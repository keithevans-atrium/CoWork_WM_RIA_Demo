with fsc_account as (
    select * from {{ ref('stg_account') }} where is_current = true
),

fsc_contact as (
    select * from {{ ref('stg_contact') }} where is_current = true and is_primary_contact = true
),

perf as (
    select * from {{ ref('stg_perf_account') }} where is_current = true
),

cust as (
    select * from {{ ref('stg_custodial_account') }} where is_current = true
),

fin_acct as (
    select * from {{ ref('stg_financial_account') }} where is_current = true
)

select
    fsc_account.account_id,
    fin_acct.financial_account_number as account_number,

    -- first_name: all sources + resolved
    fsc_contact.first_name as fsc_first_name,
    null as perf_first_name,
    null as cust_first_name,
    {{ resolve_attribute([('fsc_contact', 'first_name')], 'resolved_first_name') }},

    -- last_name: all sources + resolved
    fsc_contact.last_name as fsc_last_name,
    null as perf_last_name,
    null as cust_last_name,
    {{ resolve_attribute([('fsc_contact', 'last_name')], 'resolved_last_name') }},

    -- email: all sources + resolved
    fsc_contact.email as fsc_email,
    fsc_account.email as fsc_account_email,
    {{ resolve_attribute([('fsc_contact', 'email'), ('fsc_account', 'email')], 'resolved_email') }},

    -- phone: all sources + resolved
    fsc_contact.phone as fsc_contact_phone,
    fsc_account.phone as fsc_account_phone,
    {{ resolve_attribute([('fsc_contact', 'phone'), ('fsc_account', 'phone')], 'resolved_phone') }},

    -- address: FSC is source of truth
    fsc_account.billing_state as fsc_state,
    fsc_contact.mailing_state as fsc_contact_state,
    {{ resolve_attribute([('fsc_account', 'billing_state'), ('fsc_contact', 'mailing_state')], 'resolved_state') }},

    fsc_account.billing_city as fsc_city,
    {{ resolve_attribute([('fsc_account', 'billing_city')], 'resolved_city') }},

    fsc_account.billing_zip as fsc_zip,
    {{ resolve_attribute([('fsc_account', 'billing_zip')], 'resolved_zip') }},

    -- account_name: FSC vs custodian
    fsc_account.account_name as fsc_account_name,
    cust.account_title as cust_account_name,
    {{ resolve_attribute([('fsc_account', 'account_name'), ('cust', 'account_title')], 'resolved_account_name') }},

    -- registration: FSC vs custodian
    fin_acct.registration_type as fsc_registration_type,
    cust.registration_type as cust_registration_type,
    {{ resolve_attribute([('fin_acct', 'registration_type'), ('cust', 'registration_type')], 'resolved_registration_type') }},

    -- status: all sources
    fsc_account.is_active as fsc_is_active,
    fin_acct.status as fsc_account_status,
    perf.status as perf_status,
    cust.status as cust_status,

    -- client attributes (FSC only)
    fsc_account.account_type,
    fsc_account.client_segment,
    fsc_account.service_model,
    fsc_contact.risk_tolerance,
    fsc_contact.investment_experience,
    fsc_contact.date_of_birth,
    fsc_contact.employment_status,
    fsc_contact.occupation,
    fsc_account.advisor_id,
    fsc_account.relationship_start_date,

    -- custodian-specific
    cust.custodian_code,
    cust.rep_code,
    cust.branch_code,

    -- performance-specific
    perf.model_id,
    perf.total_market_value,
    perf.advisor_code as perf_advisor_code,

    -- resolution metadata
    case
        when fsc_account.account_id is not null and perf.account_number is not null and cust.account_number is not null then 'ALL_MATCHED'
        when fsc_account.account_id is not null and perf.account_number is not null then 'FSC_PERF'
        when fsc_account.account_id is not null and cust.account_number is not null then 'FSC_CUST'
        when fsc_account.account_id is not null then 'FSC_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from fsc_account
left join fsc_contact
    on fsc_contact.account_id = fsc_account.account_id
left join fin_acct
    on fin_acct.account_id = fsc_account.account_id
left join perf
    on perf.account_number = fin_acct.financial_account_number
left join cust
    on cust.account_number = fin_acct.financial_account_number
