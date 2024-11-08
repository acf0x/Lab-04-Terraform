/*=========================================
=               ElastiCache               =
=========================================*/

/* Subnet group para ElastiCache 
   Define las subredes donde estara ElastiCache */

resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
  name       = "elasticache-subnet-group-lab04"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  tags = {
    Name          = "elasticache-subnet-group-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "elasticache"
  }
}

/* Crear Memcached cluster 
   Cluster para almacenamiento de cache de sesiones */

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "memcached-lab04"
  engine               = "memcached"
  node_type            = var.cache-type
  num_cache_nodes      = var.num-cache-nodes-memcached # Numero de nodos de cache
  parameter_group_name = "default.memcached1.6"        # Grupo de parametros para Memcached
  port                 = 11211                         # Puerto estandar para Memcached
  subnet_group_name    = aws_elasticache_subnet_group.elasticache-subnet-group.name
  security_group_ids   = [aws_security_group.memcached-sg.id] # Grupo de seguridad

  tags = {
    Name          = "memcached-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "elasticache"
  }
}

/* Crear cluster Redis con HA y failover automatico 
   Cache con alta disponibilidad y failover automatico */

resource "aws_elasticache_replication_group" "redis" {
  description                = "Cluster de Redis para cache general con HA"
  replication_group_id       = "redis"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = var.num-cache-clusters-redis
  multi_az_enabled           = true # Multi-AZ activado
  automatic_failover_enabled = true # Failover automatico
  port                       = 6379 # Puerto estandar para Redis
  security_group_ids         = [aws_security_group.redis-sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.elasticache-subnet-group.name

  tags = {
    Name          = "redis-lab04"
    env           = "lab04"
    owner         = "alvarocf"
    resource-type = "elasticache"
  }
}