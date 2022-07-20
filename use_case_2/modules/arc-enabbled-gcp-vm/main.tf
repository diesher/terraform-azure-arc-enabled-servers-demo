#----------------------------------------
# create a resource group
#----------------------------------------
resource "azurerm_resource_group" "azure_rg" {
  name     = var.azure_resource_group
  location = var.azure_location
}

data "google_compute_network" "gcp_network" {
  name = var.gcp_network
}

#----------------------------------------
# create a gcp subnet
#----------------------------------------
resource "google_compute_subnetwork" "vm_subnet" {
  name          = "vm-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = data.google_compute_network.gcp_network.id
  private_ip_google_access = true

}

#----------------------------------------
# create a Google Cloud Network RDP firewall rule
#----------------------------------------
//
resource "google_compute_firewall" "ssh-tunnel-fw" {
  name    = "ssh-tunnel-fw"
  network = google_compute_network.arc_proxy_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["10.0.0.0/16"]
  target_tags = ["RDP"]
}

// create a Google Cloud Network HTTP firewall rule
resource "google_compute_firewall" "http_server_fw" {
  name      = "http-server-fw"
  network   = google_compute_network.arc_proxy_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["80","8080", "443"]
  }
  source_ranges = ["10.0.0.0/16"]
  target_tags = ["web"]
}

#----------------------------------------
# create a gcp vm
#----------------------------------------
resource "google_compute_instance" "default" {
  name         = "arc-gcp-demo"
  machine_type = var.instance_type
  zone         = var.gcp_zone
  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }
  network_interface {
    network = google_compute_subnetwork.vm_subnet.name

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
#  metadata = {
#    windows-startup-script-ps1 = local_file.install_arc_agent_ps1.content
#  }
}

#resource "local_file" "install_arc_agent_ps1" {
#  content = templatefile("scripts/install_arc_agent.ps1.tmpl", {
#    resourceGroup  = var.azure_resource_group
#    location       = var.azure_location
#    subscriptionId = var.subscription_id
#    appId          = var.client_id
#    appPassword    = var.client_secret
#    tenantId       = var.tenant_id
#    }
#  )
#  filename = "scripts/install_arc_agent.ps1"
#}

