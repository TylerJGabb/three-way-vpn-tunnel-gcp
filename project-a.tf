resource "google_project_service" "enable-services-a" {
  project  = "project-a-434903"
  for_each = toset(var.services_to_enable)
  service  = each.value
}


resource "google_compute_network" "network-a" {
  project                 = "project-a-434903"
  name                    = "network-a"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-a" {
  project       = "project-a-434903"
  name          = "subnet-a"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.network-a.id
}

resource "google_compute_ha_vpn_gateway" "gateway-a" {
  name    = "gw-a"
  project = "project-a-434903"
  network = google_compute_network.network-a.id
}

resource "google_compute_router" "router-a" {
  name    = "router-a"
  project = "project-a-434903"
  network = google_compute_network.network-a.id
  bgp {
    asn               = 64512
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "a-to-b-1" {
  name                  = "a-to-b-1"
  project               = "project-a-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-a.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-b.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-a.id
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "a-to-b-interface-1" {
  name       = "a-to-b-interface-1"
  project    = "project-a-434903"
  router     = google_compute_router.router-a.name
  ip_range   = "${local.a-to-b-interface-1-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.a-to-b-1.name
}

resource "google_compute_router_peer" "a-to-b-peer-1" {
  name            = "a-to-b-peer-1"
  project         = "project-a-434903"
  router          = google_compute_router.router-a.name
  peer_ip_address = local.b-to-a-interface-1-ip
  peer_asn        = google_compute_router.router-b.bgp[0].asn
  interface       = google_compute_router_interface.a-to-b-interface-1.name
}

resource "google_compute_vpn_tunnel" "a-to-b-2" {
  name                  = "a-to-b-2"
  project               = "project-a-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-a.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-b.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-a.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "a-to-b-interface-2" {
  name       = "a-to-b-interface-2"
  project    = "project-a-434903"
  router     = google_compute_router.router-a.name
  ip_range   = "${local.a-to-b-interface-2-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.a-to-b-2.name
}

resource "google_compute_router_peer" "a-to-b-peer-2" {
  name            = "a-to-b-peer-2"
  project         = "project-a-434903"
  router          = google_compute_router.router-a.name
  peer_ip_address = local.b-to-a-interface-2-ip
  peer_asn        = google_compute_router.router-b.bgp[0].asn
  interface       = google_compute_router_interface.a-to-b-interface-2.name
}







