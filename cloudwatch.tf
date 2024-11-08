/*:::::::::::::::::::::::::::::::::::::::::
:           Cloudwatch Dashboard          :
:::::::::::::::::::::::::::::::::::::::::*/

resource "aws_cloudwatch_dashboard" "cw-dashboard" {
  dashboard_name = "Cloudwatch-Dashboard-lab04"

  dashboard_body = jsonencode({
    widgets = [

      /* Metricas de peticiones al NLB */
      {
        "type" : "metric"
        "width" : 6
        "height" : 6
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.external-nlb.arn],
          ]
          "period" : 300
          "stat" : "Sum"
          "region" : "us-east-1"
          "title" : "Peticiones al NLB ${aws_lb.external-nlb.name}"
        }
      },

      /* Metricas de tiempo de respuesta NLB */
      {
        "type" : "metric"
        "width" : 6
        "height" : 6
        "properties" : {
          "metrics" : [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.external-nlb.arn],
          ]
          "period" : 300
          "stat" : "Sum"
          "region" : "us-east-1"
          "title" : "Tiempo de respuesta del NLB ${aws_lb.external-nlb.name}"
        }
      },

      /* Promedio de utilizacion de CPU de las instancias del ASG */
      {
        "type" : "metric",
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

      /* Metricas de trafico de red ASG */
      {
        "type" : "metric",
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

      /* Estado de salud de las instancias del ASG */
      {
        "type" : "metric"
        "width" : 6
        "height" : 6
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            ["AWS/EC2", "StatusCheckFailed_Instance", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            ["AWS/EC2", "StatusCheckFailed_System", "AutoScalingGroupName", aws_autoscaling_group.asg.name]
          ],
          "period" : 300
          "stat" : "Sum"
          "region" : "us-east-1"
          "title" : "Estado de salud de las instancias del ASG ${aws_autoscaling_group.asg.name}"
        }
      },

      /* Lectura/escritura en disco del ASG */
      {
        "type" : "metric",
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

      /* Uso de CPU de la instancia RDS */
      {
        "type" : "metric",
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

      /* Espacio libre en la instancia RDS */
      {
        "type" : "metric",
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

      /* Conexiones a la base de datos */
      {
        "type" : "metric",
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

      /* Peticiones en el ALB */
      {
        "type" : "metric",
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

      /* Tiempo de respuesta promedio del ALB */
      {
        "type" : "metric",
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

      /* Targets unhealthy del ALB */
      {
        "type" : "metric",
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

      /*  Metricas de trafico del NLB */
      {
        "type" : "metric",
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", aws_lb.external-nlb.dns_name],
            [".", "NewFlowCount", "LoadBalancer", aws_lb.external-nlb.dns_name],
            [".", "ProcessedBytes", "LoadBalancer", aws_lb.external-nlb.dns_name]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "us-east-1",
          "period" : 300,
          "title" : "Metricas de trafico del NLB ${aws_lb.external-nlb.dns_name}"
        }
      },

      /* Metricas de EBS */
      {
        "type" : "metric"
        "width" : 6
        "height" : 6
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "EBSReadOps", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            ["AWS/EC2", "EBSWriteOps", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            ["AWS/EC2", "EBSReadBytes", "AutoScalingGroupName", aws_autoscaling_group.asg.name],
            ["AWS/EC2", "EBSWriteBytes", "AutoScalingGroupName", aws_autoscaling_group.asg.name]
          ]
          "period" : 300
          "stat" : "Average"
          "region" : "us-east-1"
          "title" : "Metricas de EBS"
        }
      }
    ]
  })
}