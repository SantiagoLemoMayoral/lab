data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}



data "aws_iam_policy_document" "lab_app_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::lab-app-data/*"
    ]
  }
}

resource "aws_iam_policy" "lab_app" {
  name   = "lab-app-policy"
  policy = data.aws_iam_policy_document.lab_app_permissions.json
}

data "aws_iam_policy_document" "lab_app_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_eks_cluster.main.identity[0].oidc[0].issuer,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:default:lab-app"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_eks_cluster.main.identity[0].oidc[0].issuer,
        "https://",
        ""
      )}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lab_app" {
  name               = "lab-app-role"
  assume_role_policy = data.aws_iam_policy_document.lab_app_trust.json
}

resource "aws_iam_role_policy_attachment" "lab_app" {
  role       = aws_iam_role.lab_app.name
  policy_arn = aws_iam_policy.lab_app.arn
}