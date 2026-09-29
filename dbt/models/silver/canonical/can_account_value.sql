with account as (
    select *
    from {{ ref('res_account_value') }}
    qualify row_number() over (
        partition by financial_account_id
        order by match_status asc, resolved_market_value desc nulls last
    ) = 1
),

client_account as (
    select client_id, account_id, account_number
    from {{ ref('res_client_account') }}
    where is_current = true
),

client as (
    select
        acct.account_id as client_id,
        coalesce(contact.first_name, '') || ' ' || coalesce(contact.last_name, '') as client_name,
        coalesce(contact.email, acct.email) as client_email,
        coalesce(contact.phone, acct.phone) as client_phone,
        coalesce(acct.billing_state, contact.mailing_state) as client_state,
        acct.billing_city as client_city,
        acct.client_segment,
        acct.service_model,
        contact.risk_tolerance,
        contact.investment_experience
    from {{ ref('stg_fsc_account') }} acct
    left join {{ ref('stg_fsc_contact') }} contact
        on contact.account_id = acct.account_id
        and contact.is_current = true
        and contact.is_primary_contact = true
    where acct.is_current = true
),

client_advisor as (
    select client_id, advisor_id
    from {{ ref('res_client_advisor') }}
    where is_current = true
),

advisor as (
    select
        advisor_id,
        resolved_advisor_name as advisor_name,
        resolved_email as advisor_email,
        resolved_rep_code as rep_code,
        resolved_branch as branch,
        team_name,
        region
    from {{ ref('res_advisor_book') }}
    qualify row_number() over (partition by advisor_id order by match_status asc) = 1
)

select
    {{ generate_pk(['account.financial_account_id']) }} as account_value_id,

    -- account identifiers
    account.financial_account_id,
    account.account_number,
    account.resolved_account_name as account_name,
    account.resolved_registration_type as registration_type,
    account.resolved_account_type as account_type,
    account.resolved_status as status,
    account.resolved_custodian_code as custodian_code,
    account.resolved_inception_date as inception_date,

    -- account financials
    account.resolved_market_value as market_value,
    account.resolved_fee_rate as fee_rate,
    account.perf_fee_schedule as fee_schedule,
    account.resolved_model_id as model_id,
    account.resolved_is_discretionary as is_discretionary,

    -- client
    client.client_id,
    client.client_name,
    client.client_email,
    client.client_phone,
    client.client_state,
    client.client_city,
    client.client_segment,
    client.service_model,
    client.risk_tolerance,
    client.investment_experience,

    -- advisor
    advisor.advisor_id,
    advisor.advisor_name,
    advisor.advisor_email,
    advisor.rep_code as advisor_rep_code,
    advisor.branch as advisor_branch,
    advisor.team_name as advisor_team,
    advisor.region as advisor_region,

    -- metadata
    account.match_status as account_match_status,
    current_timestamp() as canonical_at

from account
left join client_account
    on client_account.account_id = account.financial_account_id
left join client
    on client.client_id = client_account.client_id
left join client_advisor
    on client_advisor.client_id = client_account.client_id
left join advisor
    on advisor.advisor_id = client_advisor.advisor_id
