resource "aws_instance" "vm" {
  ami = "ami-005ee9e4d4fd438eb"
  tags = merge(var.tags, {
    Name = "vmwebdev03"
  })
  instance_type               = "t3.micro"
  availability_zone           = aws_subnet.web.availability_zone
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.web.id
  private_ip                  = "10.10.1.11"
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = local_file.vm.filename
  user_data                   = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOF
}

resource "aws_key_pair" "vm" {
  key_name   = "vm-key-pair"
  public_key = tls_private_key.vm.public_key_openssh
}
resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "vm" {
  content  = tls_private_key.vm.private_key_pem
  filename = aws_key_pair.vm.key_name
}
