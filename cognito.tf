/*
  -----------------------------------
  | Cognito for GH Pages Hosted App |
  -----------------------------------
*/

resource "aws_cognito_identity_pool" "main" {
  provider                         = "aws.west"
  identity_pool_name               = "OSHA ML Predict"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.main.id}"

  roles {
    "authenticated"   = "arn:aws:iam::754135023419:role/Cognito_OSHAMLPredictAuth_Role"
    "unauthenticated" = "arn:aws:iam::754135023419:role/Cognito_OSHAMLPredictUnauth_Role"
  }
}
