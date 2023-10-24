resource "aws_cloudwatch_event_rule" "cw-event-rule" {
  name                = "${var.cw-event-rule-name}"
  description         = "${var.cw-event-rule-description}"
  schedule_expression = "${var.cw-event-rule-schedule-expression}"
}

resource "aws_cloudwatch_event_target" "cw-event-target" {
  rule      = "${aws_cloudwatch_event_rule.cw-event-rule.name}"
  arn       = "${var.lambda-arn}"
}

resource "aws_lambda_permission" "allow-cloudwatch-call-to-lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda-function-name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cw-event-rule.arn}"
}
