# 1. Fetch your Resource Group
data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

# 2. The VPC
resource "ibm_is_vpc" "vpc" {
  name           = "vpc-dallas-prod"
  resource_group = data.ibm_resource_group.rg.id
}

# 3. Public Gateway
resource "ibm_is_public_gateway" "pgw" {
  name           = "dallas-pub-gw"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "us-south-2"
  resource_group = data.ibm_resource_group.rg.id
}

# 4. The Subnet
resource "ibm_is_subnet" "subnet" {
  name            = "dallas-02-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "us-south-2"
  ipv4_cidr_block = "10.10.0.0/16"
  public_gateway  = ibm_is_public_gateway.pgw.id
  resource_group  = data.ibm_resource_group.rg.id
}

# 5. The Virtual Server Instance (VSI)
resource "ibm_is_instance" "vsi" {
  name    = "dallas-vsi-01"
  vpc     = ibm_is_vpc.vpc.id
  zone    = "us-south-2"
  keys    = [var.ssh_key_id] 
  profile = "cx2-2x4"
  image   = "r006-30e6297e-e9a1-4b26-8659-301a063c57ec" # Ubuntu 22.04 ID for Dallas

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
  }
}

# 6. VPN Gateway
resource "ibm_is_vpn_gateway" "vpn" {
  name           = "vpn-gw-dallas"
  subnet         = ibm_is_subnet.subnet.id
  mode           = "policy"
  resource_group = data.ibm_resource_group.rg.id
}
