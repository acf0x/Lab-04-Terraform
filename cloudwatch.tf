resource "aws_cloudwatch_dashboard" "cw-dashboard" {
  dashboard_name = "Cloudwatch-Dashboard-lab04"

  dashboard_body = jsonencode({
    widgets = [
      # Promedio de utilizacion de CPU de las instancias del ASG
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Utilizacion de CPU del ASG ${aws_autoscaling_group.asg.name}"
        }
      },

      # Trafico de red ASG
      {
        "type" : "metric",
        "x" : 6,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            [".", "NetworkOut", ".", "."]
          ],
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1",
          "title" : "Trafico de red del ASG ${aws_autoscaling_group.asg.name}"
        }
      },

      # Lectura/escritura en disco del ASG
      {
        "type" : "metric",
        "x" : 12,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "DiskReadOps", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            [".", "DiskWriteOps", ".", "."]
          ],
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1",
          "title" : "Lectura/escritura en disco del ASG ${aws_autoscaling_group.asg.name}"
        }
      },

      # Uso de CPU de la instancia RDS
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.rds.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Uso de CPU de la instancia RDS ${aws_db_instance.rds.id}"
        }
      },

      # Espacio libre en la instancia RDS
      {
        "type" : "metric",
        "x" : 6,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.rds.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Espacio libre en la instancia RDS ${aws_db_instance.rds.id}"
        }
      },

      # Conexiones a la base de datos
      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.rds.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Conexiones a la base de datos ${aws_db_instance.rds.id}"
        }
      },
      # Peticiones en el ALB
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.internal-alb.id]
          ],
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1",
          "title" : "Peticiones en el ALB ${aws_lb.internal-alb.id}"
        }
      },
      # Tiempo de respuesta promedio del ALB
      {
        "type" : "metric",
        "x" : 6,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.internal-alb.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Tiempo de respuesta promedio del ALB ${aws_lb.internal-alb.id}"
        }
      },
      # Targets healthy del ALB
      {
        "type" : "metric",
        "x" : 12,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.internal-alb.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Targets healthy del ALB ${aws_lb.internal-alb.id}"
        }
      },
      # Targets unhealthy del ALB
      {
        "type" : "metric",
        "x" : 18,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "UnhealthyHostCount", "LoadBalancer", aws_lb.internal-alb.id]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1",
          "title" : "Targets unhealthy del ALB ${aws_lb.internal-alb.id}"
        }
      },
      # Metricas de trafico del NLB
      {
        "type" : "metric",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", "${aws_lb.external-nlb.dns_name}"],
            [".", "NewFlowCount", "LoadBalancer", "${aws_lb.external-nlb.dns_name}"],
            [".", "ProcessedBytes", "LoadBalancer", "${aws_lb.external-nlb.dns_name}"]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "us-east-1",
          "period" : 300,
          "title" : "Metricas de trafico del NLB ${aws_lb.external-nlb.dns_name}"
        }
      },
    ]
  })
}