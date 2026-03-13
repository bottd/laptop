{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  programs.xfconf.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "weallcode";
  };

  environment.etc."weallcode-background.png".source = ../assets/weallcode-background.png;

  environment.systemPackages = [ pkgs.xfce.xfce4-screenshooter ];

  home-manager.users.weallcode = {
    xfconf.settings = {
      xfce4-desktop = {
        "backdrop/screen0/monitor0/workspace0/last-image" = "/etc/weallcode-background.png";
        "backdrop/screen0/monitor0/workspace0/image-style" = 5;
      };
      xfce4-screensaver = {
        "saver/enabled" = false;
        "lock/enabled" = false;
      };
      xfce4-power-manager = {
        "xfce4-power-manager/inactivity-on-ac" = 0;
        "xfce4-power-manager/inactivity-on-battery" = 0;
        "xfce4-power-manager/blank-on-ac" = 0;
        "xfce4-power-manager/blank-on-battery" = 0;
        "xfce4-power-manager/dpms-on-ac-sleep" = 0;
        "xfce4-power-manager/dpms-on-ac-off" = 0;
        "xfce4-power-manager/dpms-on-battery-sleep" = 0;
        "xfce4-power-manager/dpms-on-battery-off" = 0;
        "xfce4-power-manager/lid-action-on-ac" = 0;
        "xfce4-power-manager/lid-action-on-battery" = 0;
        "xfce4-power-manager/lock-screen-suspend-hibernate" = false;
      };
    };
  };
}
