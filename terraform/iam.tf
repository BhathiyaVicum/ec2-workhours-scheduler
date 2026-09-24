# IAM policy for lambda
resource "aws_iam_policy" "lambda_policy" {
    name = "lambda-ec2-start-stop-policy"

    policy = jsonencode (
        {
        Version= "2012-10-17",
        Statement= [
            {
            Sid= "Statement1",
            Effect= "Allow",
            Action= [
                "ec2:DescribeInstances",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            Resource= "*"
            }
        ]
        }
    )
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "ec2-manage-role"

  assume_role_policy = jsonencode(
    {
        Version= "2012-10-17",
        Statement= [
            {
            Effect= "Allow",
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Action= "sts:AssumeRole"
            }
        ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    role = aws_iam_role.lambda_execution_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "scheduler_lambda_invoke_policy" {
    name = "evevntbridge-scheduler-policy"

    policy = jsonencode(
        {
            Version= "2012-10-17",
            Statement= [
                {
                Sid= "Statement1",
                Effect= "Allow",
                Action= [
                    "lambda:InvokeFunction"
                ],
                Resource= "*"
                }
            ]
        }
    )
}

resource "aws_iam_role" "scheduler_execution_role" {

    name = "lambda-control-policy"

    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17",
            Statement = [
                {
                Effect = "Allow",
                Principal = {
                    Service = "scheduler.amazonaws.com"
                }
                Action = "sts:AssumeRole"
                }
            ]
        }
    )
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attachment" {
    role       = aws_iam_role.scheduler_execution_role.name
    policy_arn = aws_iam_policy.scheduler_lambda_invoke_policy.arn
}
