{ lib
, stdenv
, pkg-config
, apple-sdk_26 ? null
, rdma-core-usb4 ? null
, rocm-sdk ? null
, rocmOffloadArch ? null
, python3
, source ? ../userspace/bench
, appleCompat ? ./apple-compat
}:

let
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Programs portable to Apple's RDMA host SDK (linked via dynamic_lookup):
  # plain libibverbs verbs surface, no Linux-specific kernel uapi or
  # LD_PRELOAD-style entrypoints.
  darwinPrograms = [
    "mac_tb_rdma_probe"
    "rc_write_poll"
    "rc_write_verify"
    "u4_pingpong"
    "uc_oneway"
    "uc_write_verify"
  ];

  # Full Linux set. ibv_trace is an LD_PRELOAD tracer built as .so.
  linuxPrograms = darwinPrograms ++ [
    "dmabuf_mr_probe"
    "rc_qpn_churn"
    "rdma_gid_probe"
  ];
  hipPrograms = lib.optionals (!isDarwin && rocm-sdk != null) [
    "hip_rdma_write_visibility_probe"
  ];

  scripts = [
    "tbv_perftest_runner.py"
    "tbv_rdma_sweep.py"
    "tbv_uc_stress.py"
    "tbv_vllm_smoke.sh"
  ];

  cPrograms = if isDarwin then darwinPrograms else linuxPrograms;
  installPrograms = cPrograms ++ hipPrograms;
  cxxInclude = "${stdenv.cc.cc}/include/c++/${stdenv.cc.cc.version}";
  cxxTargetInclude = "${cxxInclude}/${stdenv.hostPlatform.config}";
  libcDev = lib.getDev stdenv.cc.libc;
  libcLib = lib.getLib stdenv.cc.libc;
  gccLib = lib.getLib stdenv.cc.cc;
  rocmArchFlag =
    lib.optionalString (rocmOffloadArch != null)
      "--offload-arch=${rocmOffloadArch}";
in
assert lib.assertMsg (!isDarwin || apple-sdk_26 != null)
  "bench-tools Darwin build requires apple-sdk_26";
stdenv.mkDerivation {
  pname =
    if isDarwin
    then "thunderbolt-ibverbs-bench-tools-apple-rdma"
    else "thunderbolt-ibverbs-bench-tools";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = source;
    filter = path: _type:
      let
        rel = baseNameOf (toString path);
      in
        lib.hasSuffix ".c" rel
        || lib.hasSuffix ".cpp" rel
        || lib.hasSuffix ".py" rel
        || lib.hasSuffix ".sh" rel;
  };

  nativeBuildInputs = lib.optionals (!isDarwin) [ pkg-config ];
  buildInputs = lib.optionals (!isDarwin) [ rdma-core-usb4 ]
    ++ lib.optionals (hipPrograms != [ ]) [ rocm-sdk ]
    ++ lib.optionals isDarwin [ apple-sdk_26 ]
    ++ [ python3 ];

  dontConfigure = true;

  buildPhase =
    if isDarwin then ''
      runHook preBuild
      for name in ${lib.concatStringsSep " " cPrograms}; do
        $CC -O2 -Wall -Wextra -std=gnu11 \
          -I${appleCompat} \
          "$name.c" \
          -lrdma \
          -o "$name"
      done
      runHook postBuild
    '' else ''
      runHook preBuild
      for name in ${lib.concatStringsSep " " cPrograms}; do
        extra=""
        case "$name" in
          uc_oneway) extra="-ldl" ;;
        esac
        $CC -O2 -Wall -Wextra -std=gnu11 \
          -I${rdma-core-usb4.dev}/include \
          "$name.c" \
          -L${rdma-core-usb4}/lib -libverbs \
          $extra \
          -Wl,-rpath,${rdma-core-usb4}/lib \
          -o "$name"
      done
      $CC -O2 -Wall -Wextra -fPIC -shared \
        -I${rdma-core-usb4.dev}/include \
        ibv_trace.c \
        -ldl -lpthread \
        -L${rdma-core-usb4}/lib -libverbs \
        -Wl,-rpath,${rdma-core-usb4}/lib \
        -o libibv_trace.so
      ${lib.optionalString (hipPrograms != [ ]) ''
        for name in ${lib.concatStringsSep " " hipPrograms}; do
          ROCM_PATH=${rocm-sdk} ${rocm-sdk}/bin/hipcc \
            -O2 -Wall -Wextra -std=c++17 ${rocmArchFlag} \
            --gcc-toolchain=${stdenv.cc.cc} \
            -isystem ${cxxInclude} \
            -isystem ${cxxTargetInclude} \
            -isystem ${libcDev}/include \
            -I${rdma-core-usb4.dev}/include \
            "$name.cpp" \
            -L${rdma-core-usb4}/lib -libverbs \
            -L${rocm-sdk}/lib -lhsa-runtime64 \
            -B${libcLib}/lib \
            -L${libcLib}/lib \
            -L${gccLib}/lib \
            -Wl,-rpath,${rdma-core-usb4}/lib \
            -Wl,-rpath,${libcLib}/lib \
            -Wl,-rpath,${gccLib}/lib \
            -Wl,-rpath,${rocm-sdk}/lib \
            -Wl,-dynamic-linker,${libcLib}/lib/ld-linux-x86-64.so.2 \
            -o "$name"
        done
      ''}
      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0755 ${lib.concatStringsSep " " installPrograms} $out/bin/
    install -m 0755 ${lib.concatStringsSep " " scripts} $out/bin/
    ${lib.optionalString (!isDarwin) ''
      mkdir -p $out/lib
      install -m 0644 libibv_trace.so $out/lib/
    ''}
    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin
  '';

  meta = with lib; {
    description = "Thunderbolt/USB4 RDMA bench programs (libibverbs C tools + perftest helper scripts)";
    license = licenses.mit;
    maintainers = with maintainers; [ georgewhewell ];
    platforms = if isDarwin then platforms.darwin else platforms.linux;
  };
}
