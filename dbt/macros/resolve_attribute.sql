{%- macro resolve_attribute(sources, attribute_name) -%}
{#
  Resolves an attribute across multiple source systems.
  Returns the first non-null value based on priority order.
  
  Usage: {{ resolve_attribute(
    [('fsc', 'first_name'), ('perf', 'first_name'), ('cust', 'first_name')],
    'first_name'
  ) }}
#}
    coalesce(
        {%- for source_alias, col_name in sources %}
        {{ source_alias }}.{{ col_name }}
        {%- if not loop.last %},{% endif %}
        {%- endfor %}
    ) as {{ attribute_name }}
{%- endmacro -%}
