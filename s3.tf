
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

# Host website
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.nickvenky123_resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}


# Enable CloudFront
resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.hosting.website_endpoint
    origin_id   = aws_s3_bucket.nickvenky123_resume_bucket.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.nickvenky123_resume_bucket.bucket_regional_domain_name
  }
}


# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.nickvenky123_resume_bucket.bucket
}
