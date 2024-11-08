/*=========================================
=             Launch Template             =
=========================================*/

/* Crear un Launch Template para el Auto Scaling Group
   Incluye script para montaje de EFS y configuracion dinamica de SSL y WordPress */

resource "aws_launch_template" "lt-lab04" {
  image_id               = var.ami-id                            # Variable de la imagen de la AMI a utilizar
  instance_type          = var.ec2-type                          # Variable del tipo de instancia EC2 a utilizar
  vpc_security_group_ids = [aws_security_group.instancias-sg.id] # Grupo de seguridad para las instancias EC2
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile.name # Asociar el perfil de instancia definido en iam.tf al launch template
  }
  user_data = base64encode(<<-EOF
#!/bin/bash
yum install -y amazon-efs-utils
mount -t efs -o tls ${aws_efs_file_system.efs.id}:/ /mnt
echo "${aws_efs_file_system.efs.id}:/ /mnt efs _netdev,tls 0 0" >> /etc/fstab
ln -s /mnt /var/www/html
cat <<'EOL' > /etc/httpd/conf.d/ssl.conf
<VirtualHost *:443>

    DocumentRoot /var/www/html
    ServerName ${aws_lb.external-nlb.dns_name}

        SSLEngine on
        SSLCertificateFile /etc/ssl/my-certificate.pem
        SSLCertificateKeyFile /etc/ssl/my-private-key.pem

            SSLProtocol all -SSLv2 -SSLv3
            SSLCipherSuite HIGH:!aNULL:!MD5

                <Directory /var/www/html>
                AllowOverride All
                </Directory>

</VirtualHost>
EOL
cat <<-'EOV' > /var/www/html/wp-config.php
<?php

require 'vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

$client = new SecretsManagerClient([
    'version' => 'latest',
    'region'  => 'us-east-1'
    ]);

$result = $client->getSecretValue([
    'SecretId' => '${aws_secretsmanager_secret.db-secret.arn}',  // Nombre del secreto generado de manera dinamica
]);

$secret = json_decode($result['SecretString'], true);

$username = $secret['username'];
$password = $secret['password'];

define( 'AS3CF_SETTINGS', serialize( array(
    'provider' => 'aws',
    'use-server-roles' => true,
) ) );
define( 'DB_NAME', 'wp_db' );
define( 'DB_USER', $username );
define( 'DB_PASSWORD', $password );
define( 'DB_HOST', '${aws_route53_record.rds-record.name}'  );  // Nombre del registro DNS interno de RDS generado de manera dinamica
define('WP_SITEURL', 'https://' . $_SERVER['HTTP_HOST']);
define('WP_HOME', 'https://' . $_SERVER['HTTP_HOST']);
define('WP_CACHE',true);
define('WP_REDIS_HOST', '${aws_route53_record.redis-record.name}'); // Nombre del registro DNS interno de Redis generado de manera dinamica
define('WP_REDIS_PORT', 6379);
define('MEMCACHED_HOST', '${aws_route53_record.memcached-record.name}');  // Nombre del registro DNS interno de Memcached generado de manera dinamica
define('MEMCACHED_PORT', 11211);
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AS3CF_ASSETS_PULL_SETTINGS', serialize( array(
    'domain' => '${aws_cloudfront_distribution.cf-distribution.domain_name}',
    'rewrite-urls' => true,
    'force-https' => true,
    'serve-from-s3' => true,
    'ssl' => 'https',
    'expires' => 365,
) ) );
$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */


/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOV
systemctl restart httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      resource_type = "ec2"
      env           = "lab04"
      owner         = "alvarocf"
    }
  }
}