data "aws_iam_policy_document" "ml_predictor" {
  statement {
    sid = "MakeMLpredictions"
    actions = [
      "machinelearning:Predict",
    ]

    resources = [
      "arn:aws:machinelearning:::mlmodel/*"
    ]
  }
}

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

resource "aws_iam_role_policy" "ml_predictor" {
  name   = "ml_predictor"
  role   = "${aws_iam_role.ml_predictor.id}"
  policy = "${data.aws_iam_policy_document.ml_predictor.json}"
}