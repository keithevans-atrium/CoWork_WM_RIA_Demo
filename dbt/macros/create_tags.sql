{%- macro create_tags() -%}

    {# -- Domain tag (table-level) #}
    {% set domain_values = [
        'Client',
        'Account',
        'Advisor',
        'Team',
        'Security',
        'Transaction',
        'Fee',
        'Return',
        'Opportunity',
        'Goal',
        'Position',
        'Benchmark',
        'Model Portfolio'
    ] %}

    CREATE TAG IF NOT EXISTS {{ target.database }}.GOLD.DOMAIN
        ALLOWED_VALUES {{ domain_values | map('tojson') | join(', ') }}
        COMMENT = 'Business domain classification for tables and views';

    {# -- PII tag (column-level) #}
    {% set pii_values = [
        'Name',
        'Email',
        'Phone',
        'Address',
        'SSN',
        'Date of Birth',
        'Tax ID'
    ] %}

    CREATE TAG IF NOT EXISTS {{ target.database }}.GOLD.PII
        ALLOWED_VALUES {{ pii_values | map('tojson') | join(', ') }}
        COMMENT = 'Personally Identifiable Information classification for columns';

{%- endmacro -%}
