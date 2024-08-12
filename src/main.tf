terraform {
  cloud {
    organization = "TED_EVAL"
    workspaces {
      project = "Nakabayashi-Project"
      name = "terraform-aws-cicd-demo"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --------------------------------------------------------------
# VPC
# --------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = "192.168.0.0/16" # IPv4 CIDR ブロック
  instance_tenancy                 = "default"        # テナンシー。EC2 インスタンスが物理ハードウェアに分散される方法を定義。料金に影響。defaultは他アカウントと共有利用、hostは専有の設定。
  enable_dns_support               = true             # DNS解決(bool)
  enable_dns_hostnames             = true             # DNSホスト名(bool)
  assign_generated_ipv6_cidr_block = false            # IPv6 CIDR ブロック

  tags = {
    Name    = "${var.project}-${var.enviroment}-vpc"
    project = var.project
    Env     = var.enviroment
  }
}

# --------------------------------------------------------------
# Subnet  パブリック、プライベート用にそれぞれ2つずつ構築
# --------------------------------------------------------------
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id    # リソースの参照(上記VPC)
  availability_zone       = "ap-northeast-1a" # アベイラビリティーゾーン
  cidr_block              = "192.168.1.0/24"  # CIDRブロック
  map_public_ip_on_launch = true              # 自動割り当てIP設定

  tags = {
    Name    = "${var.project}-${var.enviroment}-public_subnet_1a"
    project = var.project
    Env     = var.enviroment
    Tpye    = "public"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.enviroment}-public_subnet_1c"
    project = var.project
    Env     = var.enviroment
    Tpye    = "public"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "192.168.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.enviroment}-private_subnet_1a"
    project = var.project
    Env     = var.enviroment
    Tpye    = "private"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-${var.enviroment}-private_subnet_1c"
    project = var.project
    Env     = var.enviroment
    Tpye    = "private"
  }
}

# --------------------------------------------------------------
# Route Table
# --------------------------------------------------------------
# public
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.enviroment}-public_route_table"
    project = var.project
    Env     = var.enviroment
    Tpye    = "private"
  }
}

resource "aws_route_table_association" "public_route_table_1a" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

resource "aws_route_table_association" "public_route_table_1c" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1c.id
}

# private
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.enviroment}-private_route_table"
    project = var.project
    Env     = var.enviroment
    Tpye    = "private"
  }
}

resource "aws_route_table_association" "private_route_table_1a" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1a.id
}

resource "aws_route_table_association" "private_route_table_1c" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1c.id
}