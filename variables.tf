# Variable de seleccion de region en AWS
variable "aws_region" {
  description = "La region de AWS"
  default     = "us-east-1"
}

variable "access_key" {
  description = "access_key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "secret_key"
  type        = string
  sensitive   = true
}