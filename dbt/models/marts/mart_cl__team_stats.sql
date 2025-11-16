-- mart table for BI visualization based on team_stats model
select

  season_id,
  season_year,
  match_id,
  match_date,
  matchday,
  global_matchday,
  stage,
  team_id,
  team_name,
  matches_played,
  wins,
  losses,
  draws,
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
  end as win_loss_type,

  case stage
    when 'LEAGUE STAGE' then 1
    when 'GROUP STAGE' then 1
    when 'PLAYOFFS' then 2
    when 'LAST 16' then 3
    when 'QUARTER FINALS' then 4
    when 'SEMI FINALS' then 5
    when 'FINAL' then 6
  end as stage_rank

from {{ ref("int_cl__team_match_facts") }}
where match_date < current_date()
