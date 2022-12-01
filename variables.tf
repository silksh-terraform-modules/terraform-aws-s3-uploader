variable "tlds" {
  type = set(object({
    domain    = string
    bucket    = string
  }))
}
variable "buckets" {
  default = []
}

variable "env_scope" {
  default = ""
}