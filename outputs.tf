output "s3_web_url" {
  description = "La URL pública del bucket"
  value       = aws_s3_bucket_website_configuration.web.website_endpoint
}

output "lambda_function_url" {
  value       = aws_lambda_function_url.my_lambda_url.function_url
  description = "La URL pública de la función Lambda"
}