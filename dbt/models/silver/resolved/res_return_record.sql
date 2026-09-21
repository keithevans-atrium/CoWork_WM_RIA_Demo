with perf as (
    select * from {{ ref('stg_perf_portfolio_return') }} where is_current = true
),

bench as (
    select benchmark_id, benchmark_name, benchmark_type
    from {{ ref('stg_perf_benchmark') }}
    where is_current = true
),

fsc_acct as (
    select
        fa.financial_account_number,
        fa.account_id as sfdc_account_id,
        a.client_segment,
        a.advisor_id
    from {{ ref('stg_fsc_financial_account') }} fa
    join {{ ref('stg_fsc_account') }} a on a.account_id = fa.account_id and a.is_current = true
    where fa.is_current = true
)

select
    perf.return_id,
    perf.account_number,
    perf.portfolio_id,
    perf.as_of_date,

    perf.mtd_return,
    perf.qtd_return,
    perf.ytd_return,
    perf.itd_return,
    perf.one_year_return,
    perf.three_year_return,
    perf.five_year_return,

    perf.benchmark_id,
    bench.benchmark_name,
    bench.benchmark_type,

    perf.benchmark_mtd_return,
    perf.benchmark_ytd_return,
    perf.benchmark_one_year_return,

    perf.mtd_return - perf.benchmark_mtd_return as mtd_excess_return,
    perf.ytd_return - perf.benchmark_ytd_return as ytd_excess_return,
    perf.one_year_return - perf.benchmark_one_year_return as one_year_excess_return,

    perf.return_method,

    -- FSC enrichment
    fsc_acct.sfdc_account_id,
    fsc_acct.client_segment,
    fsc_acct.advisor_id,

    case
        when perf.return_id is not null and fsc_acct.financial_account_number is not null then 'PERF_FSC_MATCHED'
        when perf.return_id is not null then 'PERF_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from perf
left join bench on bench.benchmark_id = perf.benchmark_id
left join fsc_acct on fsc_acct.financial_account_number = perf.account_number
