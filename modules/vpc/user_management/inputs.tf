variable "enabled" {}

variable "region" {}

variable "version" {}

variable "credstash_key" {}

variable "credstash_db" {}

variable "account_name" {}

variable "rate" {
  default = "rate(15 minutes)"
}
