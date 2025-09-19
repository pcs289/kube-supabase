variable "db_params" {
  type = list(object({ name : string, value : string }))
}

variable "param_family" {
  type    = string
  default = "postgres17"
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "17.2"
}

variable "identifier" {
  type = string
}

variable "master_user" {
  type = string
}

variable "master_password" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "max_storage" {
  type = number
}

variable "storage" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
