variable "base_url" {}
variable "name" {}

resource "aws_api_gateway_rest_api" "ApiGateway" {
  name     = var.name
}

resource "aws_api_gateway_resource" "ApiProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiGateway.id
  parent_id   = aws_api_gateway_rest_api.ApiGateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_integration" "ApiProxyIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiGateway.id
  resource_id             = aws_api_gateway_resource.ApiProxyResource.id
  http_method             = aws_api_gateway_method.ApiProxyMethod.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = format("%s/{proxy}", var.base_url)
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    //    "integration.request.header.X-Some-Other-Header" = "method.request.header.X-Some-Header"
    //    "integration.request.header.X-Authorization" = "'static'"
  }
  cache_key_parameters = [
    "method.request.path.proxy",
  ]
}

resource "aws_api_gateway_method" "ApiProxyMethod" {
  rest_api_id        = aws_api_gateway_rest_api.ApiGateway.id
  resource_id        = aws_api_gateway_resource.ApiProxyResource.id
  http_method        = "ANY"
  request_parameters = { "method.request.path.proxy" = true }
  authorization      = "NONE"
}

resource "aws_api_gateway_deployment" "ApiDeployment" {
  depends_on  = [aws_api_gateway_method.ApiProxyMethod, aws_api_gateway_integration.ApiProxyIntegration, aws_api_gateway_method_response.response_200]
  rest_api_id = aws_api_gateway_rest_api.ApiGateway.id
  stage_name  = "main"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.ApiGateway.id
  resource_id = aws_api_gateway_resource.ApiProxyResource.id
  http_method = aws_api_gateway_method.ApiProxyMethod.http_method
  status_code = "200"
}

output "invoke_url" {
  value = aws_api_gateway_deployment.ApiDeployment.invoke_url
}
