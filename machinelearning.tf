resource "aws_iam_role" "ml_predictor" {
  name = "ml_predictor"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Condition": {
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ml_predictor_manageendpoint" {
  role       = aws_iam_role.ml_predictor.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ml_predictor_make_predictions" {
  role       = aws_iam_role.ml_predictor.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningRealTimePredictionOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ml_predictor_describe_models" {
  role       = aws_iam_role.ml_predictor.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningReadOnlyAccess"
}

resource "aws_cloudwatch_metric_alarm" "default" {
  alarm_name          = "osha-ml-prediction-usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "45"
  metric_name         = "PredictCount"
  namespace           = "AWS/ML"

  dimensions = {
    MLModelId   = var.model_id
    RequestMode = "RealTimePredictions"
  }

  period            = "60"
  statistic         = "Maximum"
  threshold         = "0"
  alarm_description = "Monitors OSHA ML realtime prediction rates"
  alarm_actions     = ["${aws_sns_topic.default.arn}"]
}
