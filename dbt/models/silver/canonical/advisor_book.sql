select
    adv.advisor_id,
    adv.advisor_name,
    adv.first_name,
    adv.last_name,
    adv.email,
    adv.role,
    adv.crd_number,
    adv.rep_code,
    adv.branch_name,
    adv.is_active,
    adv.hire_date,
    t.team_id,
    t.team_name,
    t.region,
    tm.role_in_team,
    count(distinct a.account_id) as client_count,
    sum(a.aum) as total_aum,
    avg(a.aum) as avg_aum_per_client
from {{ ref('raw_advisor') }} adv
left join {{ source('salesforce_fsc', 'advisor_team_member') }} tm
    on tm.advisor_id = adv.advisor_id and tm.is_active = true
left join {{ ref('raw_advisor_team') }} t
    on t.team_id = tm.team_id
left join {{ ref('raw_account') }} a
    on a.advisor_id = adv.advisor_id and a.is_active = true
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
