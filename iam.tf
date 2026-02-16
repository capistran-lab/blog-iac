resource "aws_iam_role" "auth_lambda_role" {
  name = "${var.project_name}-auth-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.auth_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "cognito_access" {
  name = "${var.project_name}-cognito-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cognito-idp:AdminGetUser",
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminUpdateUserAttributes",
        "cognito-idp:AdminSetUserPassword"
      ]
      Resource = aws_cognito_user_pool.pool.arn
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach_cognito" {
  role       = aws_iam_role.auth_lambda_role.name
  policy_arn = aws_iam_policy.cognito_access.arn

}
