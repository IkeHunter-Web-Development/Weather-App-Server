resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving of images and adding logs."
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-server-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-server"

  tags = local.common_tags
}

data "template_file" "server_container_definitions" {
  template = file("./templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image                   = var.ecr_image_server
    proxy_image                 = var.ecr_image_proxy
    django_secret_key           = var.django_secret_key
    db_host                     = aws_db_instance.main.address
    db_name                     = aws_db_instance.main.name
    db_user                     = aws_db_instance.main.username
    db_pass                     = aws_db_instance.main.password
    log_group_name              = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region            = data.aws_region.current.name
    allowed_hosts               = aws_lb.server.dns_name,
    weather_api_key             = var.weather_api_key
    google_maps_key             = var.google_maps_key
    django_cors_allowed_origins = var.django_cors_allowed_origins
  }
}

resource "aws_ecs_task_definition" "server" {
  family                   = "${local.prefix}-server"
  container_definitions    = data.template_file.server_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn

  volume {
    name = "static"
  }

  tags = local.common_tags
}

resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block
    ]
  }

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "server" {
  name            = "${local.prefix}-server"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.server.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    security_groups = [aws_security_group.ecs_service.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.server.arn
    container_name   = "proxy"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.server]

}
