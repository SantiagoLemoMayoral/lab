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

resource "aws_iam_role" "tfc" {
  name = "terraform-cloud-role"

  assume_role_policy =
    data.aws_iam_policy_document.tfc_trust.json
}

data "aws_iam_policy_document" "tfc_permissions" {

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::lab-bucket/*"
    ]
  }
}

resource "aws_iam_policy" "tfc" {
  name = "terraform-cloud-permissions"

  policy =
    data.aws_iam_policy_document.tfc_permissions.json
}

resource "aws_iam_role_policy_attachment" "tfc" {

  role =
    aws_iam_role.tfc.name

  policy_arn =
    aws_iam_policy.tfc.arn
}
