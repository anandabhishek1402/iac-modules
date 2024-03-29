terraform {
  experiments = [ module_variable_optional_attrs ]

}



locals{
    shared_cd_project_id = "shared-deploy@shared-project-verily.iam.gserviceaccount.com"
    deafult_artifact_storage = "gs://shared_artifact_demo"
    pipeline_location = "us-central1"
    pipeline_name = var.pipeline_name
    team_tag = var.team_tag
    stages = var.stages
    project_id = "shared-project-verily"
}


resource "google_clouddeploy_delivery_pipeline" "primary" {
  location    = local.pipeline_location
  name        = local.pipeline_name
  description = "basic description"
  project     = local.project_id

  serial_pipeline {
    dynamic "stages" {
        for_each = { for idx, stage in local.stages : idx => stage }

        content{
            profiles = [stages.value.skaffold_profile_name]
            target_id = google_clouddeploy_target.primary[stages.key].name
        }
    }
  }

  provider    = google-beta
}

resource "google_clouddeploy_target" "primary" {
  for_each = { for idx, stage in local.stages : idx => stage }

    # project = local.project_id
  location          = local.pipeline_location
  name              = "${local.team_tag}-${each.value.target.name}"
  description       = "multi-target description"
  project = local.project_id

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = each.value.target.deploy_service_account_email
    artifact_storage =  coalesce(each.value.target.artifact_storage, local.deafult_artifact_storage)
  }
  require_approval = each.value.require_approval

  dynamic "gke"{
    for_each = each.value.target.type == "PRIVATE_GKE" ? [1] : []
    content {
      # membership = "projects/${each.value.target.project}/locations/global/memberships/${each.value.target.memberships}"
      cluster = "projects/${each.value.target.project}/locations/${each.value.target.location}/clusters/${each.value.target.name}"
    }

  }
  provider          = google-beta
}
