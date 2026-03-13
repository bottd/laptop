{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: [
      ps.tkinter
      ps.weallcode-robot
    ]))

    (makeDesktopItem {
      name = "idle";
      desktopName = "Python IDLE";
      exec = "${python3}/bin/idle3";
      icon = "idle3";
      comment = "Python's beginner-friendly editor";
      categories = [ "Development" "IDE" ];
    })
  ];
}
