# Three way vpn tunnel

- Create three different networks in three separate projects: A,B,C
- join ProjA/NetworkA to ProjB/NetworkB using VPN tunnel
- join ProjB/NetworkB to ProjC/NetworkC using VPN tunnel

A <-> B <-> C

Each project gets one gateway, and one router.
Each network gets one subnet.

* Need to find out how to pick a link local address pair that works for each BGP session.
* The shared secret needs to be shared between both tunnels.
* Router ASN numbers need to be unique, and need to be shared between both tunnels.

# Keeping it simple

I'm going to create the projects and associated state bucket manually, and then initialize tf to use the bucket. That way the projects will aready exist and I can just run the terraform code to create the networks, gateways, routers, tunnels, and configure BGP sessions.

# Docs
- https://cloud.google.com/network-connectivity/docs/vpn/how-to/automate-vpn-setup-with-terraform
