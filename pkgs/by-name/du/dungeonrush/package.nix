{
  lib,
  stdenv,
  writeScript,
  fetchFromGitHub,
  cmake,
  SDL2_image,
  SDL2_net,
  SDL2_mixer,
  SDL2_ttf,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs:
  let
    wrapperScript = writeScript "dungeon_rush" ''
      #!${runtimeShell}
      cd @out@/bin
      exec ./.dungeon_rush-unwrapped
    '';
  in
  {
  pname = "dungeonrush";
  version = "1.1-beta";

  src = fetchFromGitHub {
    owner = "yujqiao";
    repo = "DungeonRush";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YI9GwckxReQi86hhQ9NVYy4SzaA2azR+I/6mAyZ6mlc=";
  };

  patches = [
    ./0001-patch-out-evil-audio.patch
    ./0002-fix-resource-path.patch
  ];

  buildInputs = [
    cmake
    SDL2_image
    SDL2_net
    SDL2_mixer
    SDL2_ttf
  ];

  # remove audio the developer upstream has no proper license information on
  installPhase = ''
    rm bin/res/audio/bg1.ogg
    rm bin/res/audio/bg2.ogg
    rm bin/res/audio/bg3.ogg
    mkdir -p $out/bin
    cp -r bin $out
    mv $out/bin/res $out/share
    mv $out/bin/dungeon_rush $out/bin/.dungeon_rush-unwrapped
  '';

  # Accounting for the fact that this game expects its resources in the current directory
  fixupPhase = ''
    substitute ${wrapperScript} $out/bin/dungeon_rush --subst-var out
    chmod +x $out/bin/dungeon_rush
  '';

  meta = {
    description = "Basically snake, but you build your snake out of heros in a dungeon.";
    homepage = "https://github.com/yujqiao/DungeonRush";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ grindhold ];
  };
})
