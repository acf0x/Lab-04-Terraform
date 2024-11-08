/*=========================================
=           Auto Scaling Group            =
=========================================*/

/* Crear un auto scaling group para instancias EC2 
   Asegura disponibilidad y escalado dinamico */

resource "aws_autoscaling_group" "asg" {
  name = "asg-lab04"
  launch_template {
    id      = aws_launch_template.lt-lab04.id
    version = "$Latest"
  }
  desired_capacity          = 2                                                                # Numero de instancias deseadas en el ASG
  min_size                  = 2                                                                # Numero minimo de instancias en el ASG
  max_size                  = 3                                                                # Numero maximo de instancias en el ASG
  vpc_zone_identifier       = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id] # Subnets donde se crearan las instancias EC2 del ASG
  target_group_arns         = [aws_lb_target_group.internal-alb-tg.arn]                        # Asociar al Target Group del ALB interno
  health_check_type         = "ELB"                                                            # Tipo de health check para el ASG, realizado por ALB
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "ec2-lab04"
    propagate_at_launch = true
  }
}

/* Crear una policy para el auto scaling group */

resource "aws_autoscaling_policy" "asg-policy" {
  name                   = "asg-policy-lab04"
  adjustment_type        = "ChangeInCapacity" # Tipo de ajuste en el escalado. ChangeInCapacity aumenta o disminuye el numero de instancias
  scaling_adjustment     = 1                  # Numero de instancias a ajustar en el escalado (1 para aumentar, -1 para disminuir)
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name # Nombre del auto scaling group al que se aplicara la policy
}

/* Crear un cloudwatch alarm para el auto scaling group
  Basado en el uso de CPU, que activa la policy creada anteriormente */

resource "aws_cloudwatch_metric_alarm" "asg-alarm" {
  alarm_name          = "asg-alarm-lab04"
  comparison_operator = "GreaterThanOrEqualToThreshold" # Operador de comparacion para la alarma. GreaterThanOrEqualToThreshold activa la alarma si el valor es mayor o igual al threshold
  evaluation_periods  = 2
  metric_name         = "CPUUtilization" # Metrica a monitorear, en este caso el uso de CPU de las instancias EC2 del ASG
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 75 # Valor del threshold para activar la alarma, en este caso 75% de uso de CPU

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "Monitorizacion de la CPU de EC2"
  alarm_actions     = [aws_autoscaling_policy.asg-policy.arn] # Acciones a realizar cuando se activa la alarma, en este caso activar la policy creada anteriormente

  tags = {
    Name          = "asg-alarm-lab04"
    resource_type = "cloudwatch"
    env           = "lab04"
    owner         = "alvarocf"
  }
}

/* Definir la lista de instancias que pertenecen al ASG para obtener ips privadas en output */

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg.name]
  }
}

# Datos sobre el Auto Scaling Group
data "aws_autoscaling_group" "asg" {
  name = aws_autoscaling_group.asg.name # Nombre de tu ASG
}