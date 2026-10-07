resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:SantiagoLemoMayoral/lab:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy =
    data.aws_iam_policy_document.github_assume_role.json
}

data "aws_iam_policy_document" "github_permissions" {
  statement {
    actions = [
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:CompleteLayerUpload"
    ]

    resources = [
      aws_ecr_repository.lab.arn
    ]
  }
}

resource "aws_iam_policy" "github_actions" {
  policy =
    data.aws_iam_policy_document.github_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

resource "aws_ecr_repository" "lab" {
  name = "lab"
}