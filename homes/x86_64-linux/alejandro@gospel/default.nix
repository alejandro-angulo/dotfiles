{ ... }:
{
  aa.isHeadless = false;
  aa.programs.opencode.enable = true;
  services.spotifyd = {
    enable = true;
    settings.global.bitrate = 320;
  };
}
