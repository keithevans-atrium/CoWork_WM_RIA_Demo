select
    {{ generate_pk(['holding_id']) }} as record_pk,
    holding_id,
    account_number,
    portfolio_id,
    as_of_date,
    security_id,
    ticker,
    cusip,
    security_description,
    asset_class,
    sector,
    quantity,
    market_value,
    cost_basis,
    unrealized_gain_loss,
    weight_pct,
    loaded_at,
    {{ generate_change_key([
        'account_number', 'portfolio_id', 'as_of_date', 'security_id', 'ticker', 'cusip',
        'security_description', 'asset_class', 'sector', 'quantity', 'market_value',
        'cost_basis', 'unrealized_gain_loss', 'weight_pct'
    ]) }} as change_key
from {{ source('performance_system', 'portfolio_holdings') }}
