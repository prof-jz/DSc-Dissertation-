variable "project"   { type = string }
variable "region"    { type = string }
variable "vpc_name"  { type = string }
variable "subnets" {
  type = map(object({ cidr = string, purpose = string }))
}
