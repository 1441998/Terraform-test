terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.59.0"
    }
  }
}

provider "ibm" {
  region = "us-south" 
}
