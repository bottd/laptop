{ ... }:

{
  home.file.".weallcode-background.png".source = ../weallcode-background.png;

  home.activation.setWallpaper = ''
    /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "'$HOME'/.weallcode-background.png"' || true
  '';
}
