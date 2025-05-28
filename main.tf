# Crea el bucket
resource "aws_s3_bucket" "web" {
  bucket = var.bucket_name

  tags = {
    demo = "charlasCV"
  }

}

# Deshabilita las restricciones de acceso público para el bucket
resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Activa el hosting web para el bucket
resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

# Crea una política de bucket que permita el acceso público
resource "aws_s3_bucket_policy" "bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.web]
  bucket     = aws_s3_bucket.web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.web.arn}/*"
      },
    ]
  })
}

# Sube el index.html al bucket
resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.web.id
  key          = "index.html"
  source       = "web/index_lambda.html" # CHANGE THE INDEX FILE
  content_type = "text/html"
}



# Crear el rol de ejecución para la Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name =  "${var.lambda_name}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# Adjuntar la política de permisos para la Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Código de la función Lambda en un archivo zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_code"
  output_path = "lambda.zip"
}

# Crear la función Lambda
resource "aws_lambda_function" "my_lambda" {
  function_name    = "my_public_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  memory_size      = 128
  timeout          = 10
  tags = {
    demo = "charlasCV"
  }
}

# Crear la URL pública para la Lambda
resource "aws_lambda_function_url" "my_lambda_url" {
  function_name      = aws_lambda_function.my_lambda.function_name
  authorization_type = "NONE"

  # Permitir peticiones CORS
  cors {
    allow_origins = ["*"]
    allow_methods = ["GET"]
  }
}

# Configurar la política de permisos para hacer la Lambda accesible públicamente
resource "aws_lambda_permission" "allow_public_access" {
  statement_id           = "AllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.my_lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

