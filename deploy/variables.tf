variable "prefix_identifier" {
  default = "cloudsoft-maeztro-tutorial"  // optionally replace with a prefix of your choice, possibly containing your name
}
variable "salt_override" {
  default = ""                            // replace to prevent random salt being inserted for uniqueness; if blank, a random identifier will be used
}

variable "aws_access_key_id" {
  default = "<your-aws-access-key>"       // replace with own access key
}
variable "aws_secret_access_key" {
  default = "<your-aws-secret-key>"       // replace with own access key
}
variable "aws_session_token" {
  default = ""                            // replace with session token if used
}

variable "region" {
  default = "eu-north-1"                  // optionally replace with desired region; if changing, change ami_id
}
variable "ami_id" {
  default = "ami-092cce4a19b438926"
}
variable "ec2_type" {
  default = "t3.small"
}
variable "vm_user" {
  default = "ubuntu"
}

variable "port" {
  default = "3000"
}
variable "data_table_basename" {
  default = "data-table"
}
