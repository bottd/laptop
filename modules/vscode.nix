{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        esbenp.prettier-vscode
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
        "python.defaultInterpreterPath" = "/run/current-system/sw/bin/python";
        "ruff.interpreter" = [ "/run/current-system/sw/bin/python" ];
        "ruff.configuration" = {
          "lint" = { "ignore" = [ "F403" "F405" ]; };
        };
        "github.copilot.enable" = { "*" = false; };
        "github.copilot.editor.enableAutoCompletions" = false;
        "github.copilot.editor.enableCodeActions" = false;
        "github.copilot.nextEditSuggestions.enabled" = false;
        "github.copilot.nextEditSuggestions.fixes" = false;
        "github.copilot.renameSuggestions.triggerAutomatically" = false;
        "github.copilot.chat.reviewSelection.enabled" = false;
        "github.copilot.chat.reviewAgent.enabled" = false;
        "editor.inlineSuggest.enabled" = false;
        "chat.enabled" = false;
        "chat.disableAIFeatures" = true;
        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;
        "chat.detectParticipant.enabled" = false;
        "chat.autopilot.enabled" = false;
        "inlineChat.lineNaturalLanguageHint" = false;
        "terminal.integrated.initialHint" = false;
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.insertSpaces" = true;
          "editor.detectIndentation" = false;
        };
      };
    };
  };
}
