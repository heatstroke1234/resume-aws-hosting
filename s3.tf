
# Create an S3 bucket
resource "aws_s3_bucket" "nickvenky123_resume_bucket" {
  bucket = "nickvenky123-resume-bucket"
}

# Enable versioning
resource "aws_s3_bucket_versioning" "nickvenky123_resume_bucket" {
  bucket = aws_s3_bucket.nickvenky123_resume_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "nickvenky123_resume_bucket" {
  bucket = aws_s3_bucket.nickvenky123_resume_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "nickvenky123_resume_bucket_access_block" {
  bucket = aws_s3_bucket.nickvenky123_resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "nickvenky123_resume_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.nickvenky123_resume_bucket_access_block]
  bucket     = aws_s3_bucket.nickvenky123_resume_bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.nickvenky123_resume_bucket.id}/*"
        }
      ]
    }
  )
}

/*

# Create an S3 bucket policy to restrict access to all principals in a given account
resource "aws_s3_bucket_policy" "nickvenky123_resume_bucket_policy" {
  bucket = aws_s3_bucket.nickvenky123_resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" } # Replace with your AWS account ID
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.nickvenky123_resume_bucket.arn}",
          "${aws_s3_bucket.nickvenky123_resume_bucket.arn}/*"
        ]
      }
    ]
  })
}
*/

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.nickvenky123_resume_bucket.bucket
}
