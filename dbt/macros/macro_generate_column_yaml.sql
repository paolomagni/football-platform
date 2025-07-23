/*
    Macro to recursively generate YAML configuration for a model's columns.
    It appends each column's name, description, and optional tests to the model_yaml list.
    Handles nested/struct fields if present by calling itself recursively.
*/


{% macro generate_column_yaml(column, model_yaml, column_desc_dict, parent_column_name="") %}

    {% set metadata = standard_column_metadata() %}
    {% if parent_column_name %}
        {% set column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set column_name = column.name %}
    {% endif %}

    {% set description = column_desc_dict.get(column.name | lower, metadata.get(column.name | lower, {}).get("description", "")) %}
    {% set tests = metadata.get(column.name | lower, {}).get("tests", []) %}

    {% do model_yaml.append('      - name: ' ~ column.name | lower ) %}
    {% do model_yaml.append('        description: "' ~ description ~ '"') %}

    {% if tests | length > 0 %}
        {% do model_yaml.append('        tests:') %}
        {% for test in tests %}
            {% do model_yaml.append('          - ' ~ test) %}
        {% endfor %}
    {% endif %}

    {% do model_yaml.append('') %}

    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = codegen.generate_column_yaml(child_column, model_yaml, column_desc_dict, parent_column_name=column_name) %}
        {% endfor %}
    {% endif %}

    {% do return(model_yaml) %}

{% endmacro %}
