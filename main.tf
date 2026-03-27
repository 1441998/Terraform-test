# 1. Fetch your Resource Group
data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

# 2. The VPC (The "Container" for everything)
resource "ibm_is_vpc" "vpc" {
  name           = "vpc-dallas-prod"
  resource_group = 7d27d607ac0a4e759279c822d746399f
}

# 3. Public Gateway (Allows your VSI to talk to the internet/updates)
resource "ibm_is_public_gateway" "pgw" {
  name = "tokyo-pub-gw"
  vpc  = ibm_is_vpc.vpc.id
  zone = "jp-tok-2"
  resource_group = data.ibm_resource_group.rg.id
}

# 4. The Subnet (Tokyo-02 from your diagram)
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
  keys    = [r006-fb7d06f3-039f-4753-a34a-0c5870c2e0f5] # CHANGE THIS: You need an SSH Key in IBM Cloud
  profile = "cx2-2x4"        # This is the "Size" (2 vCPU, 4GB RAM)
  image   = "r006-30e6297e-e9a1-4b26-8659-301a063c57ec" # CHANGE THIS: This is the Ubuntu 22.04 ID for Tokyo

  primary_network_interface {
    subnet = ibm_is_subnet.subnet.id
  }
}

# 6. VPN Gateway (For the connection to your Fortinet)
resource "ibm_is_vpn_gateway" "vpn" {
  name   = "vpn-gw-tokyo"
  subnet = ibm_is_subnet.subnet.id
  mode   = "policy"
  resource_group = data.ibm_resource_group.rg.id
}
