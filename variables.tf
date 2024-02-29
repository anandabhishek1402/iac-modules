variable "pipeline_name"{ 
    type = string
}
variable "team_tag"{
    type = string
}
variable "stages"{
     type = list(object({

        skaffold_profile_name = string
         target = object({
             type = string
             name = string
             project = string
              deploy_service_account_email = string
            artifact_storage = optional(string)
             membership = optional(string)
             location = optional(string)
         })
         require_approval = optional(bool, false)

     }))
     default = []
 }
