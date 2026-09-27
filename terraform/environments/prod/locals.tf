locals {

  football_competitions_scheduler = {

    import_champions_league_current = {
      name             = "import-champions-league-current"
      schedule         = "0 5 * * 4"
      competition_code = "CL"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiQ0wiLCAibW9kZSI6ImN1cnJlbnQifQ=="
    }

    import_serie_a_current = {
      name             = "import-serie-a-current"
      schedule         = "3 5 * * 4"
      competition_code = "SA"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiU0EiLCAibW9kZSI6ImN1cnJlbnQifQ=="
    }

    import_bundesliga_current = {
      name             = "import-bundesliga-current"
      schedule         = "6 5 * * 4"
      competition_code = "BL1"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiQkwxIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_eredivisie_current = {
      name             = "import-eredivisie-current"
      schedule         = "9 5 * * 4"
      competition_code = "DED"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiREVEIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_brasileirao_current = {
      name             = "import-brasileirao-current"
      schedule         = "12 5 * * 4"
      competition_code = "BSA"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiQlNBIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_liga_current = {
      name             = "import-liga-current"
      schedule         = "15 5 * * 4"
      competition_code = "PD"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiUEQiLCAibW9kZSI6ImN1cnJlbnQifQ=="
    }

    import_ligue1_current = {
      name             = "import-ligue1-current"
      schedule         = "18 5 * * 4"
      competition_code = "FL1"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiRkwxIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_championship_current = {
      name             = "import-championship-current"
      schedule         = "21 5 * * 4"
      competition_code = "ELC"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiRUxDIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_liga_portugal_current = {
      name             = "import-liga-portugal-current"
      schedule         = "24 5 * * 4"
      competition_code = "PPL"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiUFBMIiwgIm1vZGUiOiJjdXJyZW50In0="
    }

    import_premier_current = {
      name             = "import-premier-current"
      schedule         = "27 5 * * 4"
      competition_code = "PL"

      base64_body = "eyJjb21wZXRpdGlvbl9jb2RlIjoiUEwiLCAibW9kZSI6ImN1cnJlbnQifQ=="
    }

  }

}
