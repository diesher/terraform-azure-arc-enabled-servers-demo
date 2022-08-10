# An Azure resource group
resource "azurerm_resource_group" "azure_rg" {
  name     = var.azure_resource_group
  location = var.azure_location
}

##  create a Google Cloud Network SSH firewall rule
#resource "google_compute_firewall" "proxy-fw" {
#  name    = "proxy"
#  network = data.google_compute_network.network.self_link
#  priority = 100
#  allow {
#    protocol = "tcp"
#    ports    =  ["80","443"]
#  }
#  direction               = "EGRESS"
#  destination_ranges = ["10.156.0.2"]
#  target_tags = ["proxy"]
#}
#
##  create a Google Cloud Network SSH firewall rule
#resource "google_compute_firewall" "internet-deny-fw" {
#  name    = "internet-deny"
#  network = data.google_compute_network.network.self_link
#  priority = 200
#  deny {
#    protocol = "tcp"
#    ports    =  ["80","443"]
#  }
#  direction               = "EGRESS"
#  destination_ranges = ["0.0.0.0/0"]
#  target_tags = ["internet-deny"]
#}

## create a Google Cloud Network tcp firewall rule
#resource "google_compute_firewall" "proxy_fw" {
#  name      = "allow-proxy"
#  network   = data.google_compute_network.network.self_link
#
#  allow {
#    protocol = "tcp"
#    ports    = ["3389"]
#  }
#  source_ranges = ["0.0.0.0/0"]
#  target_tags = ["rdp"]
#}


# A single Google Cloud Engine instance
resource "google_compute_instance" "arc_vm" {
  name         = "arc-gcp-demo"
  machine_type = var.instance_type
  zone         = var.gcp_zone
  tags = ["proxy"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }
  network_interface {
    network = data.google_compute_network.network.name
    access_config {

    }

  }
  metadata = {
    windows-startup-script-ps1 = local_file.install_arc_agent_ps1.content
  }
}

resource "local_file" "install_arc_agent_ps1" {
  content = templatefile("../scripts/install_arc_agent.ps1.tmpl", {
    resourceGroup  = var.azure_resource_group
    location       = var.azure_location
    subscriptionId = var.subscription_id
    appId          = var.client_id
    appPassword    = var.client_secret
    tenantId       = var.tenant_id
    }
  )
  filename = "../scripts/install_arc_agent.ps1"
}



