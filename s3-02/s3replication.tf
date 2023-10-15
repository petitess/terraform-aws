data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "s3-infra-${var.env}-01-replication"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.s3infra.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.s3infra.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.s3infrarep.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "s3-infra-${var.env}-01-iam-role-policy-replication"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3infra]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.s3infra.id

  rule {
    id = "s3-infra-${var.env}-01-replication"
    delete_marker_replication {
      status = "Disabled"
    }
    #Limit the scope of this rule using one or more filters
    filter {
      #Files that start with "file" are replicated
      prefix = "file"
      #prefix = null
    }

    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.s3infrarep.arn
      storage_class = "STANDARD"
    }
  }
}
