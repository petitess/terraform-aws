terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0"
      #version = "~= 4.50"  for production
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_launch_template" "infra" {
  name          = "linux2"
  tags          = var.tags
  image_id      = "ami-0ebc18b0c418b543b"
  instance_type = "t3.micro"

}

resource "aws_autoscaling_group" "infra" {
  name = "asg-cluster-01"
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  min_size = 0
  max_size = 3
  launch_template {
    id      = aws_launch_template.infra.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.web.id]
}

resource "aws_ecs_capacity_provider" "infra" {
  name = "ec2-capacity"
  tags = var.tags
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.infra.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 3
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster" "infra" {
  name = "ecs-cluster-01"
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "infra" {
  cluster_name       = aws_ecs_cluster.infra.name
  capacity_providers = ["FARGATE", aws_ecs_capacity_provider.infra.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
