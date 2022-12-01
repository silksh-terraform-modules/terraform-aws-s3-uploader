resource "aws_iam_user" "s3_cf_apps_uploader" {
  name = "s3_cf_apps_uploader_${var.env_scope}"
  tags = {
    description = "user with permissions to upload static apps to appropriate s3 buckets"
  }
}

resource "aws_iam_access_key" "s3_cf_apps_uploader" {
  user = aws_iam_user.s3_cf_apps_uploader.name
}

resource "aws_iam_policy_attachment" "s3_cf_apps_uploader" {
  name       = "s3_cf_apps_uploader"
  users      = [aws_iam_user.s3_cf_apps_uploader.name]
  policy_arn = aws_iam_policy.s3_cf_apps_upload.arn
}

locals {
  buckets_json = jsonencode(formatlist("%s/*", var.tlds.*.bucket))
}

resource "aws_iam_policy" "s3_cf_apps_upload" {
  name = "s3_cf_apps_upload_${var.env_scope}"

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": ${local.buckets_json}
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": ${local.buckets_json}
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*",
            "Condition": {}
        }
    ]
}
DOC
}

resource "local_file" "gitlab-environment" {
  for_each = {for x in var.tlds: x.domain => x}

  content  = templatefile("${path.module}/templates/environment.json", {
    env_scope                 = "${var.env_scope}"
    access_key                = aws_iam_access_key.s3_cf_apps_uploader.id
    secret_key                = aws_iam_access_key.s3_cf_apps_uploader.secret
    app_domain_name           = "${each.value.domain}"
    app_bucket                = "${each.value.bucket}"
  })
    filename = "${path.root}/.terraform/${each.key}-gitlab-environment-${var.env_scope}.json"
}