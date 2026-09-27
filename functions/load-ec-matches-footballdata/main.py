import json
from google.cloud import storage, bigquery
import functions_framework
from datetime import datetime, timezone
import os


# Config
PROJECT_ID = os.environ.get('PROJECT_ID')
BUCKET_NAME = os.environ.get('BUCKET_NAME')
DATASET_ID = "football_data"
TABLE_ID = "raw_ec__matches"

def get_final_goals(match, team):
    """
    Returns goals scored by the specified team (home or away) without considering penalties.
    If the match ends in penalties, add regularTime + extraTime (if applicable).
    """
    score = match.get("score", {})
    duration = score.get("duration")

    if duration == "PENALTY_SHOOTOUT":
        regular_goals = score.get("regularTime", {}).get(team, 0) or 0
        extra_goals = score.get("extraTime", {}).get(team, 0) or 0
        return regular_goals + extra_goals
    else:
        return score.get("fullTime", {}).get(team, 0) or 0

@functions_framework.cloud_event
def load_ec_matches_footballdata(cloud_event):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
         cloud_event (google.events.cloud.storage.v1.ObjectFinalizedData):
             The Cloud Storage event payload.
    """

    # Get file info from event
    file_bucket = cloud_event.data["bucket"]
    file_name = cloud_event.data["name"]

    print(f"Triggered by file: {file_name} in bucket: {file_bucket}")

    # Check if the file is in the 'competition/EC/' folder
    if not file_name.startswith('competition/EC/'):
        print(f"File {file_name} is not in the 'competition/EC/' folder. Ignoring.")
        return "File not in 'competition/EC/' folder", 200

    # Client GCP
    storage_client = storage.Client(project=PROJECT_ID)
    bq_client = bigquery.Client(project=PROJECT_ID)

    # Read uploaded file
    bucket = storage_client.bucket(file_bucket)
    blob = bucket.blob(file_name)
    content = blob.download_as_string()
    data = json.loads(content)

    # Parsing matches
    matches = data.get("matches", [])
    rows_to_insert = []

    for match in matches:
        row = {
            "match_id": match["id"],
            "utc_date": match["utcDate"],
            "status": match["status"],
            "matchday": match.get("matchday"),
            "stage": match.get("stage"),
            "group": match.get("group"),
            "home_team_id": match["homeTeam"]["id"],
            "home_team_name": match["homeTeam"]["name"],
            "away_team_id": match["awayTeam"]["id"],
            "away_team_name": match["awayTeam"]["name"],
            "fulltime_home_goals": get_final_goals(match, "home"),
            "fulltime_away_goals": get_final_goals(match, "away"),
            "halftime_home_goals": match.get("score", {}).get("halfTime", {}).get("home"),
            "halftime_away_goals": match.get("score", {}).get("halfTime", {}).get("away"),
            "winner": match.get("score", {}).get("winner"),
            "referees": ", ".join([ref["name"] for ref in match.get("referees", [])]),
            "competition_id": match["competition"]["id"],
            "competition_name": match["competition"]["name"],
            "competition_code": match["competition"]["code"],
            "season_id": match["season"]["id"],
            "season_start_date": match["season"]["startDate"],
            "season_end_date": match["season"]["endDate"],
            "import_timestamp": datetime.now(timezone.utc).isoformat()
        }
        rows_to_insert.append(row)

    # BigQuery table reference
    table_ref = bq_client.dataset(DATASET_ID).table(TABLE_ID)

    # Insert rows
    errors = bq_client.insert_rows_json(table_ref, rows_to_insert)

    if errors:
        print(f"Insertion error: {errors}")
    else:
        print(f"{len(rows_to_insert)} rows inserted correctly.")
