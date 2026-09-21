select
    return_id,
    r.account_number,
    r.portfolio_id,
    r.as_of_date,
    r.mtd_return,
    r.qtd_return,
    r.ytd_return,
    r.itd_return,
    r.one_year_return,
    r.three_year_return,
    r.five_year_return,
    r.benchmark_id,
    b.benchmark_name,
    r.benchmark_mtd_return,
    r.benchmark_ytd_return,
    r.benchmark_one_year_return,
    r.mtd_return - r.benchmark_mtd_return as mtd_excess_return,
    r.ytd_return - r.benchmark_ytd_return as ytd_excess_return,
    r.one_year_return - r.benchmark_one_year_return as one_year_excess_return,
    r.return_method
from {{ ref('raw_portfolio_return') }} r
left join {{ ref('raw_benchmark') }} b
    on b.benchmark_id = r.benchmark_id
