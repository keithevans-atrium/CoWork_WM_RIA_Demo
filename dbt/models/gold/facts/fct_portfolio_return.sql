with returns as (
    select *
    from {{ ref('res_return_record') }}
    qualify row_number() over (
        partition by account_number, as_of_date
        order by portfolio_id asc
    ) = 1
)

select
    {{ generate_pk(['returns.account_number', 'returns.as_of_date']) }} as return_key,

    -- dimension keys
    returns.account_number,
    returns.as_of_date,
    returns.sfdc_account_id as client_id,
    returns.advisor_id,
    returns.benchmark_id,

    -- portfolio returns
    returns.mtd_return,
    returns.qtd_return,
    returns.ytd_return,
    returns.itd_return,
    returns.one_year_return,
    returns.three_year_return,
    returns.five_year_return,

    -- benchmark returns
    returns.benchmark_name,
    returns.benchmark_mtd_return,
    returns.benchmark_ytd_return,
    returns.benchmark_one_year_return,

    -- excess returns
    returns.mtd_excess_return,
    returns.ytd_excess_return,
    returns.one_year_excess_return,

    -- attributes
    returns.return_method,
    returns.portfolio_id,
    returns.client_segment,
    returns.match_status,
    returns.resolved_at as loaded_at

from returns
