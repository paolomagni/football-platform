
with source as (

    select * from {{ source('champions_league', 'raw_cl__matches') }}
    where DATE(import_timestamp) = (
        select MAX(DATE(import_timestamp)) 
        from {{ source('champions_league', 'raw_cl__matches') }}
    )

)

    select
        match_id,
        utc_date,
        REPLACE(status, '_', ' ') as status,
        matchday,
        REPLACE(stage, '_', ' ') as stage,
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
