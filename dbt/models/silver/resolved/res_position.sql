with perf as (
    select * from {{ ref('stg_perf_portfolio_holdings') }} where is_current = true
),

cust as (
    select * from {{ ref('stg_cust_position') }} where is_current = true
)

select
    perf.holding_id,
    perf.account_number,
    perf.as_of_date,

    -- ticker: Performance vs Custodian
    perf.ticker                             as perf_ticker,
    cust.ticker                             as cust_ticker,
    coalesce(perf.ticker, cust.ticker)      as resolved_ticker,

    -- cusip: Performance vs Custodian
    perf.cusip                              as perf_cusip,
    cust.cusip                              as cust_cusip,
    coalesce(perf.cusip, cust.cusip)        as resolved_cusip,

    -- security_description: Performance vs Custodian
    perf.security_description               as perf_security_description,
    cust.security_description               as cust_security_description,
    coalesce(perf.security_description, cust.security_description) as resolved_security_description,

    -- asset_class / sector: Performance only
    perf.asset_class,
    perf.sector,

    -- security_type: Custodian only
    cust.security_type,

    -- quantity: Performance vs Custodian
    perf.quantity                            as perf_quantity,
    cust.quantity                            as cust_quantity,
    coalesce(cust.quantity, perf.quantity)   as resolved_quantity,

    -- price: Custodian is source of truth
    cust.price                              as cust_price,
    coalesce(cust.price)                    as resolved_price,

    -- market_value: Performance vs Custodian
    perf.market_value                       as perf_market_value,
    cust.market_value                       as cust_market_value,
    coalesce(cust.market_value, perf.market_value) as resolved_market_value,

    -- cost_basis: Performance vs Custodian
    perf.cost_basis                         as perf_cost_basis,
    cust.cost_basis                         as cust_cost_basis,
    coalesce(cust.cost_basis, perf.cost_basis) as resolved_cost_basis,

    -- unrealized_gain_loss: Performance only
    perf.unrealized_gain_loss               as perf_unrealized_gain_loss,
    coalesce(cust.market_value - cust.cost_basis, perf.unrealized_gain_loss) as resolved_unrealized_gain_loss,

    -- weight: Performance only
    perf.weight_pct,

    -- cost basis method: Custodian only
    cust.cost_basis_method,
    cust.accrued_income,

    -- resolution metadata
    case
        when perf.holding_id is not null and cust.position_id is not null then 'BOTH_MATCHED'
        when perf.holding_id is not null then 'PERF_ONLY'
        when cust.position_id is not null then 'CUST_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from perf
full outer join cust
    on cust.account_number = perf.account_number
    and cust.cusip = perf.cusip
    and cust.as_of_date = perf.as_of_date
