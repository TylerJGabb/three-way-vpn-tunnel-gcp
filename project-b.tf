resource "google_project_service" "enable_services_b" {
  project  = "project-b-434820"
  for_each = toset(var.services_to_enable)
  service  = each.value
}

resource "google_compute_network" "network-b" {
  project                 = "project-b-434820"
  name                    = "network-b"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-b" {
  project       = "project-b-434820"
  name          = "subnet-b"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.network-b.id
}

resource "google_compute_ha_vpn_gateway" "gateway-b" {
  name    = "gw-b"
  project = "project-b-434820"
  network = google_compute_network.network-b.id
}

resource "google_compute_router" "router-b" {
  name    = "router-b"
  project = "project-b-434820"
  network = google_compute_network.network-b.id
  bgp {
    asn               = 64513
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "b-to-a-1" {
  name                  = "b-to-a-1"
  project               = "project-b-434820"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-a.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-b.id
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "b-to-a-interface-1" {
  project    = "project-b-434820"
  name       = "b-to-a-interface-1"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-a-interface-1-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-a-1.name
}

resource "google_compute_router_peer" "b-to-a-peer-1" {
  project         = "project-b-434820"
  name            = "b-to-a-peer-1"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.a-to-b-interface-1-ip
  peer_asn        = google_compute_router.router-a.bgp[0].asn
  interface       = google_compute_router_interface.b-to-a-interface-1.name
}

resource "google_compute_vpn_tunnel" "b-to-a-2" {
  name                  = "b-to-a-2"
  project               = "project-b-434820"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-a.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-b.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "b-to-a-interface-2" {
  project    = "project-b-434820"
  name       = "b-to-a-interface-2"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-a-interface-2-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-a-2.name
}

resource "google_compute_router_peer" "b-to-a-peer-2" {
  project         = "project-b-434820"
  name            = "b-to-a-peer-2"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.a-to-b-interface-2-ip
  peer_asn        = google_compute_router.router-a.bgp[0].asn
  interface       = google_compute_router_interface.b-to-a-interface-2.name
}
