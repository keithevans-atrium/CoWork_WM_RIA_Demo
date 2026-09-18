select
    h.holding_id,
    h.account_number,
    h.portfolio_id,
    h.as_of_date,
    h.security_id,
    h.ticker,
    h.cusip,
    h.security_description,
    h.asset_class,
    h.sector,
    h.quantity,
    h.market_value,
    h.cost_basis,
    h.unrealized_gain_loss,
    h.weight_pct,
    p.price as custodian_price,
    p.cost_basis_method,
    p.accrued_income,
    b.benchmark_name,
    b.benchmark_type
from {{ ref('brz_portfolio_holdings') }} h
left join {{ ref('brz_position') }} p
    on p.account_number = h.account_number
    and p.cusip = h.cusip
    and p.as_of_date = h.as_of_date
left join {{ ref('brz_benchmark') }} b
    on b.benchmark_id = (
        select pa.model_id
        from {{ ref('brz_perf_account') }} pa
        where pa.account_number = h.account_number
        limit 1
    )
