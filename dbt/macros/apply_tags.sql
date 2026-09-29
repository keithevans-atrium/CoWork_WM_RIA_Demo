{%- macro apply_tags() -%}

    {%- set obj_type = 'VIEW' if config.get('materialized') == 'view' else 'TABLE' -%}
    {%- set tag_db = target.database -%}

    {# -- Apply domain tag to table/view #}
    {%- set domain = config.get('domain') -%}
    {%- if domain -%}
        ALTER {{ obj_type }} {{ this }}
            SET TAG {{ tag_db }}.GOLD.DOMAIN = '{{ domain }}';
    {%- endif -%}

    {# -- Apply PII tags to columns #}
    {%- set model_node = model -%}
    {%- if model_node and model_node.columns -%}
        {%- for col_name, col_info in model_node.columns.items() -%}
            {%- if col_info.meta and col_info.meta.get('pii') -%}
        ALTER {{ obj_type }} {{ this }}
            ALTER COLUMN {{ col_name }}
            SET TAG {{ tag_db }}.GOLD.PII = '{{ col_info.meta.pii }}';
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}

{%- endmacro -%}
