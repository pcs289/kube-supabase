locals {
  queue_name = "${aws_eks_cluster.main.name}-karpenter"
  events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

resource "aws_sqs_queue" "this" {
  name                      = local.queue_name
  message_retention_seconds = 300
}

data "aws_iam_policy_document" "queue" {
  statement {
    sid       = "SQSWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.queue.json
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v }

  name_prefix   = "Karpenter${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    { "ClusterName" : var.cluster_name },
  )
}
