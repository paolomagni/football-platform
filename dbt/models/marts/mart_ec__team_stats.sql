-- mart table for BI visualization based on team_stats model
select

  season_id,
  season_year,
  match_id,
  match_date,
  matchday,
  global_matchday,
  stage,
  `group`,
  team_id,
  team_name,
  matches_played,
  wins,
  losses,
  draws,
  goals_scored,
  goals_conceded,
  goal_difference,
  goals_scored_home,
  goals_conceded_home,
  goals_scored_away,
  goals_conceded_away,
  home_matches_played,
  away_matches_played,
  home_wins,
  home_draws,
  home_losses,
  away_wins,
  away_draws,
  away_losses,
  home_comebacks,
  away_comebacks,
  home_collapses,
  away_collapses,
  case stage
    when 'LEAGUE STAGE' then 1
    when 'GROUP STAGE' then 1
    when 'PLAYOFFS' then 2
    when 'LAST 16' then 3
    when 'QUARTER FINALS' then 4
    when 'SEMI FINALS' then 5
    when 'FINAL' then 6
  end as stage_rank

from {{ ref("int_ec__team_match_facts") }}
