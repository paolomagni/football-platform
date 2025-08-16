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
  
),

-- aggregation comeback/collapses for home/away
team_comeback_stats as (
  select

    season_id,
    match_id,
    stage,
    `group`,
    team_id,
    is_home,
    is_comeback,
    is_collapse

  from {{ ref("int_ec__comebacks") }}
)

select

  team_stats_agg.season_id,
  team_stats_agg.season_year,
  team_stats_agg.match_id,
  team_stats_agg.match_date,
  team_stats_agg.matchday,
  team_stats_agg.stage,
  team_stats_agg.`group`,
  team_stats_agg.team_id,
  team_stats_agg.team_name,
  team_stats_agg.matches_played,
  team_stats_agg.wins,
  team_stats_agg.losses,
  team_stats_agg.draws,
  team_stats_agg.goals_scored,
  team_stats_agg.goals_conceded,
  team_stats_agg.goal_difference,
  tcs.is_home,
  tcs.is_comeback,
  tcs.is_collapse,
  gm.global_matchday

from team_stats_agg

left join team_comeback_stats tcs
  on team_stats_agg.season_id = tcs.season_id
  and team_stats_agg.stage = tcs.stage
  and team_stats_agg.team_id = tcs.team_id
  and team_stats_agg.match_id = tcs.match_id
  and (
    team_stats_agg.`group` = tcs.`group`
    or (team_stats_agg.`group` is null and tcs.`group` is null)
  )
  
left join global_matchdays gm
  on team_stats_agg.season_id = gm.season_id
  and team_stats_agg.team_id = gm.team_id
  and team_stats_agg.match_id = gm.match_id
