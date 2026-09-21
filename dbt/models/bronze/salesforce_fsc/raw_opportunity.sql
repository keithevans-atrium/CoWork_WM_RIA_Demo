select
    {{ generate_pk(['opportunity_id']) }} as record_pk,
    opportunity_id,
    account_id,
    contact_id,
    opportunity_name,
    stage,
    opportunity_type,
    amount,
    expected_revenue,
    close_date,
    probability,
    lead_source,
    advisor_id,
    created_date,
    last_modified_date,
    'salesforce_fsc' as _source_system,
    current_timestamp() as _loaded_at,
    'OPPORTUNITY' as _record_source,
    {{ generate_change_key([
        'account_id', 'contact_id', 'opportunity_name', 'stage', 'opportunity_type',
        'amount', 'expected_revenue', 'close_date', 'probability', 'lead_source', 'advisor_id'
    ]) }} as change_key
from {{ source('salesforce_fsc', 'opportunity') }}
