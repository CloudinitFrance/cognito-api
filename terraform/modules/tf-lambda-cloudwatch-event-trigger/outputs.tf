output "cloudwatch-event-rule-arn" {
  value = "${aws_cloudwatch_event_rule.cw-event-rule.arn}"
}
