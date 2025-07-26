-- teams metrics calculation
with team_stats_agg as (
  select

    season_id,
    season_year,
    stage,
    team_id,
    team_name,
    count(*) as matches_played,
    sum(case when goals_for_ft > goals_against_ft then 1 else 0 end) as wins,
    sum(case when goals_for_ft < goals_against_ft then 1 else 0 end) as losses,
    sum(case when goals_for_ft = goals_against_ft then 1 else 0 end) as draws,
    sum(goals_for_ft) as goals_scored,
    sum(goals_against_ft) as goals_conceded,
    sum(goals_for_ft - goals_against_ft) as goal_difference

  from {{ ref("int_cl__base_team_matches") }}
  group by season_id, season_year, stage, team_id, team_name
),

-- aggregation for home/away
team_stats_home_away as (
  select

    season_id,
    stage,
    team_id,
    sum(case when is_home and goals_for_ft > goals_against_ft then 1 else 0 end) as home_wins,
    sum(case when is_home and goals_for_ft = goals_against_ft then 1 else 0 end) as home_draws,
    sum(case when is_home and goals_for_ft < goals_against_ft then 1 else 0 end) as home_losses,
    sum(case when not is_home and goals_for_ft > goals_against_ft then 1 else 0 end) as away_wins,
    sum(case when not is_home and goals_for_ft = goals_against_ft then 1 else 0 end) as away_draws,
    sum(case when not is_home and goals_for_ft < goals_against_ft then 1 else 0 end) as away_losses,
    sum(case when is_home then goals_for_ft end) as goals_scored_home,
    sum(case when is_home then goals_against_ft end) as goals_conceded_home,
    sum(case when not is_home then goals_for_ft end) as goals_scored_away,
    sum(case when not is_home then goals_against_ft end) as goals_conceded_away,
    count(case when is_home then 1 end) as home_matches_played,
    count(case when not is_home then 1 end) as away_matches_played

  from {{ ref("int_cl__base_team_matches") }}
  group by season_id, stage, team_id
),

-- aggregation comeback/collapses for home/away
team_comeback_stats as (
  select

    season_id,
    stage,
    team_id,
    sum(case when is_home and is_comeback = 1 then 1 else 0 end) as home_comebacks,
    sum(case when not is_home and is_comeback = 1 then 1 else 0 end) as away_comebacks,
    sum(case when is_home and is_collapse = 1 then 1 else 0 end) as home_collapses,
    sum(case when not is_home and is_collapse = 1 then 1 else 0 end) as away_collapses

  from {{ ref("int_cl__comebacks") }}
  group by season_id, stage, team_id
)

select *

from team_stats_agg
left join team_stats_home_away using(season_id, stage, team_id)
left join team_comeback_stats using(season_id, stage, team_id)
