variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
  version = "~> 2.0"
}

module "tgw-build" {
  source = "./modules/tgw-build"
  env = "test"
  vpc_cidr = "10.0.0.0/16"
  subnet_a = "10.0.0.0/17"
  subnet_c = "10.0.128.0/17"
  az1 = "${var.region}a"
  az2 = "${var.region}c"
  tgw_desc = "this is an example"
  tgw_name = "test_tgw"
  tgw_rt_name = "test_rt"
}
