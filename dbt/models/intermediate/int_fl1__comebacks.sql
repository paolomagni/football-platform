-- calculation of comeback metric
with comeback as (
  select

    season_id,
    match_id,
    match_date,
    matchday,
    team_id,
    is_home,
    case when goals_for_ht < goals_against_ht and goals_for_ft > goals_against_ft then 1 else 0 end as is_comeback,
    case when goals_for_ht > goals_against_ht and goals_for_ft < goals_against_ft then 1 else 0 end as is_collapse
    
  from {{ ref("int_fl1__base_team_matches") }}
)

select *
from comeback
