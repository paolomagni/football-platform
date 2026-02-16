-- teams metrics calculation
with team_stats_agg as (
  select

    season_id,
    season_year,
    match_id,
    match_date,
    matchday,
    team_id,
    team_name,
    1 as matches_played,
    case when goals_for_ft > goals_against_ft then 1 else 0 end as wins,
    case when goals_for_ft < goals_against_ft then 1 else 0 end as losses,
    case when goals_for_ft = goals_against_ft then 1 else 0 end as draws,
    case when goals_for_ft > goals_against_ft then 3
         when goals_for_ft = goals_against_ft then 1
         else 0 end as points,
    goals_for_ft as goals_scored,
    goals_against_ft as goals_conceded,
    goals_for_ft - goals_against_ft as goal_difference

  from {{ ref("int_fl1__base_team_matches") }}
),

-- global matchday for every match_id
global_matchdays as (
  select
    season_id,
    team_id,
    match_id,
    row_number() over (
      partition by season_id, team_id 
      order by match_date, match_id
    ) as global_matchday
  from {{ ref("int_fl1__base_team_matches") }}

),

-- aggregation comeback/collapses for home/away
team_comeback_stats as (
  select

    season_id,
    match_id,
    team_id,
    is_home,
    is_comeback,
    is_collapse

  from {{ ref("int_fl1__comebacks") }}
)

select *

from team_stats_agg
left join team_comeback_stats using(season_id, team_id, match_id)
left join global_matchdays using(season_id, team_id, match_id)
