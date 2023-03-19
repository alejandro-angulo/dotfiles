{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aa.tools.zsh;
in {
  options.aa.tools.zsh = with types; {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    aa.home.extraOptions = {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        envExtra = ''
          export PATH=~/.local/bin:$PATH
          export EDITOR=vim
        '';
        initExtra = ''
          base16_darktooth
          bindkey -v
          bindkey '^A' beginning-of-line
          bindkey '^E' end-of-line
          bindkey '^R' history-incremental-search-backward
          alias view="vim -R $1"
          # alias ls=lsd
          alias l='ls -la'
        '';

        plugins = with pkgs; [
          {
            name = "zsh-syntax-highlighting";
            src = fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.6.0";
              sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
            };
            file = "zsh-syntax-highlighting.zsh";
          }
          {
            name = "powerlevel10k";
            src = fetchFromGitHub {
              owner = "romkatv";
              repo = "powerlevel10k";
              rev = "v1.16.1";
              sha256 = "0fkfh8j7rd8mkpgz6nsx4v7665d375266shl1aasdad8blgqmf0c";
            };
            file = "powerlevel10k.zsh-theme";
          }
          {
            name = "powerlevel10k-config";
            src = lib.cleanSource ./.;
            file = "p10k.zsh";
          }
          {
            name = "base16-shell";
            src = fetchFromGitHub {
              owner = "chriskempson";
              repo = "base16-shell";
              rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
              sha256 = "1yj36k64zz65lxh28bb5rb5skwlinixxz6qwkwaf845ajvm45j1q";
            };
            file = "base16-shell.plugin.zsh";
          }
        ];
      };
    };
  };
}
