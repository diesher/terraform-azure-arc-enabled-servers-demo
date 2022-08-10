
## GCP VPC
#resource "google_compute_network" "arc_proxy_vpc" {
#  name                    = "arc-proxy-vpc-demo"
#  auto_create_subnetworks = true
#}

##  create a Google Cloud Network SSH firewall rule
#resource "google_compute_firewall" "ssh-tunnel-fw" {
#  name    = "ssh-tunnel-fw"
#  network = data.google_compute_network.network.self_link #google_compute_network.arc_proxy_vpc.self_link
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22"]
#  }
#  source_ranges = ["0.0.0.0/0"]
#  target_tags = ["ssh"]
#}

# create a Google Cloud Network tcp firewall rule
resource "google_compute_firewall" "http_server_fw" {
  name      = "proxy-server-fw"
  network   = data.google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["3128"] // port 3128 if from the squid proxy server
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["proxy"]
}


# create a static IP address
 resource "google_compute_address" "static" {
   name = "ipv4-address"
 }


# create a Google Cloud Compute Instance
resource "google_compute_instance" "vm_proxy" {
  name                      = "vm-proxy"
  machine_type              = "e2-standard-2"
  allow_stopping_for_update = false
  zone = var.gcp_zone
  tags = ["proxy"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud-devel/ubuntu-2004-lts"
    }
  }

  metadata = {
    ssh-keys = "arc_user:${file("~/.ssh/google_compute_engine.pub")}"
  }

  network_interface {
    network = data.google_compute_network.network.self_link
    access_config {
      // let google cloud generate an IP address
      nat_ip = google_compute_address.static.address
      // or use an already declared static ip

    }
  }
  metadata_startup_script = file("../scripts/proxy_server.sh")
}


