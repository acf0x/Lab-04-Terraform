/*=========================================
=                  S3                     =
=========================================*/

/* Crear un bucket de S3 
   Almacena archivos estaticos y permite versionado de los archivos */

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-lab04" # Nombre del bucket

  tags = {
    Name          = "bucket-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "s3"
  }
}

/* Habilitar versionado en el bucket S3 */

resource "aws_s3_bucket_versioning" "bucket-versioning-ejercicio" {
  bucket = aws_s3_bucket.bucket.id # Bucket al que se aplica el versionado
  versioning_configuration {
    status = "Enabled" # Estado del versionado: activado
  }
}

/* Bloquear acceso publico en el bucket de S3 */

resource "aws_s3_bucket_public_access_block" "s3-public-access-block" {
  bucket                  = aws_s3_bucket.bucket.id # Nombre del bucket
  block_public_acls       = true                    # Bloquear ACLs publicas
  block_public_policy     = true                    # Bloquear políticas publicas
  ignore_public_acls      = true                    # Ignorar ACLs publicas
  restrict_public_buckets = true                    # Restringir el acceso publico
}

/* Crear politica de acceso a S3
   Politica de acceso para servicios especificos, como CloudFront y rol de las instancias EC2 */

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "s3-policy" {
  bucket = aws_s3_bucket.bucket.id # ID del bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cf-distribution.arn}" # Solo podra acceder si el ARN es el de la distribucion de Cloudfront de este codigo
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-instance-role-lab04" # Acceso dinamico para rol de las instancias creadas en una cuenta desde este codigo
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}