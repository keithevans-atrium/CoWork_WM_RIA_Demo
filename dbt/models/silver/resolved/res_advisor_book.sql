with fsc_advisor as (
    select * from {{ ref('stg_fsc_advisor') }} where is_current = true
),

fsc_team_member as (
    select * from {{ ref('stg_fsc_advisor_team') }} where is_current = true
),

cust_reps as (
    select distinct
        rep_code,
        custodian_code,
        branch_code
    from {{ ref('stg_cust_custodial_account') }}
    where is_current = true
),

fsc_accounts as (
    select
        advisor_id,
        count(distinct account_id) as fsc_client_count,
        sum(aum) as fsc_total_aum
    from {{ ref('stg_fsc_account') }}
    where is_current = true and is_active = true
    group by 1
)

select
    fsc_advisor.advisor_id,

    -- advisor_name: FSC only
    fsc_advisor.first_name                  as fsc_first_name,
    fsc_advisor.last_name                   as fsc_last_name,
    fsc_advisor.first_name || ' ' || fsc_advisor.last_name as resolved_advisor_name,

    -- email: FSC only
    fsc_advisor.email                       as fsc_email,
    coalesce(fsc_advisor.email)             as resolved_email,

    -- role: FSC only
    fsc_advisor.role                        as fsc_role,
    coalesce(fsc_advisor.role)              as resolved_role,

    -- crd_number: FSC only
    fsc_advisor.crd_number,

    -- rep_code: FSC vs Custodian
    fsc_advisor.rep_code                    as fsc_rep_code,
    cust_reps.rep_code                      as cust_rep_code,
    coalesce(fsc_advisor.rep_code, cust_reps.rep_code) as resolved_rep_code,

    -- branch: FSC vs Custodian
    fsc_advisor.branch_name                 as fsc_branch_name,
    cust_reps.branch_code                   as cust_branch_code,
    coalesce(fsc_advisor.branch_name)       as resolved_branch,

    -- custodian linkage
    cust_reps.custodian_code,

    -- team info: FSC only
    fsc_team_member.team_id,
    fsc_team_member.team_name,
    fsc_team_member.region,

    -- active status
    fsc_advisor.is_active                   as fsc_is_active,
    fsc_advisor.hire_date,
    fsc_advisor.termination_date,

    -- book metrics from FSC
    fsc_accounts.fsc_client_count,
    fsc_accounts.fsc_total_aum,

    -- resolution metadata
    case
        when fsc_advisor.advisor_id is not null and cust_reps.rep_code is not null then 'FSC_CUST_MATCHED'
        when fsc_advisor.advisor_id is not null then 'FSC_ONLY'
        else 'UNMATCHED'
    end as match_status,

    current_timestamp() as resolved_at

from fsc_advisor
left join fsc_team_member
    on fsc_team_member.team_lead_advisor_id = fsc_advisor.advisor_id
left join cust_reps
    on cust_reps.rep_code = fsc_advisor.rep_code
left join fsc_accounts
    on fsc_accounts.advisor_id = fsc_advisor.advisor_id
