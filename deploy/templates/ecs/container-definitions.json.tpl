[
    {
        "name": "app",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 128,
        "environment": [
            {"name": "DJANGO_SECRET_KEY", "value": "${django_secret_key}"},
            {"name": "DB_HOST", "value": "${db_host}"},
            {"name": "DB_NAME", "value": "${db_name}"},
            {"name": "DB_USER", "value": "${db_user}"},
            {"name": "DB_PASS", "value": "${db_pass}"},
            {"name": "ALLOWED_HOSTS", "value": "${allowed_hosts}"},
            {"name": "API_KEY", "value": "${weather_api_key}"},
            {"name": "MAPS_KEY", "value": "${google_maps_key}"},
            {"name": "CORS_ALLOWED_ORIGINS", "value": "${django_cors_allowed_origins}"},
            {"name": "S3_STORAGE_BUCKET_NAME", "value": "${s3_storage_bucket_name}"},
            {"name": "S3_STORAGE_BUCKET_REGION", "value": "${s3_storage_bucket_region}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "server"
            }
        },
        "portMappings": [
            {
                "containerPort": 9000,
                "hostPort": 9000
            }
        ],
        "mountPoints": [
            {
                "readOnly": false,
                "containerPath": "/vol/web",
                "sourceVolume": "static"
            }
        ]
    },
    {
        "name": "proxy",
        "image": "${proxy_image}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000
            }
        ],
        "memoryReservation": 128,
        "environment": [
            {"name": "APP_HOST", "value": "127.0.0.1"},
            {"name": "APP_PORT", "value": "9000"},
            {"name": "LISTEN_PORT", "value": "8000"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "proxy"
            }
        },
        "mountPoints": [
            {
                "readOnly": true,
                "containerPath": "/vol/static",
                "sourceVolume": "static"
            }
        ]
    },
    {
        "name": "frontend",
        "image": "${frontend_image}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 4200
            }
        ],
        "memoryReservation": 256,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "frontend"
            }
        }
    }
]
