with cust_fee as (
    select * from {{ ref('stg_cust_fee_billing') }} where is_current = true
),

cust_acct as (
    select * from {{ ref('stg_cust_custodial_account') }} where is_current = true
),

fsc_acct as (
    select
        fa.financial_account_number,
        fa.account_id as sfdc_account_id,
        fa.custodian_name as fsc_custodian_name,
        fa.management_fee_rate as fsc_fee_rate,
        a.account_name as fsc_account_name,
        a.client_segment,
        a.advisor_id
    from {{ ref('stg_fsc_financial_account') }} fa
    join {{ ref('stg_fsc_account') }} a on a.account_id = fa.account_id and a.is_current = true
    where fa.is_current = true
)

select
    cust_fee.fee_id,
    cust_fee.account_number,

    -- fee_type: Custodian only
    cust_fee.fee_type                       as cust_fee_type,
    coalesce(cust_fee.fee_type)             as resolved_fee_type,

    -- fee_rate: Custodian vs FSC
    cust_fee.fee_rate                       as cust_fee_rate,
    fsc_acct.fsc_fee_rate                   as fsc_fee_rate,
    coalesce(cust_fee.fee_rate, fsc_acct.fsc_fee_rate) as resolved_fee_rate,

    -- fee_amount: Custodian only
    cust_fee.fee_amount                     as cust_fee_amount,
    coalesce(cust_fee.fee_amount)           as resolved_fee_amount,

    -- billable_aum: Custodian only
    cust_fee.billable_aum                   as cust_billable_aum,
    coalesce(cust_fee.billable_aum)         as resolved_billable_aum,

    -- billing period
    cust_fee.billing_period_start,
    cust_fee.billing_period_end,
    cust_fee.debit_date,

    -- status: Custodian only
    cust_fee.status                         as cust_fee_status,
    coalesce(cust_fee.status)               as resolved_fee_status,

    -- custodian context
    cust_acct.custodian_code                as cust_custodian_code,
    cust_acct.rep_code                      as cust_rep_code,

    -- FSC context (enrichment)
    fsc_acct.sfdc_account_id,
    fsc_acct.fsc_account_name,
    fsc_acct.fsc_custodian_name,
    fsc_acct.client_segment,
    fsc_acct.advisor_id,

    -- resolution metadata
    case
        when cust_fee.fee_id is not null and fsc_acct.financial_account_number is not null then 'CUST_FSC_MATCHED'
        when cust_fee.fee_id is not null then 'CUST_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from cust_fee
left join cust_acct
    on cust_acct.account_number = cust_fee.account_number
left join fsc_acct
    on fsc_acct.financial_account_number = cust_fee.account_number
