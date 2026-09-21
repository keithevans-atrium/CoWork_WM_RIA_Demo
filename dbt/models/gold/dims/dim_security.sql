select
    ticker as security_key,
    cusip,
    ticker,
    security_description,
    asset_class,
    sector
from {{ ref('raw_portfolio_holdings') }}
qualify row_number() over (partition by ticker order by as_of_date desc) = 1
