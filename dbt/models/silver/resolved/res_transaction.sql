with cust as (
    select * from {{ ref('stg_cust_transaction') }} where is_current = true
),

cust_acct as (
    select account_number, custodian_code, rep_code
    from {{ ref('stg_cust_custodial_account') }}
    where is_current = true
),

fsc_acct as (
    select
        fa.financial_account_number,
        fa.account_id as sfdc_account_id,
        a.account_name as fsc_account_name,
        a.client_segment,
        a.advisor_id
    from {{ ref('stg_fsc_financial_account') }} fa
    join {{ ref('stg_fsc_account') }} a on a.account_id = fa.account_id and a.is_current = true
    where fa.is_current = true
)

select
    cust.transaction_id,
    cust.account_number,

    cust.trade_date,
    cust.settle_date,

    cust.transaction_type                   as cust_transaction_type,
    coalesce(cust.transaction_type)         as resolved_transaction_type,

    cust.ticker                             as cust_ticker,
    cust.cusip                              as cust_cusip,
    coalesce(cust.ticker)                   as resolved_ticker,
    coalesce(cust.cusip)                    as resolved_cusip,

    cust.security_description               as cust_security_description,
    coalesce(cust.security_description)     as resolved_security_description,

    cust.quantity,
    cust.price,
    cust.gross_amount,
    cust.net_amount,
    cust.commission,
    cust.fees,
    cust.cancel_status,

    -- custodian context
    cust_acct.custodian_code,
    cust_acct.rep_code,

    -- FSC enrichment
    fsc_acct.sfdc_account_id,
    fsc_acct.fsc_account_name,
    fsc_acct.client_segment,
    fsc_acct.advisor_id,

    case
        when cust.transaction_id is not null and fsc_acct.financial_account_number is not null then 'CUST_FSC_MATCHED'
        when cust.transaction_id is not null then 'CUST_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from cust
left join cust_acct on cust_acct.account_number = cust.account_number
left join fsc_acct on fsc_acct.financial_account_number = cust.account_number
