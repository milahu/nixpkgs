{ lib
, usrsctp
, fetchpatch
}:

usrsctp.overrideAttrs (oldAttrs: rec {
  version = oldAttrs.version + "-frida";
  patches = (oldAttrs.patches or []) ++ [
    # https://github.com/sctplab/usrsctp/pull/591
    # add Add usrsctp_get_timeout
    # required by frida-core
    (fetchpatch {
      url = "https://github.com/sctplab/usrsctp/commit/5fb4b8373d77978ea8b2373048d8d04840dd2f61.patch";
      sha256 = "sha256-54k3s5Y4dYehnBK9Lr2aIrTurAktQIq3RQs8DDSAYaY=";
    })
  ];
})
