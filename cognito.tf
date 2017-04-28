/*
  -----------------------------------
  | Cognito for GH Pages Hosted App |
  -----------------------------------
*/

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "OSHA ML Predict"
  allow_unauthenticated_identities = true
}
