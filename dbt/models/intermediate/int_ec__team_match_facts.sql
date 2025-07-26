-- teams metrics calculation
with team_stats_agg as (
  select

    season_id,
    season_year,
    match_id,
    match_date,
    matchday,
    stage,
    `group`,
    team_id,
    team_name,
    1 as matches_played,
    case when goals_for_ft > goals_against_ft then 1 else 0 end as wins,
    case when goals_for_ft < goals_against_ft then 1 else 0 end as losses,
    case when goals_for_ft = goals_against_ft then 1 else 0 end as draws,
    goals_for_ft as goals_scored,
    goals_against_ft as goals_conceded,
    goals_for_ft - goals_against_ft as goal_difference

  from {{ ref("int_ec__base_team_matches") }}
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
  from {{ ref("int_ec__base_team_matches") }}
--  group by season_id, match_id, match_date
),

-- aggregation for home/away
team_stats_home_away as (
  select

    season_id,
    match_id,
    stage,
    `group`,
    team_id,
    case when is_home and goals_for_ft > goals_against_ft then 1 else 0 end as home_wins,
    case when is_home and goals_for_ft = goals_against_ft then 1 else 0 end as home_draws,
    case when is_home and goals_for_ft < goals_against_ft then 1 else 0 end as home_losses,
    case when not is_home and goals_for_ft > goals_against_ft then 1 else 0 end as away_wins,
    case when not is_home and goals_for_ft = goals_against_ft then 1 else 0 end as away_draws,
    case when not is_home and goals_for_ft < goals_against_ft then 1 else 0 end as away_losses,
    case when is_home then goals_for_ft end as goals_scored_home,
    case when is_home then goals_against_ft end as goals_conceded_home,
    case when not is_home then goals_for_ft end as goals_scored_away,
    case when not is_home then goals_against_ft end as goals_conceded_away,
    case when is_home then 1 end as home_matches_played,
    case when not is_home then 1 end as away_matches_played

  from {{ ref("int_ec__base_team_matches") }}
),

-- aggregation comeback/collapses for home/away
team_comeback_stats as (
  select

    season_id,
    match_id,
    stage,
    `group`,
    team_id,
    case when is_home and is_comeback = 1 then 1 else 0 end as home_comebacks,
    case when not is_home and is_comeback = 1 then 1 else 0 end as away_comebacks,
    case when is_home and is_collapse = 1 then 1 else 0 end as home_collapses,
    case when not is_home and is_collapse = 1 then 1 else 0 end as away_collapses

  from {{ ref("int_ec__comebacks") }}
)

select *

from team_stats_agg
left join team_stats_home_away using(season_id, stage, `group`, team_id, match_id)
left join team_comeback_stats using(season_id, stage, `group`, team_id, match_id)
left join global_matchdays using(season_id, team_id, match_id)
