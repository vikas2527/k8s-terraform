output "state_bucket_name" {
  description = "S3 bucket for Terraform remote state"
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.locks.name
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform remote state"
  value       = aws_s3_bucket.state.arn
}