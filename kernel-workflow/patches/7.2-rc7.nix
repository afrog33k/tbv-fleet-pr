[
  # Real local fixes (must carry)
  {
    name = "usb4-nhi-clear-pending-before-unmask";
    patch = ./0004-thunderbolt-nhi-clear-pending-before-unmask.patch;
  }
  {
    name = "usb4-xdomain-source-aware-protocol-handler";
    patch = ./0007-thunderbolt-xdomain-pass-source-to-protocol-handlers.patch;
  }
  {
    name = "usb4-xdomain-pin-protocol-handler-owner";
    patch = ./0008-thunderbolt-xdomain-pin-protocol-handler-owner.patch;
  }
  {
    name = "usb4-xdomain-drain-protocol-callbacks";
    patch = ./0010-thunderbolt-xdomain-drain-protocol-callbacks-on-unr.patch;
  }
  # Debug knobs (default on; toggle with debugPatches in flake)
  {
    name = "usb4-dma-priority-weight-params";
    patch = ./0002-thunderbolt-tunnel-add-dma-priority-weight-params.patch;
    debug = true;
  }
  {
    name = "usb4-nhi-ring-debugfs-instrumentation";
    patch = ./0003-thunderbolt-nhi-add-ring-debugfs-instrumentation.patch;
    debug = true;
  }
  {
    name = "usb4-xdomain-log-unmatched-protocol-uuids";
    patch = ./0005-thunderbolt-xdomain-log-unmatched-protocol-uuids.patch;
    debug = true;
  }
  {
    name = "usb4-xdomain-lane-bonding-module-param";
    patch = ./0009-thunderbolt-xdomain-lane-bonding-module-param.patch;
    debug = true;
  }
  {
    name = "usb4-xdomain-route-trace";
    patch = ./0010-thunderbolt-trace-XDomain-route-matching.patch;
    debug = true;
  }
]
