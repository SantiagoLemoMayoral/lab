resource "aws_apigatewayv2_api" "api" {
  name          = "lab-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "name" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /objects"

  target = "integrations/${aws_apigatewayv2_integration.handler.id}"
}

resource "aws_apigatewayv2_integration" "name" {
  api_id = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.handle.invoque_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_stage" "name" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}