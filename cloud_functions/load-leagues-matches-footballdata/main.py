import json
from google.cloud import storage, bigquery
import functions_framework
from datetime import datetime, timezone
import os
import re

# Config
PROJECT_ID = os.environ.get('PROJECT_ID')
BUCKET_NAME = os.environ.get('BUCKET_NAME')
DATASET_ID = "football_data"
ALLOWED_COMP_CODES = {"SA", "PL", "BL1", "DED", "BSA", "PD", "FL1", "ELC", "PPL"}

@functions_framework.cloud_event
def load_leagues_matches_footballdata(cloud_event):
    """Triggered by a change to a Cloud Storage bucket."""

    file_bucket = cloud_event.data["bucket"]
    file_name = cloud_event.data["name"]

    print(f"Triggered by file: {file_name} in bucket: {file_bucket}")

    # Match path: competition/SA/xyz.json → extract "SA"
    match = re.match(r"competition/([A-Z0-9]+)/", file_name)
    if not match:
        print(f"File {file_name} is not in a valid competition subfolder. Ignoring.")
        return "Invalid path", 200

    comp_code = match.group(1).upper()
    if comp_code not in ALLOWED_COMP_CODES:
        print(f"Competition code {comp_code} is not supported by this function. Ignoring.")
        return f"Competition {comp_code} not handled", 200

    table_id = f"raw_{comp_code.lower()}__matches"
    print(f"Detected valid competition code: {comp_code} → Table: {table_id}")

    # Client GCP
    storage_client = storage.Client(project=PROJECT_ID)
    bq_client = bigquery.Client(project=PROJECT_ID)

    # Read uploaded file
    bucket = storage_client.bucket(file_bucket)
    blob = bucket.blob(file_name)
    content = blob.download_as_string()
    data = json.loads(content)

    matches = data.get("matches", [])
    rows_to_insert = []

    for match in matches:
        row = {
            "match_id": match["id"],
            "utc_date": match["utcDate"],
            "status": match["status"],
            "matchday": match.get("matchday"),
            "home_team_id": match["homeTeam"]["id"],
            "home_team_name": match["homeTeam"]["name"],
            "away_team_id": match["awayTeam"]["id"],
            "away_team_name": match["awayTeam"]["name"],
            "fulltime_home_goals": match.get("score", {}).get("fullTime", {}).get("home"),
            "fulltime_away_goals": match.get("score", {}).get("fullTime", {}).get("away"),
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
    table_ref = bq_client.dataset(DATASET_ID).table(table_id)

    # Insert rows
    errors = bq_client.insert_rows_json(table_ref, rows_to_insert)

    if errors:
        print(f"Insertion error: {errors}")
    else:
        print(f"{len(rows_to_insert)} rows inserted correctly into {table_id}.")
