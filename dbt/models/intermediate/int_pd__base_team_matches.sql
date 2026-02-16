-- base CTE for home/away matches
with base as (
  select
    season_id,
    match_id,
    extract(date from utc_date) as match_date,
    matchday,
    extract(year from season_end_date) as season_year,
    home_team_id as team_id,
    home_team_name as team_name,
    halftime_home_goals as goals_for_ht,
    halftime_away_goals as goals_against_ht,
    fulltime_home_goals as goals_for_ft,
    fulltime_away_goals as goals_against_ft,
    true as is_home
  from {{ ref("stg_pd__matches") }}

  union all

  select
    season_id,
    match_id,
    extract(date from utc_date) as match_date,
    matchday,
    extract(year from season_end_date) as season_year,
    away_team_id,
    away_team_name,
    halftime_away_goals,
    halftime_home_goals,
    fulltime_away_goals,
    fulltime_home_goals,
    false as is_home
  from {{ ref("stg_pd__matches") }}
)

select *
from base
