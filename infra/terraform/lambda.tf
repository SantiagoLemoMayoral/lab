resource "aws_lambda_function" "handler" {
  function_name = "lab-handler"

  package_type = "Image"
  image_uri    = aws_ecr_repository.lab.repository_url
  role         = aws_iam_role.handler.arn

  memory_size = 512
  timeout     = 

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.lab.name
    }
  }
}

resource "aws_lambda_function" "object_worker" {
  function_name = "lab-object-worker"

  package_type = "Image"
  image_uri    = "..."
  role         = aws_iam_role.object_worker.arn

  memory_size = 1024
  timeout     = 30
}

resource "aws_lambda_event_source_mapping" "object_worker" {
  event_source_arn = aws_sqs_queue.object_queue.arn
  function_name    = aws_lambda_function.object_worker.arn

  batch_size                         = 10
  maximum_batching_window_in_seconds = 1

  scaling_config {
    maximum_concurrency = 20
  }
}