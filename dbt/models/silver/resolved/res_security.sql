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
),

master as (
    select *
    from {{ ref('stg_security_master') }}
    where is_current = true
)

select
    coalesce(perf.security_id, master.record_pk) as security_id,

    -- ticker: Master > Performance > Custodian
    perf.ticker                             as perf_ticker,
    cust.ticker                             as cust_ticker,
    master.ticker                           as master_ticker,
    coalesce(master.ticker, perf.ticker, cust.ticker) as resolved_ticker,

    -- cusip: Master > Performance > Custodian
    perf.cusip                              as perf_cusip,
    cust.cusip                              as cust_cusip,
    master.cusip                            as master_cusip,
    coalesce(master.cusip, perf.cusip, cust.cusip) as resolved_cusip,

    -- isin: Master only
    master.isin,

    -- security_name: Master > Performance > Custodian
    perf.security_description               as perf_security_name,
    cust.security_description               as cust_security_name,
    master.security_name                    as master_security_name,
    coalesce(master.security_name, perf.security_description, cust.security_description) as resolved_security_name,

    -- classifications: Master > Performance > Custodian
    coalesce(master.asset_class, perf.asset_class) as asset_class,
    master.sub_asset_class,
    coalesce(master.sector, perf.sector) as sector,
    coalesce(master.security_type, cust.security_type) as security_type,

    -- master-only attributes
    master.exchange,
    master.currency,
    master.issuer,
    master.country,
    master.inception_date,
    master.expense_ratio,
    master.dividend_yield,
    master.market_cap_category,
    master.is_esg,
    master.risk_rating,
    master.benchmark_index,
    master.description as security_description,
    coalesce(master.is_active, true) as is_active,

    -- resolution metadata
    case
        when master.ticker is not null and perf.ticker is not null and cust.ticker is not null then 'ALL_MATCHED'
        when master.ticker is not null and perf.ticker is not null then 'MASTER_PERF'
        when master.ticker is not null and cust.ticker is not null then 'MASTER_CUST'
        when master.ticker is not null then 'MASTER_ONLY'
        when perf.ticker is not null and cust.ticker is not null then 'PERF_CUST'
        when perf.ticker is not null then 'PERF_ONLY'
        when cust.ticker is not null then 'CUST_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from master
full outer join perf on perf.ticker = master.ticker
full outer join cust on cust.ticker = coalesce(master.ticker, perf.ticker)
