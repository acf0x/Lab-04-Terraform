/*=========================================
=                Providers                =
=========================================*/

/* Configuracion del provider a utilizar. AWS version 5.74.0 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
  }
}

/* Variables de inicio de sesion
   Definidas en terraform.tfvars */

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}