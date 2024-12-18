output "s3_uploader_id" {
  value = aws_iam_access_key.s3_cf_apps_uploader.id
}

output "s3_uploader_secret" {
  value = aws_iam_access_key.s3_cf_apps_uploader.secret
  sensitive   = true
}

output "s3_uploader_arn" {
  value = aws_iam_user.s3_cf_apps_uploader.arn
}
