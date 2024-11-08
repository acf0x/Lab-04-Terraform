/*=========================================
=                  IAM                    =
=========================================*/

/* Crear rol de IAM para las instancias EC2 */

resource "aws_iam_role" "ec2-instance-role" {
  name = "ec2-instance-role-lab04"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name          = "ec2-instance-role-lab04"
    env           = "lab04"
    resource-type = "iam"
    owner         = "alvarocf"
  }
}

/* Crear politica para KMS */

resource "aws_iam_policy" "kms-access" {
  name        = "kms-access"
  description = "Politica para acceso a KMS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KMS"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

/* Adjuntar las politicas necesarias al rol de IAM */

/* Adjuntar politica al rol para acceder a KMS */

resource "aws_iam_role_policy_attachment" "kms-access" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = aws_iam_policy.kms-access.arn
}

/* Adjuntar politica al rol para conectar por SSM */

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

/* Adjuntar politica al rol para acceder a Secrets Manager */

resource "aws_iam_role_policy_attachment" "secretsmanager-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

/* Adjuntar politica al rol para acceder a S3 */

resource "aws_iam_role_policy_attachment" "s3-policy" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

/* Crear un perfil de instancia para asociar el rol a la instancia EC2 */

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "ec2-instance-profile-lab04"
  role = aws_iam_role.ec2-instance-role.name

  tags = {
    Name          = "ec2-instance-profile-lab04"
    env           = "lab04"
    resource-type = "iam-instance-profile"
    owner         = "alvarocf"
  }
}