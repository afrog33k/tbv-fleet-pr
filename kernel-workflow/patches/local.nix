# Local patches for the westeri/thunderbolt.git integration tree.
#
# This list applies on top of upstream `thunderbolt-next`. On a stock
# torvalds/linux tree at >= v7.2-rc7, prefer `7.2-rc7.nix` which lists the
# subset of local patches still required there.
let
  debugNames = map (p: p.name) (import ./local-integration-debug.nix);
in
builtins.filter (p: !(builtins.elem p.name debugNames)) (import ./7.2-rc7.nix)
