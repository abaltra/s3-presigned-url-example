resource "aws_s3_bucket" "bucket" {
  bucket = "s3-presigned-upload-example"
  acl    = "private"

  cors_rule {
    allowed_headers = ["Content-Type", "X-Amz-Server-Side-Encryption", "Accept"]
    allowed_methods = ["PUT", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
      {
          "Sid": "DenyIncorrectEncryptionHeader",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::s3-presigned-upload-example/*",
          "Condition": {
              "StringNotEquals": {
                  "s3:x-amz-server-side-encryption": "AES256"
              }
          }
      },
      {
          "Sid": "DenyUnEncryptedObjectUploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::s3-presigned-upload-example/*",
          "Condition": {
              "Null": {
                  "s3:x-amz-server-side-encryption": "true"
              }
          }
      }
  ]
}
EOF
}