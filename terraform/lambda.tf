data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/../lambda/handler.py"
    output_path = "${path.module}/../lambda/lambda_function.zip"
}

resource "aws_lambda_function" "scheduler_lambda" {
  
  filename = data.archive_file.lambda_zip.output_path
  function_name = "ec2-workhour-scheduler"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "handler.lambda_handler"
  runtime = "python3.9"
  timeout = 60
  memory_size = 128

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = {
    Name = "ec2-scheduler-lambda"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {

    name = "/aws/lambda/${aws_lambda_function.scheduler_lambda.function_name}"
    retention_in_days = 7

    tags = {
      Name = "ec2-scheduler-logs"
      Environment = var.environment
    }
}