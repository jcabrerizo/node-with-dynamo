
resource "aws_dynamodb_table" "data_table" {
  name = "${local.prefix}-${var.data_table_basename}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "HASH_KEY"
  range_key = "SORT_KEY"

  attribute {
    name = "HASH_KEY"
    type = "S"
  }

  attribute {
    name = "SORT_KEY"
    type = "N"
  }

  tags = {
    Name = "${local.prefix}/dynamo"
  }
}

resource aws_dynamodb_table_item "data_table_item" {
  count = 3
  table_name = aws_dynamodb_table.data_table.name
  hash_key = aws_dynamodb_table.data_table.hash_key
  range_key = aws_dynamodb_table.data_table.range_key

  item = jsonencode(
    {
      (aws_dynamodb_table.data_table.hash_key) : {
        "S": tostring(local.prefix)
      },
      (aws_dynamodb_table.data_table.range_key) : {
        "N": tostring(format("%d",count.index + 1))
      },
      "DATA" : {
        "S": tostring(format(" ${local.prefix} data %06d ", count.index + 1))
      },
    })

  depends_on = [aws_dynamodb_table.data_table]
}

resource aws_iam_policy "data_table_policy" {
  name = "${local.prefix}-${var.data_table_basename}-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "AccessDataTable",
        "Effect": "Allow",
        "Action": [
          "dynamodb:List*",
          "dynamodb:BatchGet*",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:ConditionCheckItem",
        ],
        "Resource": [aws_dynamodb_table.data_table.arn,]
      }
    ],
  })

  tags = {
    Name = "${local.prefix}/policy"
  }
}
