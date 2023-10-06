
resource "aws_instance" "node_server" {
  key_name      = aws_key_pair.node_server.key_name
  ami = var.ami_id
  instance_type = var.ec2_type

  vpc_security_group_ids = [
    aws_security_group.node_server.id
  ]

  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = tls_private_key.ssh_key.private_key_openssh
    host        = self.public_ip
    agent       = false   # can prevents some auth sock errors on mac; change if required in your env
  }

  # copy script files onto vm
  provisioner "file" {
    source      = "./scripts/"
    destination = "/tmp/"
  }
  # copy src files onto vm
  provisioner "file" {
    source      = "./src/"
    destination = "/tmp/"
  }

  # Execute script on remote vm after this creation
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*sh",
      "sudo /tmp/create.sh | tee /tmp/create.log",
      "sudo /tmp/configure.sh \"${var.port}\" \"${var.region}\" \"${var.aws_access_key_id}\" \"${var.aws_secret_access_key}\" \"${var.aws_session_token}\" \"${aws_dynamodb_table.data_table.name}\" | tee /tmp/configure.log",
      "sudo /tmp/start.sh \"${var.port}\" | tee /tmp/start.log",
      "echo ${self.public_ip}"
    ]
  }

  tags = {
    Name = "${local.prefix}/vm"
  }

  depends_on = [aws_dynamodb_table.data_table]
}

resource "aws_key_pair" "node_server" {
  key_name   = "${local.prefix}-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "${local.prefix}/ssh-key"
  }
}

resource "aws_security_group" "node_server" {
  name        = "${local.prefix}-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # backend
  ingress {
    description = "HTTP"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}/asg"
  }
}

# Provides an Elastic IP resource.
resource "aws_eip" "node_server" {
  domain      = "vpc"
  instance = aws_instance.node_server.id

  tags = {
    Name = "${local.prefix}/eip"
  }
}
