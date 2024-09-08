{...}: {
  aa.isHeadless = false;
  services.spotifyd = {
    enable = true;
    settings.global.bitrate = 320;
  };
}
