FROM nixos/nix
RUN nix-env -i coreutils
ADD bootstrap.sh .
RUN sh bootstrap.sh
RUN rm bootstrap.sh
