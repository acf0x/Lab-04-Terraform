/*=========================================
=               CloudFront                =
=========================================*/

/* Crear una distribucion de CloudFront 
   Proporciona contenido estatico con baja latencia */

resource "aws_cloudfront_distribution" "cf-distribution" {
  origin {
    domain_name = aws_lb.external-nlb.dns_name # Origen del contenido, en este caso el NLB
    origin_id   = "nlb-origin"                 # ID unico para el origen

    custom_origin_config {
      http_port              = 80                     # Puerto HTTP para el origen
      https_port             = 443                    # Puerto HTTPS para el origen
      origin_protocol_policy = "https-only"           # Forzar HTTPS en el origen
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"] # Protocolos SSL permitidos
    }
  }

  default_cache_behavior {
    target_origin_id       = "nlb-origin"               # Origen a utilizar
    viewer_protocol_policy = "allow-all"                # Permitir todos los protocolos
    allowed_methods        = ["GET", "HEAD", "OPTIONS"] # Metodos permitidos en el caché
    cached_methods         = ["GET", "HEAD"]            # Metodos cacheados
    forwarded_values {
      query_string = true # Incluye strings de consultas
      cookies {
        forward = "all" # Configuracion para manejar cookies
      }
    }

    min_ttl     = 0     # TTL minimo
    default_ttl = 3600  # TTL por defecto (1 hora)
    max_ttl     = 86400 # TTL maximo (1 día)
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # Sin restricciones geograficas para el acceso
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.acm-certificate-lab04.arn # Certificado SSL
    ssl_support_method  = "sni-only"                                    # Metodo de soporte SSL SNI
  }

  default_root_object = "index.php" # Root al que accede
  enabled             = true        # Habilita la distribucion
  comment             = "Cloudfront distribution hacia NLB"
}