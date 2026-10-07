resource "aws_iam_openid_connect_provider" "tfc" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity"
  ]
}

data "aws_iam_policy_document" "tfc_trust" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.tfc.arn
      ]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"

      values = [
        "organization:my-org:project:my-project:workspace:lab:run_phase:*"
      ]
    }
  }
}