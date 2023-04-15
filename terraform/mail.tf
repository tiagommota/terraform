# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet
# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key_name.id]
}
# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/ssh_key
data "digitalocean_ssh_key" "ssh_key_name" {
  name = var.ssh_key_name
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster
# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_node_pool
resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# 
variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "region" {
  default = ""
}

# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet
output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "foo" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}