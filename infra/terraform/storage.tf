resource "aws_dynamodb_table" "metadata" {
  name         = "lab-metadata"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "object_id"

  attribute {
    name = "object_id"
    type = "S"
  }

}
