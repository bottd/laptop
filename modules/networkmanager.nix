_: {
  networking.networkmanager.enable = true;

  # Restrict WiFi connections and their stored secrets to the intended local user
  networking.networkmanager.settings."connection-wifi" = {
    "match-device" = "type:wifi";
    "connection.permissions" = "user:weallcode;";
  };
}
