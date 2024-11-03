# Backend para almacenar tfstate y lock
terraform {
  backend "s3" {
    bucket         = "lab04-bucket-tf"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab04-dynamoDB-tf"
    encrypt        = true
  }
}
