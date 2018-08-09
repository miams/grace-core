resource "aws_iam_user" "deployer" {
  name = "circle-deployer"
}

resource "aws_iam_user_policy_attachment" "deployer_attach" {
  user = "${aws_iam_user.deployer.name}"

  # AWS-managed policy
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_user_policy" "deployer_org" {
  name = "deployer_org"
  user = "${aws_iam_user.deployer.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "organizations:*",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:PutRolePolicy",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
