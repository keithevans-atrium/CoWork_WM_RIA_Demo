select
    {{ generate_pk(['p.financial_account_id']) }} as account_value_key,

    -- dimension keys
    p.financial_account_id,
    p.account_number,
    p.client_id,
    p.advisor_id,
    p.model_id,

    -- account value measures
    p.market_value,
    p.is_discretionary,

    -- model portfolio
    p.model_name,
    p.risk_profile,
    p.equity_target_pct,
    p.fixed_income_target_pct,
    p.alternative_target_pct,
    p.cash_target_pct,

    -- latest returns
    p.return_as_of_date,
    p.mtd_return,
    p.qtd_return,
    p.ytd_return,
    p.itd_return,
    p.one_year_return,
    p.three_year_return,
    p.five_year_return,
    p.benchmark_name,
    p.mtd_excess_return,
    p.ytd_excess_return,
    p.one_year_excess_return,

    -- holdings summary
    p.holding_count,
    p.holdings_market_value,
    p.holdings_cost_basis,
    p.total_unrealized_gain_loss,
    p.positions_as_of_date,

    -- metadata
    p.canonical_at as loaded_at

from {{ ref('can_portfolio') }} p
