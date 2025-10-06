variable "launchdarkly_access_token" {
  description = "LaunchDarkly API access token"
  type        = string
  sensitive   = true
}

variable "view_maintainer_id" {
  description = "LaunchDarkly member ID to set as maintainer for views"
  type        = string
}