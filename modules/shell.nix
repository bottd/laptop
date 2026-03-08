{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(direnv hook bash)"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
