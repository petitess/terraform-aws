
resource "aws_vpc" "hub" {
  cidr_block = "10.10.0.0/20"
  tags = merge(var.tags, {
    Name = "vpc-${var.prefix}-01"
  })
}

resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id
  tags = merge(var.tags, {
    Name = "igw-${aws_vpc.hub.tags.Name}"
  })
}

resource "aws_route_table" "hub" {
  vpc_id = aws_vpc.hub.id
  tags = merge(var.tags, {
    Name = "rt-${aws_vpc.hub.tags.Name}"
  })
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub.id
  }
}

resource "aws_route_table_association" "mgmt" {
  route_table_id = aws_route_table.hub.id
  subnet_id = aws_subnet.mgmt.id
}

resource "aws_route_table_association" "web" {
  route_table_id = aws_route_table.hub.id
  subnet_id = aws_subnet.web.id
}

resource "aws_subnet" "mgmt" {
  vpc_id     = aws_vpc.hub.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "eu-north-1c"
  tags = merge(var.tags, {
    Name = "snet-${var.prefix}-mgmt"
  })
}

resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.hub.id
  availability_zone = "eu-north-1b"
  cidr_block = "10.10.1.0/24"
  tags = merge(var.tags, {
    Name = "snet-${var.prefix}-web"
  })
}

resource "aws_security_group" "mgmt" {
  vpc_id = aws_vpc.hub.id
  name   = "nsg-${var.prefix}-mgmt"
  tags = merge(var.tags, {
    Name = "nsg-${var.prefix}-mgmt"
  })
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow internet"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "All"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

resource "aws_security_group" "web" {
  vpc_id = aws_vpc.hub.id
  name   = "nsg-${var.prefix}-web"
  tags = merge(var.tags, {
    Name = "nsg-${var.prefix}-web"
  })
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow Http"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "Tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow RDP"
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "Tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow SSH"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "Tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow internet"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "All"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}