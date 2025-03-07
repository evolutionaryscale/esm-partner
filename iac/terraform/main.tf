# These data sources provide information about the environment this
# terraform is running in -- it's how we can know which account, region,
# and partition (ie, commercial AWS vs GovCloud) we're in.

data "aws_caller_identity" "current" {}
