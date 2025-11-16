
with source as (

    select *,
    from {{ source('european_championship', 'raw_ec__matches') }}
    qualify date(import_timestamp) = max(date(import_timestamp)) over (partition by season_id)

)

    select
        match_id,
        utc_date,
        REPLACE(status, '_', ' ') as status,
        matchday,
        REPLACE(stage, '_', ' ') as stage,
        REPLACE(`group`, '_', ' ') as `group`,
        home_team_id,
        home_team_name,
        away_team_id,
        away_team_name,
        fulltime_home_goals,
        fulltime_away_goals,
        halftime_home_goals,
        halftime_away_goals,
        winner,
        referees,
        competition_id,
        competition_name,
        competition_code,
        season_id,
        season_start_date,
        season_end_date,
        import_timestamp

    from source
    where status != 'SCHEDULED'
