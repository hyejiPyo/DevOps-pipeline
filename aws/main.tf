provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "default" {
  name        = "jenkind-cd-sg"
  description = "jenkins-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 43
    to_port     = 43
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# jenkins server(CD)
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = var.instance_type
  key_name      = var.aws_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}

# jenkins agent server
resource "aws_instance" "jenkins_agent" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = var.instance_type
  key_name      = var.aws_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
  EOF

  tags = {
    Name = "jenkins-agent"
  }
}

# prometheus server
resource "aws_instance" "prometheus" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = var.instance_type
  key_name      = var.aws_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y prometheus
    sudo systemctl enable prometheus
    sudo systemctl start prometheus
  EOF

  tags = {
    Name = "prometheus-server"
  }
}

