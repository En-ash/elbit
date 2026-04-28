# General Configurations
locals {
  env_name = "${var.env}-"
}

# Setup Configurations
locals {
  region_name      = "${var.region_name}"
  eks_name    = "${var.env}-eks"
  eks_version = "${var.eks_version}"
  
  zone1 = "${var.zone1}"
  zone2 = "${var.zone2}"
}

