import functions_framework
import requests
import os
import json
import time
import logging
from google.cloud import storage
from datetime import datetime, timezone

# ENV VARS: FOOTBALL_DATA_API_KEY, BUCKET_NAME

API_BASE = "https://api.football-data.org/v4/competitions/{}"
RATE_DELAY = 6  # to respect free plan rate limit

@functions_framework.http
def fetch_matches_footballdata(request):
    try:
        request_json = request.get_json(force=True)
    except Exception as e:
        logging.error("Invalid or missing JSON body")
        return ("Invalid or missing JSON body", 400)

    competition_code = request_json.get("competition_code")
    mode = request_json.get("mode")
    year = request_json.get("year")  # used only for mode == "year"

    if not competition_code or not mode:
        logging.error("Missing required parameters: competition_code, mode")
        return ("Missing required parameters: competition_code, mode", 400)

    api_key = os.environ.get("FOOTBALL_DATA_API_KEY")
    if not api_key:
        logging.error("Missing FOOTBALL_DATA_API_KEY in env")
        return ("Missing FOOTBALL_DATA_API_KEY in env", 500)

    headers = {"X-Auth-Token": api_key}

    # Fetch metadata for the competition
    comp_uri = API_BASE.format(competition_code)
    comp_resp = requests.get(comp_uri, headers=headers)
    if comp_resp.status_code != 200:
        logging.error(f"Failed to retrieve competition metadata: {comp_resp.status_code}")
        return (f"Failed to retrieve competition metadata: {comp_resp.status_code}", 500)

    comp_data = comp_resp.json()
    all_seasons = comp_data.get("seasons", [])

    if not all_seasons:
        logging.warning("No seasons metadata available")
        return ("No seasons metadata available", 404)

    # Mapping seasons
    seasons_info = {
        int(season["startDate"][:4]): season
        for season in all_seasons
        if "startDate" in season and "endDate" in season
    }

    available_years = sorted(seasons_info.keys())
    current_year = max(available_years)

    if mode == "current":
        selected_years = [current_year]
    elif mode == "history":
        selected_years = [y for y in available_years if y < current_year]
    elif mode == "year":
        if not year:
            logging.error("Missing 'year' parameter for mode 'year'")
            return ("Missing 'year' parameter for mode 'year'", 400)
        try:
            selected_years = [int(year)]
        except ValueError:
            logging.error("Invalid year format")
            return ("Invalid year format", 400)
    else:
        logging.error(f"Invalid mode: {mode}")
        return ("Invalid mode: must be one of 'current', 'history', 'year'", 400)

    # GCS setup
    bucket_name = os.environ["BUCKET_NAME"]
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)

    saved = 0
    skipped = 0
    errors = []

    for start_year in selected_years:
        season_info = seasons_info.get(start_year)
        if not season_info:
            logging.warning(f"Season info not found for start year {start_year}")
            continue

        end_year = int(season_info["endDate"][:4])
        season_label = f"{start_year}-{str(end_year)[-2:]}"  # es. 2023-24

        uri = f"{comp_uri}/matches?season={start_year}"
        logging.info(f"Fetching {competition_code} {season_label}")
        resp = requests.get(uri, headers=headers)

        if resp.status_code == 403:
            logging.warning(f"✋ SKIP {season_label}: not included in free plan")
            skipped += 1
            continue
        elif resp.status_code != 200:
            logging.error(f"⚠️ Error {season_label}: status {resp.status_code}")
            errors.append({"season": season_label, "status": resp.status_code})
            continue

        data = resp.json()
        filename = f"competition/{competition_code}/{season_label}.json"
        blob = bucket.blob(filename)
        blob.upload_from_string(json.dumps(data), content_type="application/json")
        logging.info(f"✅ Saved {filename}")
        saved += 1
        time.sleep(RATE_DELAY)

    response = {
        "competition_code": competition_code,
        "mode": mode,
        "saved_seasons": saved,
        "skipped_seasons": skipped,
        "failed_seasons": errors,
        "gcs_prefix": f"gs://{bucket_name}/competition/{competition_code}/"
    }

    return (json.dumps(response), 200, {"Content-Type": "application/json"})
