resource "google_cloud_scheduler_job" "job" {

  for_each = var.jobs

  name   = each.value.name
  region = each.value.region

  schedule  = each.value.schedule
  time_zone = each.value.time_zone

  attempt_deadline = each.value.attempt_deadline

  http_target {

    uri         = each.value.uri
    http_method = each.value.http_method

    body = each.value.base64_body


    dynamic "oidc_token" {

      for_each = each.value.oidc_token == null ? [] : [each.value.oidc_token]

      content {

        service_account_email = oidc_token.value.service_account_email
        audience              = oidc_token.value.audience

      }
    }


    dynamic "oauth_token" {

      for_each = each.value.oauth_token == null ? [] : [each.value.oauth_token]

      content {

        service_account_email = oauth_token.value.service_account_email
        scope                 = oauth_token.value.scope

      }
    }
  }


  dynamic "retry_config" {

    for_each = each.value.retry_config == null ? [] : [each.value.retry_config]

    content {

      min_backoff_duration = retry_config.value.min_backoff_duration
      max_backoff_duration = retry_config.value.max_backoff_duration
      max_retry_duration   = retry_config.value.max_retry_duration
      max_doublings        = retry_config.value.max_doublings

    }
  }
}
