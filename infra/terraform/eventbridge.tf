resource "aws_cloudwatch_event_bus" "lab" {
  name = "lab-events"
}

resource "aws_cloudwatch_event_rule" "object_created" {
  name           = "lab-object-created"
  event_bus_name = aws_cloudwatch_event_bus.lab.name

  event_pattern = jsonencode({
    source      = ["lab.api"]
    detail-type = ["object.created"]
  })
}

resource "aws_cloudwatch_event_target" "object_queue" {
  rule           = aws_cloudwatch_event_rule.object_created.name
  event_bus_name = aws_cloudwatch_event_bus.lab.name

  target_id = "object-queue"
  arn       = aws_sqs_queue.object_queue.arn
}

resource "aws_sqs_queue_policy" "allow_eventbridge" {
  queue_url = aws_sqs_queue.object_queue.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "events.amazonaws.com"
      }

      Action = "sqs:SendMessage"

      Resource = aws_sqs_queue.object_queue.arn

      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.object_created.arn
        }
      }
    }]
  })
}

