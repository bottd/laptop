_: {
  networking.networkmanager.enable = true;

  # Store WiFi passwords system-wide (no secret service needed)
  networking.networkmanager.settings."connection-wifi" = {
    "match-device" = "type:wifi";
    "connection.permissions" = "";
  };
}
