////////////////////////////////////////////////
/// Then apply these other 3 modules at once
///
/// `terraform apply -target=module.secret_store` -target=module.bucket` -target=module.rds`
///


// 4. Secret Store
//  - Apply module without secrets `var.secrets = {}`
//  - Encrypt secrets with the generated KMS key `./config.sh encrypt`
//  - Add secrets in `terraform.tfvars`
//  - Apply module with secrets in var.secrets
//  - Secrets will be created on SecretManager with `var.environment` as prefix (eg. `production-supabase-db`)
module "secret_store" {
  source = "../../modules/secret-store"

  name                 = var.secretstore_name
  environment          = var.environment
  secrets              = var.secrets
  external_secret_role = module.helm_base.external_secrets_role_arn
}

// 5. S3 Bucket for Supabase
// Since Supabase only accepts AccessKeys, we need to create a user with long-lived credentials
// https://supabase.com/docs/guides/database/extensions/wrappers/s3#connecting-to-s3
resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

resource "aws_iam_user" "s3" {
  name = "${var.environment}-s3-user"
  path = "/"
}

resource "aws_iam_user_policy_attachment" "iam_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  user       = aws_iam_user.s3.name
}

// Create Bucket Policy for IAM User FullAccess
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_user.s3.arn}"
        }
        Action = [
          "s3:*"
        ]
        Resource = [
          "${module.bucket.arn}/*",
          "${module.bucket.arn}"
        ]
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "s3" {
  name        = "${var.environment}-supabase-s3"
  description = "IAM User Keys for Supabase-S3"
}
resource "aws_secretsmanager_secret_version" "s3" {
  secret_id     = aws_secretsmanager_secret.s3.id
  secret_string = jsonencode({ "keyId" : aws_iam_access_key.s3.id, "accessKey" : aws_iam_access_key.s3.secret })
}

module "bucket" {
  source = "../../modules/s3_bucket"

  bucket_name      = var.bucket_name
  bucket_encrypted = var.bucket_encrypted
  bucket_versioned = var.bucket_versioned

}

// 6. RDS Database for Supabase
module "rds" {
  source = "../../modules/rds"

  identifier     = var.db_identifier
  instance_class = var.db_instance_class

  master_user     = var.db_master_user
  master_password = module.secret_store.decrypted_secrets["RDS_MASTER_PASSWORD"]

  engine         = var.db_engine
  engine_version = var.db_engine_version

  storage     = var.db_storage
  max_storage = var.db_max_storage

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  db_params = var.db_params
}
