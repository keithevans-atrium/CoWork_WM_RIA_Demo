{%- macro generate_pk(pk_columns) -%}
    md5(concat_ws('|',
        {%- for col in pk_columns %}
        coalesce(cast({{ col }} as varchar), '^^NULL^^')
        {%- if not loop.last %},{% endif %}
        {%- endfor %}
    ))
{%- endmacro -%}


{%- macro generate_change_key(columns) -%}
    md5(concat_ws('|',
        {%- for col in columns %}
        coalesce(cast({{ col }} as varchar), '^^NULL^^')
        {%- if not loop.last %},{% endif %}
        {%- endfor %}
    ))
{%- endmacro -%}
