data "aws_iam_policy_document" "ml_predictor_trust" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "ml_predictor" {
  name = "ml_predictor"

  assume_role_policy = data.aws_iam_policy_document.ml_predictor_trust.json
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
  alarm_actions     = [aws_sns_topic.default.arn]
}
