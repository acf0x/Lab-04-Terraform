/*=========================================
=                Backend                  =
=========================================*/

/* Backend para almacenar tfstate y lock */

terraform {
  backend "s3" {
    bucket         = "lab05-bucket-tf"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lk-lab04"
    encrypt        = true
  }
}