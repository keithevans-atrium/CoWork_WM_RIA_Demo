select
    c.advisor_id,
    c.advisor_name,
    c.team_name,
    c.region,
    c.client_segment,
    count(distinct c.account_id) as client_count,
    count(distinct av.account_number) as account_count,
    sum(av.total_market_value) as total_aum,
    sum(av.total_cash) as total_cash,
    sum(av.total_market_value) + coalesce(sum(av.total_cash), 0) as total_assets,
    avg(av.total_market_value) as avg_account_value,
    sum(case when av.is_discretionary then av.total_market_value else 0 end) as discretionary_aum,
    sum(case when not av.is_discretionary then av.total_market_value else 0 end) as non_discretionary_aum
from {{ ref('client') }} c
left join {{ ref('account_value') }} av
    on av.sfdc_account_id = c.account_id
group by 1, 2, 3, 4, 5
