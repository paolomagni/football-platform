/*
	Original source code from dbt-codegen
	https://github.com/dbt-labs/dbt-codegen/blob/0.9.0/macros/generate_model_yaml.sql

    Macro to dynamically generate YAML configuration for one or more dbt models.
    It retrieves column metadata and tests (both standard and optionally upstream)
    and structures them in a list of YAML lines. Model-level tests are added if configured.
    At runtime (if execute), it logs and returns the complete YAML as a string.
*/


{% macro generate_model_yaml(model_names=[], upstream_descriptions=False) %}

    {% set model_yaml=[] %}

    {% do model_yaml.append('version: 2') %}
    {% do model_yaml.append('') %}
    {% do model_yaml.append('models:') %}

    {% if model_names is string %}
        {{ exceptions.raise_compiler_error("The `model_names` argument must always be a list, even if there is only one model.") }}
    {% else %}
        {% for model in model_names %}
            {% do model_yaml.append('  - name: ' ~ model | lower) %}
            {% do model_yaml.append('    description: ""') %}
            {% do model_yaml.append('    columns:') %}

            {% set relation=ref(model) %}
            {%- set columns = adapter.get_columns_in_relation(relation) -%}
            {% set column_desc_dict =  codegen.build_dict_column_descriptions(model) if upstream_descriptions else {} %}

            {% for column in columns %}
                {% set model_yaml = generate_column_yaml(column, model_yaml, column_desc_dict) %}
            {% endfor %}

            {# adding model-level tests if availables #}
            {% set model_tests = standard_model_tests(model) %}
            {% if model_tests | length > 0 %}
                {% do model_yaml.append('    tests:') %}
                {% for test in model_tests %}
                    {% for test_name, test_args in test.items() %}
                        {% if test_args is mapping and test_args | length > 0 %}
                            {% do model_yaml.append('      - ' ~ test_name ~ ':') %}
                            {% for arg_name, arg_value in test_args.items() %}
                                {% if arg_value is iterable and not arg_value is string %}
                                    {% do model_yaml.append('          ' ~ arg_name ~ ': ' ~ arg_value | tojson) %}
                                {% else %}
                                    {% do model_yaml.append('          ' ~ arg_name ~ ': ' ~ arg_value) %}
                                {% endif %}
                            {% endfor %}
                        {% else %}
                            {% do model_yaml.append('      - ' ~ test_name) %}
                        {% endif %}
                    {% endfor %}
                {% endfor %}
            {% endif %}

        {% endfor %}
    {% endif %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
