with fsc as (
    select * from {{ ref('stg_fsc_financial_account') }} where is_current = true
),

perf as (
    select * from {{ ref('stg_perf_account') }} where is_current = true
),

cust as (
    select * from {{ ref('stg_cust_custodial_account') }} where is_current = true
)

select
    fsc.financial_account_id,
    fsc.financial_account_number as account_number,

    -- account_name: FSC vs Custodian
    fsc.financial_account_name              as fsc_account_name,
    cust.account_title                      as cust_account_name,
    coalesce(fsc.financial_account_name, cust.account_title) as resolved_account_name,

    -- registration_type: FSC vs Custodian
    fsc.registration_type                   as fsc_registration_type,
    cust.registration_type                  as cust_registration_type,
    coalesce(fsc.registration_type, cust.registration_type) as resolved_registration_type,

    -- account_type: FSC only
    fsc.account_type                        as fsc_account_type,
    coalesce(fsc.account_type)              as resolved_account_type,

    -- balance / market_value: FSC vs Performance
    fsc.balance                             as fsc_balance,
    perf.total_market_value                 as perf_market_value,
    coalesce(perf.total_market_value, fsc.balance) as resolved_market_value,

    -- custodian: FSC name vs Custodian code
    fsc.custodian_name                      as fsc_custodian_name,
    cust.custodian_code                     as cust_custodian_code,
    coalesce(cust.custodian_code,
        case fsc.custodian_name
            when 'Schwab' then 'SCHW'
            when 'Pershing' then 'PERS'
            when 'Fidelity' then 'FIDL'
        end
    ) as resolved_custodian_code,

    -- status: all sources
    fsc.status                              as fsc_status,
    perf.status                             as perf_status,
    cust.status                             as cust_status,
    coalesce(fsc.status, perf.status, cust.status) as resolved_status,

    -- fee rate: FSC only
    fsc.management_fee_rate                 as fsc_fee_rate,
    perf.fee_schedule                       as perf_fee_schedule,
    fsc.management_fee_rate                 as resolved_fee_rate,

    -- model: FSC vs Performance
    fsc.model_portfolio                     as fsc_model_id,
    perf.model_id                           as perf_model_id,
    coalesce(perf.model_id, fsc.model_portfolio) as resolved_model_id,

    -- discretionary flag
    fsc.is_discretionary                    as fsc_is_discretionary,
    perf.is_discretionary                   as perf_is_discretionary,
    coalesce(fsc.is_discretionary, perf.is_discretionary) as resolved_is_discretionary,

    -- inception / open date: FSC vs Custodian
    fsc.inception_date                      as fsc_inception_date,
    cust.date_opened                        as cust_date_opened,
    coalesce(fsc.inception_date, cust.date_opened) as resolved_inception_date,

    -- custodian-specific
    cust.rep_code,
    cust.branch_code,
    cust.margin_approved,
    cust.options_level,

    -- performance-specific
    perf.portfolio_id,
    perf.advisor_code                       as perf_advisor_code,

    -- FSC linkage
    fsc.account_id                          as sfdc_account_id,
    fsc.contact_id                          as sfdc_contact_id,

    -- resolution metadata
    case
        when fsc.financial_account_id is not null and perf.account_number is not null and cust.account_number is not null then 'ALL_MATCHED'
        when fsc.financial_account_id is not null and perf.account_number is not null then 'FSC_PERF'
        when fsc.financial_account_id is not null and cust.account_number is not null then 'FSC_CUST'
        when fsc.financial_account_id is not null then 'FSC_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from fsc
left join perf
    on perf.account_number = fsc.financial_account_number
left join cust
    on cust.account_number = fsc.financial_account_number
