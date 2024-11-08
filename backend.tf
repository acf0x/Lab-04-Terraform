/*=========================================
=                Backend                  =
=========================================*/

/* Backend para almacenar tfstate y lock */

terraform {
  backend "s3" {
    bucket         = "acf-bucket-tf-lab04"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acf-dynamodb-lk-lab04"
    encrypt        = true
  }
}