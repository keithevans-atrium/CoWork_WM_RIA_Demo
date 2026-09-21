select
    {{ generate_pk(['return_id']) }} as record_pk,
    return_id,
    account_number,
    portfolio_id,
    as_of_date,
    mtd_return,
    qtd_return,
    ytd_return,
    itd_return,
    one_year_return,
    three_year_return,
    five_year_return,
    benchmark_id,
    benchmark_mtd_return,
    benchmark_ytd_return,
    benchmark_one_year_return,
    return_method,
    loaded_at,
    'performance_system' as _source_system,
    current_timestamp() as _loaded_at,
    'PORTFOLIO_RETURN' as _record_source,
    {{ generate_change_key([
        'account_number', 'portfolio_id', 'as_of_date', 'mtd_return', 'qtd_return',
        'ytd_return', 'itd_return', 'one_year_return', 'three_year_return', 'five_year_return',
        'benchmark_id', 'benchmark_mtd_return', 'benchmark_ytd_return', 'benchmark_one_year_return'
    ]) }} as change_key
from {{ source('performance_system', 'portfolio_return') }}
