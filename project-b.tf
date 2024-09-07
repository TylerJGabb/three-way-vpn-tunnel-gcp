resource "google_project_service" "enable-services-b" {
  project  = "project-b-434903"
  for_each = toset(var.services_to_enable)
  service  = each.value
}

resource "google_compute_network" "network-b" {
  project                 = "project-b-434903"
  name                    = "network-b"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-b" {
  project       = "project-b-434903"
  name          = "subnet-b"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.network-b.id
}

resource "google_compute_ha_vpn_gateway" "gateway-b" {
  name    = "gw-b"
  project = "project-b-434903"
  network = google_compute_network.network-b.id
}

resource "google_compute_router" "router-b" {
  name    = "router-b"
  project = "project-b-434903"
  network = google_compute_network.network-b.id
  bgp {
    asn               = 64513
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "b-to-a-1" {
  name                  = "b-to-a-1"
  project               = "project-b-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-a.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-b.id
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "b-to-a-interface-1" {
  project    = "project-b-434903"
  name       = "b-to-a-interface-1"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-a-interface-1-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-a-1.name
}

resource "google_compute_router_peer" "b-to-a-peer-1" {
  project         = "project-b-434903"
  name            = "b-to-a-peer-1"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.a-to-b-interface-1-ip
  peer_asn        = google_compute_router.router-a.bgp[0].asn
  interface       = google_compute_router_interface.b-to-a-interface-1.name
}

resource "google_compute_vpn_tunnel" "b-to-a-2" {
  name                  = "b-to-a-2"
  project               = "project-b-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-a.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-b.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "b-to-a-interface-2" {
  project    = "project-b-434903"
  name       = "b-to-a-interface-2"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-a-interface-2-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-a-2.name
}

resource "google_compute_router_peer" "b-to-a-peer-2" {
  project         = "project-b-434903"
  name            = "b-to-a-peer-2"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.a-to-b-interface-2-ip
  peer_asn        = google_compute_router.router-a.bgp[0].asn
  interface       = google_compute_router_interface.b-to-a-interface-2.name
}

# I created this manually and then attempted to import it
# in order to learn what I was misconfiguring
# turns out it was the interface index

# -/+ resource "google_compute_vpn_tunnel" "manual-b-to-c-1" {
#       ~ creation_timestamp              = "2024-09-06T21:05:06.149-07:00" -> (known after apply)
#       ~ detailed_status                 = "Tunnel is up and running." -> (known after apply)
#       ~ effective_labels                = {
#           + "goog-terraform-provisioned" = "true"
#         }
#       ~ id                              = "projects/project-b-434903/regions/us-central1/vpnTunnels/manual-b-to-c-1" -> (known after apply)
#         ike_version                     = 2
#       ~ label_fingerprint               = "42WmSpB8rSM=" -> (known after apply)
#       - labels                          = {} -> null
#       ~ local_traffic_selector          = [
#           - "0.0.0.0/0",
#         ] -> (known after apply)
#         name                            = "manual-b-to-c-1"
#       - peer_external_gateway_interface = 0 -> null
#       - peer_gcp_gateway                = "https://www.googleapis.com/compute/v1/projects/project-c-434903/regions/us-central1/vpnGateways/gw-c" -> null # forces replacement
#       ~ peer_ip                         = "35.242.104.13" -> (known after apply)
#         project                         = "project-b-434903"
#       ~ region                          = "us-central1" -> (known after apply)
#       ~ remote_traffic_selector         = [
#           - "0.0.0.0/0",
#         ] -> (known after apply)
#       - router                          = "https://www.googleapis.com/compute/v1/projects/project-b-434903/regions/us-central1/routers/router-b" -> null # forces replacement
#       ~ self_link                       = "https://www.googleapis.com/compute/v1/projects/project-b-434903/regions/us-central1/vpnTunnels/manual-b-to-c-1" -> (known after apply)
#       + shared_secret                   = (sensitive value) # forces replacement
#       ~ shared_secret_hash              = "VLt0Ql38qjeiUNLIJaZVzIBvxini" -> (known after apply)
#       ~ terraform_labels                = {
#           + "goog-terraform-provisioned" = "true"
#         }
#       ~ tunnel_id                       = "5758162270571359773" -> (known after apply)
#       - vpn_gateway                     = "https://www.googleapis.com/compute/v1/projects/project-b-434903/regions/us-central1/vpnGateways/gw-b" -> null # forces replacement
#       - vpn_gateway_interface           = 0 -> null
#     }

resource "google_compute_vpn_tunnel" "b-to-c-1" {
  name             = "b-to-c-1"
  project          = "project-b-434903"
  vpn_gateway      = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.gateway-c.id
  shared_secret    = local.shared_secret
  router           = google_compute_router.router-b.id
  // this is the index of the interface on the VPN gateway that the tunnel is connected to
  // this corresponds to one of the two ip addresses (interfaces) owned by the gateway
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "b-to-c-interface-1" {
  project    = "project-b-434903"
  name       = "b-to-c-interface-1"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-c-interface-1-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-c-1.name
}

resource "google_compute_router_peer" "b-to-c-peer-1" {
  project         = "project-b-434903"
  name            = "b-to-c-peer-1"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.c-to-b-interface-1-ip
  peer_asn        = google_compute_router.router-c.bgp[0].asn
  interface       = google_compute_router_interface.b-to-c-interface-1.name
}

resource "google_compute_vpn_tunnel" "b-to-c-2" {
  name                  = "b-to-c-2"
  project               = "project-b-434903"
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway-b.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway-c.id
  shared_secret         = local.shared_secret
  router                = google_compute_router.router-b.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "b-to-c-interface-2" {
  project    = "project-b-434903"
  name       = "b-to-c-interface-2"
  router     = google_compute_router.router-b.name
  ip_range   = "${local.b-to-c-interface-2-ip}/30"
  vpn_tunnel = google_compute_vpn_tunnel.b-to-c-2.name
}

resource "google_compute_router_peer" "b-to-c-peer-2" {
  project         = "project-b-434903"
  name            = "b-to-c-peer-2"
  router          = google_compute_router.router-b.name
  peer_ip_address = local.c-to-b-interface-2-ip
  peer_asn        = google_compute_router.router-c.bgp[0].asn
  interface       = google_compute_router_interface.b-to-c-interface-2.name
}
