resource "google_project_service" "enable-services-c" {
  project  = "project-c-434903"
  for_each = toset(var.services_to_enable)
  service  = each.value
}

resource "google_compute_network" "network-c" {
  project                 = "project-c-434903"
  name                    = "network-c"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-c" {
  project       = "project-c-434903"
  name          = "subnet-c"
  ip_cidr_range = "10.0.3.0/24"
  network       = google_compute_network.network-c.id
}

resource "google_compute_ha_vpn_gateway" "gateway-c" {
  name    = "gw-c"
  project = "project-c-434903"
  network = google_compute_network.network-c.id
}

resource "google_compute_router" "router-c" {
  name    = "router-c"
  project = "project-c-434903"
  network = google_compute_network.network-c.id
  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "c-to-b-1" {
  name                  = "c-to-b-1"
  project               = "project-c-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-c.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-b.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-c.id
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "c-to-b-interface-1" {
  name       = "c-to-b-interface-1"
  project    = "project-c-434903"
  router     = google_compute_router.router-c.name
  ip_range   = "${local.c-to-b-interface-1-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.c-to-b-1.name
}

resource "google_compute_router_peer" "c-to-b-peer-1" {
  project         = "project-c-434903"
  name            = "c-to-b-peer-1"
  router          = google_compute_router.router-c.name
  peer_ip_address = local.b-to-c-interface-1-ip
  peer_asn        = google_compute_router.router-b.bgp[0].asn
  interface       = google_compute_router_interface.c-to-b-interface-1.name
}
