provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "default" {
  name        = "jenkind-ci-sg"
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

# jenkins server
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = var.instance_type
  key_name      = var.aws_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.default.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_server_profile.name

  user_data = <<-EOF
    #!/bin/bash
    # Install Docker
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    
    # Run Jenkins as Docker container
    sudo docker run -d \
      --name jenkins \
      -p 8080:8080 \
      -p 50000:50000 \
      -v jenkins_home:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --restart=unless-stopped \
      jenkins/jenkins:lts
    
    # Install Docker CLI in Jenkins container
    sudo docker exec jenkins sh -c "curl -fsSL https://get.docker.com | sh" || true
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
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name

  user_data = <<-EOF
    #!/bin/bash
    # Install Docker
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    
    # Install kubectl
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Install Java for Jenkins agent
    sudo yum install -y java-11-amazon-corretto
  EOF

  tags = {
    Name = "jenkins-agent"
  }
}

# Elastic IPs for each server
resource "aws_eip" "jenkins_server_eip" {
  instance = aws_instance.jenkins_server.id
}

resource "aws_eip" "jenkins_agent_eip" {
  instance = aws_instance.jenkins_agent.id
}

