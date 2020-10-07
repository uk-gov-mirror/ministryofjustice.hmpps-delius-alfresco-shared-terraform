resource "aws_sns_topic" "chatbot" {
  name = "${local.common_name}-chatbot"
}

resource "aws_sns_topic_policy" "chatbot" {
  arn    = aws_sns_topic.chatbot.arn
  policy = data.aws_iam_policy_document.chatbot.json
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "codestar-notifications.amazonaws.com"
      ]
    }

    resources = [aws_sns_topic.chatbot.arn]
  }
}

resource "aws_iam_policy" "chatbot_iam_policy" {
  path        = "/"
  description = "chatbot-iam-policy"
  policy      = data.aws_iam_policy_document.chatbot_iam_policy_document.json
  name        = "chatbot-iam-policy"
}

data "aws_iam_policy_document" "chatbot_iam_policy_document" {
  statement {
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "chatbot_iam_role" {
  name = "chatbot-iam-role"

  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json
}

data "aws_iam_policy_document" "chatbot_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_iam_role_policy_attachment" {
  role       = aws_iam_role.chatbot_iam_role.id
  policy_arn = aws_iam_policy.chatbot_iam_policy.arn
}

module "chatbot" {
  source             = "../modules/chatbot"
  configuration_name = "alf-dev-alerts"
  iam_role_arn       = aws_iam_role.chatbot_iam_role.arn
  slack_channel_id   = "G01BVK3SPK5"
  slack_workspace_id = "T02DYEB3A"
  sns_topic_arns = [
    aws_sns_topic.chatbot.arn
  ]
}
