# Debug-only patches for the westeri/thunderbolt.git integration tree.
#
# These are the patches that produce additional debug instrumentation,
# extra logging, or extra module parameters. They are not required for
# correctness; they are only used while debugging.
[
  {
    name = "usb4-dma-priority-weight-params";
    patch = ./0002-thunderbolt-tunnel-add-dma-priority-weight-params.patch;
  }
  {
    name = "usb4-nhi-ring-debugfs-instrumentation";
    patch = ./0003-thunderbolt-nhi-add-ring-debugfs-instrumentation.patch;
  }
  {
    name = "usb4-xdomain-log-unmatched-protocol-uuids";
    patch = ./0005-thunderbolt-xdomain-log-unmatched-protocol-uuids.patch;
  }
  {
    name = "usb4-xdomain-lane-bonding-module-param";
    patch = ./0009-thunderbolt-xdomain-lane-bonding-module-param.patch;
  }
  {
    name = "usb4-xdomain-route-trace";
    patch = ./0010-thunderbolt-trace-XDomain-route-matching.patch;
  }
]
