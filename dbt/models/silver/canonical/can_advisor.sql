with advisor as (
    select
        advisor_id,
        fsc_first_name as first_name,
        fsc_last_name as last_name,
        resolved_advisor_name as advisor_name,
        resolved_email as email,
        resolved_role as role,
        crd_number,
        resolved_rep_code as rep_code,
        resolved_branch as branch,
        team_id,
        team_name,
        region,
        fsc_is_active as is_active,
        hire_date,
        termination_date,
        match_status
    from {{ ref('res_advisor_book') }}
    qualify row_number() over (partition by advisor_id order by match_status asc) = 1
),

client_advisor as (
    select advisor_id, client_id
    from {{ ref('res_client_advisor') }}
    where is_current = true
),

book_metrics as (
    select
        ca.advisor_id,
        count(distinct ca.client_id) as client_count,
        count(distinct clac.account_id) as account_count,
        coalesce(sum(av.resolved_market_value), 0) as total_aum
    from {{ ref('res_client_advisor') }} ca
    inner join {{ ref('res_client_account') }} clac
        on clac.client_id = ca.client_id
        and clac.is_current = true
    inner join {{ ref('res_account_value') }} av
        on av.financial_account_id = clac.account_id
    where ca.is_current = true
    group by 1
)

select
    {{ generate_pk(['advisor.advisor_id']) }} as canonical_advisor_id,

    -- advisor identifiers
    advisor.advisor_id,
    advisor.advisor_name,
    advisor.first_name,
    advisor.last_name,
    advisor.email,
    advisor.role,
    advisor.crd_number,
    advisor.rep_code,
    advisor.branch,
    advisor.is_active,
    advisor.hire_date,
    advisor.termination_date,

    -- team
    advisor.team_id,
    advisor.team_name,
    advisor.region,

    -- book metrics
    coalesce(book_metrics.client_count, 0) as client_count,
    coalesce(book_metrics.account_count, 0) as account_count,
    coalesce(book_metrics.total_aum, 0) as total_aum,

    -- metadata
    advisor.match_status as advisor_match_status,
    current_timestamp() as canonical_at

from advisor
left join book_metrics
    on book_metrics.advisor_id = advisor.advisor_id
