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
  role       = "${aws_iam_role.ml_predictor.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ml_predictor_make_predictions" {
  role       = "${aws_iam_role.ml_predictor.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningRealTimePredictionOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ml_predictor_describe_models" {
  role       = "${aws_iam_role.ml_predictor.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningReadOnlyAccess"
}
