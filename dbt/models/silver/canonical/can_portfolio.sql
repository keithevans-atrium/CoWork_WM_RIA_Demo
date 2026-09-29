with account as (
    select
        account_value_id,
        financial_account_id,
        account_number,
        account_name,
        market_value,
        model_id,
        is_discretionary,
        client_id,
        client_name,
        client_segment,
        advisor_id,
        advisor_name
    from {{ ref('can_account_value') }}
),

model as (
    select
        model_id,
        resolved_model_name as model_name,
        risk_profile,
        equity_target_pct,
        fixed_income_target_pct,
        alternative_target_pct,
        cash_target_pct,
        is_active as model_is_active
    from {{ ref('res_model_portfolio') }}
),

latest_return as (
    select
        account_number,
        as_of_date as return_as_of_date,
        return_method,
        mtd_return,
        qtd_return,
        ytd_return,
        itd_return,
        one_year_return,
        three_year_return,
        five_year_return,
        benchmark_name,
        benchmark_mtd_return,
        benchmark_ytd_return,
        benchmark_one_year_return,
        mtd_excess_return,
        ytd_excess_return,
        one_year_excess_return
    from {{ ref('res_return_record') }}
    qualify row_number() over (
        partition by account_number
        order by as_of_date desc, portfolio_id asc
    ) = 1
),

position_summary as (
    select
        account_number,
        count(distinct resolved_ticker) as holding_count,
        sum(resolved_market_value) as holdings_market_value,
        sum(resolved_cost_basis) as holdings_cost_basis,
        sum(resolved_unrealized_gain_loss) as total_unrealized_gain_loss,
        max(as_of_date) as positions_as_of_date
    from {{ ref('res_position') }}
    group by 1
)

select
    {{ generate_pk(['account.financial_account_id']) }} as portfolio_id,

    -- account context
    account.financial_account_id,
    account.account_number,
    account.account_name,
    account.market_value,
    account.is_discretionary,

    -- client context
    account.client_id,
    account.client_name,
    account.client_segment,

    -- advisor context
    account.advisor_id,
    account.advisor_name,

    -- model portfolio
    account.model_id,
    model.model_name,
    model.risk_profile,
    model.equity_target_pct,
    model.fixed_income_target_pct,
    model.alternative_target_pct,
    model.cash_target_pct,
    model.model_is_active,

    -- latest returns
    latest_return.return_as_of_date,
    latest_return.return_method,
    latest_return.mtd_return,
    latest_return.qtd_return,
    latest_return.ytd_return,
    latest_return.itd_return,
    latest_return.one_year_return,
    latest_return.three_year_return,
    latest_return.five_year_return,
    latest_return.benchmark_name,
    latest_return.benchmark_mtd_return,
    latest_return.benchmark_ytd_return,
    latest_return.benchmark_one_year_return,
    latest_return.mtd_excess_return,
    latest_return.ytd_excess_return,
    latest_return.one_year_excess_return,

    -- holdings summary
    position_summary.holding_count,
    position_summary.holdings_market_value,
    position_summary.holdings_cost_basis,
    position_summary.total_unrealized_gain_loss,
    position_summary.positions_as_of_date,

    -- metadata
    current_timestamp() as canonical_at

from account
left join model
    on model.model_id = account.model_id
left join latest_return
    on latest_return.account_number = account.account_number
left join position_summary
    on position_summary.account_number = account.account_number
