with client as (
    select * from {{ ref('stg_fsc_account') }} where is_current = true
),

contact as (
    select * from {{ ref('stg_fsc_contact') }} where is_current = true and is_primary_contact = true
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
),

account_metrics as (
    select
        ca.client_id,
        count(distinct av.financial_account_id) as account_count,
        coalesce(sum(av.resolved_market_value), 0) as total_aum
    from {{ ref('res_client_account') }} ca
    inner join {{ ref('res_account_value') }} av
        on av.financial_account_id = ca.account_id
    where ca.is_current = true
    group by 1
)

select
    {{ generate_pk(['client.account_id']) }} as canonical_client_id,

    -- client identifiers
    client.account_id as client_id,
    coalesce(contact.first_name, '') || ' ' || coalesce(contact.last_name, '') as client_name,
    contact.first_name,
    contact.last_name,

    -- contact
    coalesce(contact.email, client.email) as email,
    coalesce(contact.phone, client.phone) as phone,
    coalesce(client.billing_state, contact.mailing_state) as state,
    client.billing_city as city,
    client.billing_zip as zip,

    -- demographics
    client.account_type,
    client.client_segment,
    client.service_model,
    contact.risk_tolerance,
    contact.investment_experience,
    contact.date_of_birth,
    contact.employment_status,
    contact.occupation,
    client.relationship_start_date,

    -- book metrics
    coalesce(account_metrics.account_count, 0) as account_count,
    coalesce(account_metrics.total_aum, 0) as total_aum,

    -- primary advisor
    advisor.advisor_id,
    advisor.advisor_name,
    advisor.advisor_email,
    advisor.rep_code as advisor_rep_code,
    advisor.branch as advisor_branch,
    advisor.team_name as advisor_team,
    advisor.region as advisor_region,

    -- metadata
    current_timestamp() as canonical_at

from client
left join contact
    on contact.account_id = client.account_id
left join client_advisor
    on client_advisor.client_id = client.account_id
left join advisor
    on advisor.advisor_id = client_advisor.advisor_id
left join account_metrics
    on account_metrics.client_id = client.account_id
