# 1. START schedule - Weekdays 8:00 AM
resource "aws_scheduler_schedule" "start_schedule" {
  name       = "ec2-start-schedule"
  group_name = "default"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression_timezone = "Asia/Colombo"
  schedule_expression = "cron(0 8 ? * MON-FRI *)"
  
  target {
    arn      = aws_lambda_function.scheduler_lambda.arn
    role_arn = aws_iam_role.scheduler_execution_role.arn
    
    input = jsonencode({
      action = "start"
    })
  }
}

# 2. STOP schedule - Weekdays 7:00 PM
resource "aws_scheduler_schedule" "stop_schedule" {
  name       = "ec2-stop-schedule"
  group_name = "default"
  
  flexible_time_window {
    mode = "OFF"
  }
  
  schedule_expression_timezone = "Asia/Colombo"
  schedule_expression = "cron(0 19 ? * MON-FRI *)"
  
  target {
    arn      = aws_lambda_function.scheduler_lambda.arn
    role_arn = aws_iam_role.scheduler_execution_role.arn
    
    input = jsonencode({
      action = "stop"
    })
  }
}

# 3. Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  count         = 2
  statement_id  = "AllowExecutionFromEventBridge-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_lambda.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = count.index == 0 ? aws_scheduler_schedule.start_schedule.arn : aws_scheduler_schedule.stop_schedule.arn
}