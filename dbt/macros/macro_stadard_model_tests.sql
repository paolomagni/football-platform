/*
    Macro that returns a dictionary of standard model-level tests
    based on the provided model name. The output is a list of test configurations
    to be applied to the given model in the YAML.
*/


{% macro standard_model_tests(model_name) %}
  {% set tests = {
    'stg_cl__matches': [
      {'dbt_utils.unique_combination_of_columns': {'combination_of_columns': ['match_id']}}
    ]
  } %}
  {{ return(tests.get(model_name, [])) }}
{% endmacro %}
