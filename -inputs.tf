variable "name" {
  type        = string
  description = "String to append to resource names."
}

variable "schedule_expression" {
  type        = string
  description = "(Optional) cron() or rate() string for triggering lambda by scheduled Eventbridge rule"
  default     = ""
}

variable "alarm_sns_topic" {
  type        = string
  description = "(Optional) SNS topic for for connection limit alarm to send an alert"
  default     = null
}

variable "dry_run" {
  type        = bool
  description = "Flag to set lambda into 'informational only' mode"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Maps of tags to apply to resources"
  default     = {}
}

variable "idle_connection_threshold_seconds" {
  type        = string
  description = "Number of seconds to compare connection idle time against to determine whether or not to close the connection"
  default     = 86400
}

variable "concurrent_request_limit" {
  type        = string
  description = "Size of close connection batches from lambda function"
  default     = 50
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "list of security groups to attach to lambda"
  default     = []
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "list of vpc subnet ids to create network interfaces for lambda"
  default     = []
}

variable "redis_nodes_for_alarms" {
  type = list(string)
  description = "List of nodes to assign alarms to it's CurrConnection metric"
  default = []
}
