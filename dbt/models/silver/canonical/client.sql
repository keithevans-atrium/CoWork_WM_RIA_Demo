select
    a.account_id,
    a.account_name,
    a.account_type,
    a.client_segment,
    a.service_model,
    a.aum,
    a.billing_state,
    a.billing_city,
    a.billing_zip,
    a.relationship_start_date,
    a.is_active,
    c.contact_id,
    c.full_name as primary_contact_name,
    c.email as primary_contact_email,
    c.phone as primary_contact_phone,
    c.date_of_birth,
    c.employment_status,
    c.occupation,
    c.risk_tolerance,
    c.investment_experience,
    a.advisor_id,
    adv.advisor_name,
    adv.rep_code,
    adv.branch_name,
    t.team_id,
    t.team_name,
    t.region,
    a.created_date,
    a.last_modified_date
from {{ ref('raw_account') }} a
left join {{ ref('raw_contact') }} c
    on c.account_id = a.account_id and c.is_primary_contact = true
left join {{ ref('raw_advisor') }} adv
    on adv.advisor_id = a.advisor_id
left join {{ ref('raw_advisor_team') }} t
    on t.team_lead_advisor_id = adv.advisor_id
