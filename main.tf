##############################################################################
# 1. Resource Group Data Lookup
##############################################################################
data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

##############################################################################
# 2. VPC Creation
##############################################################################
resource "ibm_is_vpc" "vpc" {
  name           = "vpc-dallas-prod"
  resource_group = data.ibm_resource_group.rg.id
  # We set this to false to allow us to define our own custom address prefixes
  address_prefix_management = "manual" 
}

##############################################################################
# 3. Address Prefix (The "Floor Plan" for your IPs)
##############################################################################
resource "ibm_is_vpc_address_prefix" "prefix" {
  name = "dallas-prefix-02"
  zone = "us-south-2"
  vpc  = ibm_is_vpc.vpc.id
  cidr = "10.10.0.0/16"
}

##############################################################################
# 4. Public Gateway (Internet Access for the VSI)
##############################################################################
resource "ibm_is_public_gateway" "pgw" {
  name           = "dallas-pub-gw"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "us-south-2"
  resource_group = data.ibm_resource_group.rg.id
}

##############################################################################
# 5. Subnet (The "Room" for your VSI)
##############################################################################
resource "ibm_is_subnet" "subnet" {
  name            = "dallas-02-subnet"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "us-south-2"
  ipv4_cidr_block = "10.10.0.0/16"
  public_gateway  = ibm_is_public_gateway.pgw.id
  resource_group  = data.ibm_resource_group.rg.id

  # This ensures the Prefix is created before the Subnet tries to use it
  depends_on = [ibm_is_vpc_address_prefix.prefix]
}

##############################################################################
# 6. Virtual Server Instance (VSI)
##############################################################################
resource "ibm_is_instance" "vsi" {
  name    = "dallas-vsi-01"
  vpc     = ibm_is_vpc.vpc.id
  zone    = "us-south-2"
  keys    = [var.ssh_key_id] 
  profile = "cx2-2x4"
  image   = "r006-30e6297e-e9a1-4b26-8659-301a063c57ec" # Ubuntu 22.04 Dallas

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
  }
}

##############################################################################
# 7. VPN Gateway (Site-to-Site)
##############################################################################
resource "ibm_is_vpn_gateway" "vpn" {
  name           = "vpn-gw-dallas"
  subnet         = ibm_is_subnet.subnet.id
  mode           = "policy"
  resource_group = data.ibm_resource_group.rg.id
}
