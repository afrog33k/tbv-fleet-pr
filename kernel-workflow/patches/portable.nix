# Stock-kernel patch set: just the surviving local patches.
#
# On a stock torvalds/linux tree at >= v7.2-rc7 the upstream maintainer
# series (0101-0121) is already in the kernel, as is the 0122 property
# hardening backport and 0123 XDomain delayed-work UAF. The only patches
# still required on top are the local fixes and debug knobs.
import ./7.2-rc7.nix
