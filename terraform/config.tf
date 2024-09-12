terraform {
  backend "s3" {
    bucket = var.state_bukcet_name
    key    = "terraform/state.tfstate"
    region =  var.region
  }
}

provider "aws" {
  region =  var.region
}