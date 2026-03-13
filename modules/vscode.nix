{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
      ];
      userSettings = {
        "editor.wordWrap" = "on";
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.fontSize" = 16;
        "security.workspace.trust.untrustedFiles" = "open";
        "workbench.startupEditor" = "newUntitledFile";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.fontFamily" = "'JetBrains Mono', 'DejaVu Sans Mono', monospace";
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = true;
          "editor.detectIndentation" = false;
        };
      };
    };
  };
}
