# Create an S3 bucket
resource "aws_s3_bucket" "my_secure_bucket" {
  bucket = "my-secure-bucket-name" # Change to your desired bucket name
  acl    = "private"

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable default encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Create an S3 bucket policy to restrict access to all principals in a given account
resource "aws_s3_bucket_policy" "my_secure_bucket_policy" {
  bucket = aws_s3_bucket.my_secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" } # Replace with your AWS account ID
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.my_secure_bucket.arn}",
          "${aws_s3_bucket.my_secure_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.my_secure_bucket.bucket
}
