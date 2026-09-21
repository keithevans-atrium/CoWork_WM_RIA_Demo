select
    fa.financial_account_id,
    fa.financial_account_number as account_number,
    fa.financial_account_name,
    fa.account_type,
    fa.registration_type,
    fa.custodian_name,
    fa.balance as sfdc_balance,
    fa.inception_date,
    fa.model_portfolio,
    fa.management_fee_rate,
    fa.is_discretionary,
    fa.status,
    fa.account_id as sfdc_account_id,
    pa.portfolio_id,
    pa.total_market_value,
    pa.model_id,
    pa.custodian_code,
    pa.fee_schedule,
    ca.rep_code,
    ca.branch_code,
    ca.margin_approved,
    ca.options_level,
    ca.date_opened,
    cb.cash_balance,
    cb.money_market_balance,
    cb.total_cash,
    cb.available_to_trade
from {{ ref('raw_financial_account') }} fa
left join {{ ref('raw_perf_account') }} pa
    on pa.account_number = fa.financial_account_number
left join {{ ref('raw_custodial_account') }} ca
    on ca.account_number = fa.financial_account_number
left join {{ source('custodian', 'cash_balance') }} cb
    on cb.account_number = fa.financial_account_number
