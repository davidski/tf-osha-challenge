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

resource "aws_iam_role_policy_attachment" "lambda_worker_logs" {
  role       = "${aws_iam_role.lambda_worker.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_worker" {
  provider         = "aws.west"
  filename         = "osha_lambda_worker.zip"
  function_name    = "osha_lambda_worker"
  description      = "Shuts down realtime prediction endpoint in response to SNS delivered Cloudwatch Alarm"
  role             = "${aws_iam_role.lambda_worker.arn}"
  handler          = "main.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("osha_lambda_worker.zip"))}"
}

resource "aws_lambda_permission" "with_sns" {
  provider      = "aws.west"
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_worker.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.default.arn}"
}

resource "aws_sns_topic" "default" {
  name         = "osha-endpoint-status"
  display_name = "OSHA Realtime Prediction status messages"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.default.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda_worker.arn}"
}

output "lambda_role_arn" {
  value = "${aws_iam_role.lambda_worker.arn}"
}
