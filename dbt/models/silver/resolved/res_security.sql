with perf as (
    select
        security_id, ticker, cusip, security_description, asset_class, sector
    from {{ ref('stg_perf_portfolio_holdings') }}
    where is_current = true
    qualify row_number() over (partition by ticker order by as_of_date desc) = 1
),

cust as (
    select
        ticker, cusip, security_description, security_type
    from {{ ref('stg_cust_position') }}
    where is_current = true
    qualify row_number() over (partition by ticker order by as_of_date desc) = 1
)

select
    perf.security_id,

    perf.ticker                             as perf_ticker,
    cust.ticker                             as cust_ticker,
    coalesce(perf.ticker, cust.ticker)      as resolved_ticker,

    perf.cusip                              as perf_cusip,
    cust.cusip                              as cust_cusip,
    coalesce(perf.cusip, cust.cusip)        as resolved_cusip,

    perf.security_description               as perf_security_name,
    cust.security_description               as cust_security_name,
    coalesce(perf.security_description, cust.security_description) as resolved_security_name,

    perf.asset_class,
    perf.sector,
    cust.security_type,

    case
        when perf.ticker is not null and cust.ticker is not null then 'BOTH_MATCHED'
        when perf.ticker is not null then 'PERF_ONLY'
        when cust.ticker is not null then 'CUST_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from perf
full outer join cust on cust.ticker = perf.ticker
