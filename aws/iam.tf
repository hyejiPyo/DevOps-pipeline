# IAM Role for Jenkins Server
resource "aws_iam_role" "jenkins_server_role" {
  name = "jenkins-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "jenkins-server-role"
  }
}

# IAM Role for Jenkins Agent
resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "jenkins-agent-role"
  }
}

# IAM Policy for Jenkins Server
resource "aws_iam_role_policy" "jenkins_server_policy" {
  name = "jenkins-server-policy"
  role = aws_iam_role.jenkins_server_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM Policy for Jenkins Agent
resource "aws_iam_role_policy" "jenkins_agent_policy" {
  name = "jenkins-agent-policy"
  role = aws_iam_role.jenkins_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Instance Profile for Jenkins Server
resource "aws_iam_instance_profile" "jenkins_server_profile" {
  name = "jenkins-server-profile"
  role = aws_iam_role.jenkins_server_role.name
}

# Instance Profile for Jenkins Agent
resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}
