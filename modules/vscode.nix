# VS Code configuration
{ pkgs }:

{
  # VS Code with extensions
  package = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.vscode-pylance
    ];
  };

  # Settings file
  settings = pkgs.writeText "vscode-settings.json" (builtins.toJSON {
    # Python
    "python.linting.enabled" = true;
    "python.linting.pylintEnabled" = true;
    "python.linting.pylintArgs" = [
      "--disable=C0114"
      "--disable=C0115"
      "--disable=C0116"
    ];
    "python.formatting.provider" = "black";
    "python.formatting.blackArgs" = [ "--line-length" "120" ];

    # Editor
    "editor.wordWrap" = "on";
    "editor.minimap.enabled" = false;
    "editor.formatOnSave" = true;
    "security.workspace.trust.untrustedFiles" = "open";
    "workbench.startupEditor" = "newUntitledFile";

    # Terminal
    "terminal.integrated.fontSize" = 14;
    "terminal.integrated.fontFamily" = "Menlo, Monaco, 'Courier New', monospace";

    # Python-specific
    "[python]" = {
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.detectIndentation" = false;
    };
  });
}
