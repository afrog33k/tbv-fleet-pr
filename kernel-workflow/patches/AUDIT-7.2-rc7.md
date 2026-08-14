# 7.2-rc7 Patch Audit (2026-08-14)

Audited against `linux.git` tag `v7.2-rc7` (`db2ddb871`), apply-checked with
`git apply --check`. SHA `db2ddb871` resolves to `Linux 7.2-rc7`, dated
2026-08-12.

## Method

`git apply --check <patch>` from a clean `v7.2-rc7` tree. "Applies" means the
patch is not yet present (or the context lines moved enough to be a real
delta). "Rejects" means the patch context no longer matches the source — for
the upstream series that resolves to "the fix is already in 7.2-rc7", for the
local patches it usually means the surrounding code evolved enough that the
patch needs a rebase.

| Patch | Series | Verdict |
|---|---|---|
| 0001 (referenced in flake) | (none) | n/a |
| 0002 DMA priority/weight params | local | keep — debug knob, author marks "do not upstream" |
| 0003 NHI ring debugfs instrumentation | local | keep — debug instrumentation, used heavily |
| 0004 NHI clear pending MSI-X before unmask | local | keep — real fix, not in 7.2-rc7 |
| 0005 xdomain log unmatched protocol UUIDs | local | keep — debug, used for Apple UUID discovery |
| 0007 xdomain pass source XDomain to protocol handlers | local | keep — real local API extension |
| 0008 xdomain pin protocol handler owner | local | keep — real local rmmod race fix |
| 0009 xdomain lane-bonding module param | local | keep — debug knob |
| 0009 xdomain match properties by identity | local | **drop — already in 7.2-rc7** (uses `pkg_len`) |
| 0010 xdomain drain protocol callbacks on unregister | local | keep — real local rmmod race fix |
| 0010 xdomain route matching trace | local | keep — debug, used heavily |
| 0101 Avoid reserved fields in path config | upstream | **drop — already in 7.2-rc7** |
| 0102 Don't disable lane adapter on XDomain failure | upstream | **drop — already in 7.2-rc7** |
| 0103 Make XDomain lane bonding comply | upstream | **drop — already in 7.2-rc7** |
| 0104 Keep domain reference while processing | upstream | **drop — already in 7.2-rc7** |
| 0105 Release request on tb_cfg_request failure | upstream | **drop — already in 7.2-rc7** |
| 0106 Set tb->root_switch to NULL on stop | upstream | **drop — already in 7.2-rc7** |
| 0107 Wait for tb_domain_release to complete | upstream | **drop — already in 7.2-rc7** |
| 0108 Keep XDomain reference during service lifetime | upstream | **drop — already in 7.2-rc7** |
| 0109 dma_test: no need to store debugfs dir | upstream | **drop — already in 7.2-rc7** |
| 0110 Remove service debugfs on unregister | upstream | **drop — already in 7.2-rc7** |
| 0111 Remove XDomain from bus without domain lock | upstream | **drop — already in 7.2-rc7** |
| 0112 Don't create multiple DMA tunnels on firmware | upstream | **drop — already in 7.2-rc7** |
| 0113 Add tb_property_merge_dir | upstream | **drop — already in 7.2-rc7** |
| 0114 Add KUnit test for tb_property_merge_dir | upstream | **drop — already in 7.2-rc7** |
| 0115 Allow service drivers to specify own properties | upstream | **drop — already in 7.2-rc7** |
| 0116 thunderbolt/net: move ring_frame_size | upstream | **drop — already in 7.2-rc7** |
| 0117 thunderbolt/net: let service drivers configure interrupt throttling | upstream | **drop — already in 7.2-rc7** |
| 0118 Add helper to figure size of the ring | upstream | **drop — already in 7.2-rc7** |
| 0119 Add tb_ring_flush | upstream | **drop — already in 7.2-rc7** |
| 0120 Add support for ConfigFS | upstream | **drop — already in 7.2-rc7** |
| 0121 Add support for USB4STREAM | upstream | **drop — already in 7.2-rc7** |
| 0122 backport XDomain property hardening fixes | local (LKML backport) | **drop — already in 7.2-rc7** (verified `xd->removing`, `min_t(size_t, ...)` clamps present) |
| 0123 Prevent XDomain delayed-work UAF | local (LKML backport) | **drop — already in 7.2-rc7** (verified `xd->removing` lock-checked queue sites) |

## Final set to carry on 7.2-rc7

11 patches, all local. The full upstream 0101-0121 layer is gone.

- 0002 — debug knob (DMA priority/weight)
- 0003 — debug instrumentation (NHI ring debugfs)
- 0004 — real local fix (NHI MSI-X clear before unmask)
- 0005 — debug (xdomain log unmatched UUIDs)
- 0007 — real local API extension (source XDomain to protocol handlers)
- 0008 — real local fix (pin protocol handler owner)
- 0009 (lane bonding module param) — debug knob
- 0010 (drain protocol callbacks) — real local fix
- 0010 (xdomain route trace) — debug

## Notes

- `local.nix` in tree bundles the debug-only patches under `local-integration-debug.nix` for the
  `westeri/thunderbolt.git` integration tree. Against a stock 7.2-rc7 kernel we
  can flatten: every local patch that was previously debug-only is now in the
  flat layer, gated by the flake attribute `debugPatches` (default on).
- The regen script `regen-upstream-thunderbolt-patches.sh` is now documentation
  only. The 0101-0121 series is upstream; running it against 7.2-rc7 yields a
  no-op diff. We keep the script for future maintainer delta tracking when 7.3
  opens.
- Post-7.2 commits in `thunderbolt-next` (DMA tunnel credit clamp, busy
  polling, IOCB_NOWAIT) are **not** required for the dmabuf RX refactor and are
  deferred.
