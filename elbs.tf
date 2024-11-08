/*=========================================
=             Load Balancers              =
=========================================*/

/* Crear un Application Load Balancer (ALB) interno 
   Este ALB distribuirá el trafico desde el Network Load Balancer externo a las instancias */

resource "aws_lb" "internal-alb" {
  name               = "alb-lab04"
  internal           = true                                                           # Configuración para trafico interno
  load_balancer_type = "application"                                                  # Tipo de load balancer (ALB)
  security_groups    = [aws_security_group.alb-sg.id]                                 # Grupo de seguridad para el ALB
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id] # Subredes donde es desplegado el ALB

  tags = {
    Name          = "alb-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "alb"
  }
}

/* Listener HTTPS para el ALB interno
   Configurado en el puerto 443 para recibir trafico HTTPS */

resource "aws_lb_listener" "listener-internal-alb-https" {
  load_balancer_arn = aws_lb.internal-alb.arn                       # ALB que recibe las solicitudes
  port              = 443                                           # Puerto para el trafico HTTPS
  protocol          = "HTTPS"                                       # Protocolo HTTPS para el listener
  ssl_policy        = "ELBSecurityPolicy-2016-08"                   # Política SSL recomendada por AWS
  certificate_arn   = aws_acm_certificate.acm-certificate-lab04.arn # Certificado SSL asociado

  default_action {
    type             = "forward"                               # Accion por defecto: redirigir el trafico
    target_group_arn = aws_lb_target_group.internal-alb-tg.arn # Target Group para el trafico
  }
}

/* Target Group para el ALB interno 
   Define las instancias en la VPC principal como el target del trafico HTTPS */

resource "aws_lb_target_group" "internal-alb-tg" {
  name        = "internal-alb-tg-lab04"
  port        = 443                 # Puerto de destino HTTPS
  protocol    = "HTTPS"             # Protocolo de destino HTTPS
  vpc_id      = aws_vpc.vpc-main.id # VPC donde están las instancias del Target Group
  target_type = "instance"          # Tipo de destino: instancias

  health_check { # Configuración de health check
    protocol = "HTTPS"
    port     = 443
    path     = "/health" # Ruta personalizada para verificar el estado
  }

  tags = {
    Name          = "internal-alb-tg-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "tg"
  }
}

/* Crear un Network Load Balancer (NLB) externo 
   Distribuye el trafico hacia el ALB */

resource "aws_lb" "external-nlb" {
  name                             = "external-nlb-lab04"
  internal                         = false                          # Configuracion para trafico externo
  load_balancer_type               = "network"                      # Tipo de load balancer: network
  security_groups                  = [aws_security_group.nlb-sg.id] # Grupo de seguridad para el NLB
  enable_cross_zone_load_balancing = true                           # Habilitar balanceo entre zonas

  /* Mapeo en las subredes publicas */
  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-2.id
  }

  tags = {
    Name          = "external-nlb-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "nlb"
  }
}

/* Target Group para el NLB 
   Este target group redirige el trafico al ALB interno configurado */

resource "aws_lb_target_group" "external-nlb-tg" {
  name        = "external-nlb-tg-lab04"
  port        = 443                 # Puerto de destino: 443 (HTTPS)
  protocol    = "TCP"               # Protocolo de destino: TCP
  vpc_id      = aws_vpc.vpc-main.id # VPC donde esta el Target Group
  target_type = "alb"               # Tipo de destino: ALB

  health_check {
    protocol = "HTTPS"
    port     = 443
  }

  tags = {
    Name          = "external-nlb-tg-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "tg"
  }
}

/* Asociacion del Target Group del NLB al recurso */

resource "aws_lb_target_group_attachment" "external-nlb-tg-attachment" {

  depends_on = [ # Forzar dependencia explicita para evitar error al crearse antes que el listener del ALB
    aws_lb.internal-alb,
    aws_lb_listener.listener-internal-alb-https
  ]
  target_group_arn = aws_lb_target_group.external-nlb-tg.arn
  target_id        = aws_lb.internal-alb.arn
}

/* Listener para trafico HTTPS en el NLB 
   Redirige el trafico entrante del NLB al target group */

resource "aws_lb_listener" "listener-external-nlb-https" {
  load_balancer_arn = aws_lb.external-nlb.arn # NLB que recibe el trafico
  port              = 443                     # Puerto de escucha
  protocol          = "TCP"                   # Protocolo TCP para el NLB

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-nlb-tg.arn # Redireccion al target group
  }
}