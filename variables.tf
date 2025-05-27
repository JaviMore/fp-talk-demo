variable "bucket_name" {
  type        = string
  default     = "s3-fp-talk"
  description = "The name of the bucket"
}


variable "lambda_name" {
  type        = string
  default     = "lambda-fp-talk"
  description = "The name of the lambda"
}
