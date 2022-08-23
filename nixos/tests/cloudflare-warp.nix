import ./make-test-python.nix ({ pkgs, ... }: {
  name = "cloudflare-warp";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ wolfangaukang ];
  };

  nodes.machine =
    { lib, ... }:

    {
      # cloudflare-warp is unfree
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "cloudflare-warp"
      ];
      services.cloudflare-warp = {
        enable = true;
      };
    };

  # As the commands are automated, we will need to add the
  # --accept-tos flag. Also, as there is no internet connection,
  # We will only test the registration, which should work
  testScript = ''
    machine.wait_for_unit("warp-svc.service")
    file = "/var/lib/cloudflare-warp/settings.json"
    machine.wait_for_file(file);
    machine.succeed("warp-cli --accept-tos register")
    machine.wait_for_console_text("Success")
  '';
})
