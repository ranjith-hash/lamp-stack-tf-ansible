locals {

  rg = "${var.project_name}-rg"
  vnet = "${var.project_name}-vnet"
  subnet_1 = "${var.project_name}-subnet1"

  env = var.environment
  managed_by = "terraform"

  common_tags = {
    env = local.env
    managed_by = local.managed_by
  }

}