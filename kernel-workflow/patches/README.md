# Kernel Patches

This directory carries the local kernel patches for the
`thunderbolt-ibverbs` kernel module.

- `7.2-rc7.nix`: the canonical patch list for stock torvalds/linux trees
  at >= v7.2-rc7. Contains only the local fixes and debug knobs that are
  not yet in upstream v7.2-rc7. The maintainer-tree delta (0101-0121)
  is in the kernel itself and is not carried here.
- `upstream-thunderbolt-next.nix`: empty placeholder. The 0101-0121 series
  was the 7.2 merge window delta; it is now in v7.2-rc7. The regen script
  `regen-upstream-thunderbolt-patches.sh` is kept for tracking future
  maintainer delta (v7.3 merge window), but the patch set itself is empty.
- `local.nix`: local patches for the `westeri/thunderbolt.git` integration
  tree, which is ahead of v7.2-rc7. Equals `7.2-rc7.nix` minus the
  debug-only layer.
- `local-integration-debug.nix`: the debug-only subset (gated separately
  by `local.nix` via a name filter).
- `local-portable.nix`: equal to `7.2-rc7.nix` for the stock-kernel
  portable stack.
- `portable.nix`: the stock-kernel patch set; equal to `7.2-rc7.nix`.
- `default.nix`: imports `portable.nix`.

Patches are tagged with a `debug = true` attribute on the entries that
produce only extra debug instrumentation, extra logging, or extra module
parameters. The flake exposes `debugPatches` (default on) to toggle the
debug subset out of the build.

The audit at `AUDIT-7.2-rc7.md` records the apply-check verdict for every
patch against a clean v7.2-rc7 tree (commit `db2ddb871`).
