{
  config,
  pkgs,
  ...
}: {
  # enable the tailscale daemon; this will do a
  # variety of tasks:
  # 1. create the TUN network device
  # 2. setup some IP routes to route through the TUN
  services.tailscale = {enable = true;};

  # Let's open the UDP port with which the network is tunneled through
  networking.firewall.allowedUDPPorts = [41641];

  # Disable SSH access through the firewall Only way into the machine will be
  # through This may cause a chicken & egg problem since you need to register
  # a machine first using `tailscale up`
  # Better to rely on EC2 SecurityGroups
  # services.openssh.openFirewall = false;

  # Let's make the tailscale binary avilable to all users
  environment.systemPackages = [pkgs.tailscale];

  # TODO: Enable SSH via tailscale
}
