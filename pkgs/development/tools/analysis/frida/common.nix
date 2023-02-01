{ fetchFromGitHub }:

{
  version = "16.0.8";
  # sources are pinned in https://github.com/frida/frida
  srcs = {
    frida-gum = fetchFromGitHub {
      owner = "frida";
      repo = "frida-gum";
      rev = "be5fc6d95bfc490dbd83d3e0847f0fef01c1f009";
      sha256 = "sha256-GNxCLbi35qH4bvSwdxF3h2eirOhKKdg9BWNzx2OmXik=";
    };
  };
}
