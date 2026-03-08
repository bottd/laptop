{ ... }:

{
  # Wallpaper - copy to home directory
  home.file.".weallcode-background.png".source = ../weallcode-background.png;

  # Set wallpaper via activation script (works with most DEs)
  home.activation.setWallpaper = ''
    # GNOME
    if command -v gsettings &>/dev/null; then
      gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.weallcode-background.png" 2>/dev/null || true
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.weallcode-background.png" 2>/dev/null || true
    fi

    # KDE Plasma
    if command -v plasma-apply-wallpaperimage &>/dev/null; then
      plasma-apply-wallpaperimage "$HOME/.weallcode-background.png" 2>/dev/null || true
    fi

    # XFCE
    if command -v xfconf-query &>/dev/null; then
      xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$HOME/.weallcode-background.png" 2>/dev/null || true
    fi
  '';
}
