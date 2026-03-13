{ pkgs, ... }:
let
  monitor = "eDP-1";
  wallpaper = "/etc/weallcode-background.png";
in
{
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
        "backdrop/screen0/monitor${monitor}/workspace0/last-image" = wallpaper;
        "backdrop/screen0/monitor${monitor}/workspace0/image-style" = 5; # zoomed
      };
      xfce4-panel = {
        "panels" = [ 1 ];
        "panels/panel-1/plugin-ids" = [ 1 2 3 4 5 6 ];
        "panels/panel-1/position" = "p=8;x=0;y=0";
        "panels/panel-1/position-locked" = true;
        "panels/panel-1/size" = 48;
        "panels/panel-1/length" = 100.0;
        "plugins/plugin-1" = "applicationsmenu";
        "plugins/plugin-2" = "launcher";
        "plugins/plugin-3" = "launcher";
        "plugins/plugin-4" = "separator";
        "plugins/plugin-4/expand" = true;
        "plugins/plugin-5" = "systray";
        "plugins/plugin-6" = "clock";
      };
    };

    xdg.configFile = {
      "xfce4/panel/launcher-2/code.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Visual Studio Code
        Exec=code
        Icon=vscode
      '';
      "xfce4/panel/launcher-3/firefox.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Firefox
        Exec=firefox
        Icon=firefox
      '';
    };
  };
}
