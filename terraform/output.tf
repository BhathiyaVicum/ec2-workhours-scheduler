output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.controling_app[*].id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.scheduler_lambda.function_name
}

output "start_schedule_arn" {
  description = "ARN of the start schedule"
  value       = aws_scheduler_schedule.start_schedule.arn
}

output "stop_schedule_arn" {
  description = "ARN of the stop schedule"
  value       = aws_scheduler_schedule.stop_schedule.arn
}