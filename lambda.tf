resource "aws_iam_role" "lambda_worker" {
  name_prefix = "osha_lambda_worker"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_worker" {
  role       = "${aws_iam_role.lambda_worker.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
}

output "lambda_role_arn" {
  value = "${aws_iam_role.lambda_worker.arn}"
}
