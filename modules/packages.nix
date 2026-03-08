# Package list
{ pkgs, vscode }:

with pkgs; [
  # CLI tools
  git
  direnv
  dockutil

  # Python with packages
  tk
  tcl
  (python3.withPackages (ps: [
    ps.tkinter
    ps.weallcode-robot
  ]))

  # GUI apps
  vscode.package
  google-chrome
]
