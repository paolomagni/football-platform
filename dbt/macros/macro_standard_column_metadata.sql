/*
    Macro defining a dictionary of standard metadata for known column names.
    Each entry can contain a description and a list of tests associated with the column.
    Used by other macros to enrich column YAML definitions dynamically.
*/


{% macro standard_column_metadata() %}
    {% set metadata = {

        "match_id": {
            "description": "Unique ID of the match",
            "tests": ["not_null", "unique"]
        },
        "utc_date": {
            "description": "Date and time of the match"
        },
        "match_date": {
            "description": "Date when the match was played"
        },
        "status": {
            "description": "The status of a match. [SCHEDULED | LIVE | IN PLAY | PAUSED | FINISHED | POSTPONED | SUSPENDED | CANCELLED]"
        },
        "matchday": {
            "description": "Number of the matchday within the stage of the competition when the match was played"
        },
        "stage": {
            "description": "The stage of the match. [LEAGUE STAGE or GROUP STAGE | PLAYOFFS | LAST 16 | QUARTER FINALS | SEMI FINALS | FINAL]"
        },
        "home_team_id": {
            "description": "Unique ID of the team playing at home",
            "tests": ["not_null"]
        },
        "home_team_name": {
            "description": "Name of the team playing at home",
            "tests": ["not_null"]
        },
        "away_team_id": {
            "description": "Unique ID of the team playing away",
            "tests": ["not_null"]
        },
        "away_team_name": {
            "description": "Name of the team playing away",
            "tests": ["not_null"]
        },
        "fulltime_home_goals": {
            "description": "Goals scored in the game by the home team"
        },
        "fulltime_away_goals": {
            "description": "Goals scored in the game by the away team"
        },
        "halftime_home_goals": {
            "description": "Goals scored in the first half by the home team"
        },
        "halftime_away_goals": {
            "description": "Goals scored in the first half by the away team"
        },
        "winner": {
            "description": "Label of the team winning the game, otherwise draw [HOME_TEAM | AWAY_TEAM | DRAW]"
        },
        "referees": {
            "description": "Name and surname of the main referee of the match"
        },
        "competition_id": {
            "description": "Unique ID of the match"
        },
        "competition_name": {
            "description": "Unique name of the competition"
        },
        "competition_code": {
            "description": "Unique name of the competition",
            "tests": ["not_null"]
        },
        "season_id": {
            "description": "Unique ID of the season within the competition",
            "tests": ["not_null"]
        },
        "season_start_date": {
            "description": "Date of the season start"
        },
        "season_end_date": {
            "description": "Date of the season end"
        },
        "import_timestamp": {
            "description": "Timestamp of data import from https://www.football-data.org/",
            "tests": ["not_null"]
        },

        "season_year": {
            "description": "Year extracted from season_end_date"
        },
        "team_id": {
            "description": "Unique ID of the team",
            "tests": ["not_null"]
        },
        "team_name": {
            "description": "Name of the team",
            "tests": ["not_null"]
        },
        "goals_for_ht": {
            "description": "Goals scored by the team in the first half"
        },
        "goals_against_ht": {
            "description": "Goals conceded by the team in the first half"
        },
        "goals_for_ft": {
            "description": "Goals scored by the team in the full match"
        },
        "goals_against_ft": {
            "description": "Goals conceded by the team in the full match"
        },
        "is_home": {
            "description": "True if the team is playing at home, False otherwise",
            "tests": [
                {
                    "accepted_values": {
                        "values": [True, False],
                        "quote": false
                    }
                }
            ]
        },

        "is_comeback": {
            "description": "True if the team made a comeback",
            "tests": ["not_null"]
        },
        "is_collapse": {
            "description": "True if the team collapsed",
            "tests": ["not_null"]
        },

        "matches_played": {"description": "Total matches played"},
        "wins": {"description": "Total matches won"},
        "losses": {"description": "Total matches lost"},
        "draws": {"description": "Total matches drawn"},
        "goals_scored": {"description": "Total goals scored"},
        "goals_conceded": {"description": "Total goals scored conceded"},
        "avg_goals_scored": {"description": "Average goals scored per match"},
        "avg_goals_conceded": {"description": "Average goals conceded per match"},
        "avg_goal_difference": {"description": "Average goal difference per match"},
        "home_wins": {"description": "Matches won at home"},
        "home_draws": {"description": "Matches drawn at home"},
        "home_losses": {"description": "Matches lost at home"},
        "away_wins": {"description": "Matches won away"},
        "away_draws": {"description": "Matches drawn away"},
        "away_losses": {"description": "Matches lost away"},
        "avg_goals_scored_home": {"description": "Average goals scored at home"},
        "avg_goals_conceded_home": {"description": "Average goals conceded at home"},
        "avg_goals_scored_away": {"description": "Average goals scored away"},
        "avg_goals_conceded_away": {"description": "Average goals conceded away"},
        "home_comebacks": {"description": "Number of home comebacks"},
        "away_comebacks": {"description": "Number of away comebacks"},
        "home_collapses": {"description": "Number of home collapses"},
        "away_collapses": {"description": "Number of away collapses"}

    } %}

    {{ return(metadata) }}
{% endmacro %}
