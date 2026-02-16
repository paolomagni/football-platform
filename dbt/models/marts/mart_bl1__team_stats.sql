-- mart table for BI visualization based on team_stats model
select

  season_id,
  season_year,
  match_id,
  match_date,
  matchday,
  global_matchday,
  team_id,
  team_name,
  matches_played,
  wins,
  losses,
  draws,
  points,
  goals_scored,
  goals_conceded,
  goal_difference,
  is_home,
  is_comeback,
  is_collapse,

  case 
    when wins = 1 and is_comeback = 1 then 'Win - Comeback'
    when wins = 1 then 'Win'
    when losses = 1 and is_collapse = 1 then 'Loss - Collapse'
    when losses = 1 then 'Loss'
    when draws = 1 then 'Draw'
  end as win_loss_type

from {{ ref("int_bl1__team_match_facts") }}
where match_date < current_date()
