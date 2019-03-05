FROM nixos/nix
RUN nix-env -i coreutils
RUN mkdir /root/.emacs.d
ADD bootstrap.sh /root/.emacs.d/
RUN sh /root/.emacs.d/bootstrap.sh
RUN nix-collect-garbage
