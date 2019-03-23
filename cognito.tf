/*
  -----------------------------------
  | Cognito for GH Pages Hosted App |
  -----------------------------------
*/

resource "aws_cognito_identity_pool" "main" {
  provider                         = "aws.west"
  identity_pool_name               = "OSHA ML Predict"
  allow_unauthenticated_identities = true
  version = "~> 1.54"
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  provider         = "aws.west"
  identity_pool_id = "${aws_cognito_identity_pool.main.id}"

  roles {
    "authenticated"   = "${aws_iam_role.authenticated.arn}"
    "unauthenticated" = "${aws_iam_role.unauthenticated.arn}"
  }
}

resource "aws_iam_role" "unauthenticated" {
  name_prefix        = "OSHA_ML_Unauthenticated_Cognito"
  description        = "OSHA ML Cognito Unauthenticated Users"
  assume_role_policy = "${data.aws_iam_policy_document.unauthenticated_trust.json}"
}

resource "aws_iam_role_policy_attachment" "oshaml_ml_readonly" {
  role       = "${aws_iam_role.unauthenticated.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "oshaml_ml_realtimepredicitons" {
  role       = "${aws_iam_role.unauthenticated.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningRealTimePredictionOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "oshaml_ml_managerealtimeendpoints" {
  role       = "${aws_iam_role.unauthenticated.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonMachineLearningManageRealTimeEndpointOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "oshaml_authenticated_attachment" {
  role       = "${aws_iam_role.authenticated.name}"
  policy_arn = "${aws_iam_policy.authenticated_policy.arn}"
}

resource "aws_iam_role" "authenticated" {
  name_prefix        = "OSHA_ML_Authenticated_Cognito"
  description        = "OSHA ML Cognito Authenticated Users"
  assume_role_policy = "${data.aws_iam_policy_document.authenticated_trust.json}"
}

resource "aws_iam_policy" "unauthenticated_policy" {
  name_prefix = "OSHA_ML_Unathenticated"
  path        = "/"
  description = "OSHA ML Unauthenticated Users Access Permissions"
  policy      = "${data.aws_iam_policy_document.unauthenticated_policy.json}"
}

resource "aws_iam_policy" "authenticated_policy" {
  name_prefix = "OSHA_ML_Authenticated"
  path        = "/"
  description = "Permit OSHA ML web app to do ML predicitions via unauthenticated Cogntio calls"
  policy      = "${data.aws_iam_policy_document.authenticated_policy.json}"
}

data "aws_iam_policy_document" "unauthenticated_policy" {
  statement {
    sid = "1"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "authenticated_policy" {
  statement {
    sid = "1"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "unauthenticated_trust" {
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
      values   = ["${aws_cognito_identity_pool.main.id}"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

data "aws_iam_policy_document" "authenticated_trust" {
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
      values   = ["${aws_cognito_identity_pool.main.id}"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}
