{%- macro stage_snapshot(snapshot_ref, unique_key) -%}

select
    *,
    row_number() over (
        partition by {{ unique_key }}
        order by dbt_valid_from asc
    ) as version_number,
    row_number() over (
        partition by {{ unique_key }}
        order by dbt_valid_from desc
    ) as reverse_version_number,
    case
        when dbt_valid_to is null and coalesce(dbt_is_deleted, false) = false
        then true
        else false
    end as is_current
from {{ snapshot_ref }}

{%- endmacro -%}
