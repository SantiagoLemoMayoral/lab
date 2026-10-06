resource "aws_sqs_queue" "object_dlq1" {
  name = "lab-object-dlq"
}

resource "aws_sqs_queue" "object_queue1" {
  name = "lab-object-queue"

  visibility_timeout_seconds = 45
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20
}

resource "aws_sqs_queue_redrive_policy" "object" {
  queue_url = aws_sqs_queue.object_queue.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.object_dlq.arn
    maxReceiveCount     = 5
  })
}