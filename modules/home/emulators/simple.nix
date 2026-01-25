{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleEmulators [
  { name = "bsnes"; defaultPackage = pkgs.bsnes; description = "bsnes (SNES)"; }
  { name = "duckstation"; defaultPackage = pkgs.duckstation; description = "DuckStation"; }
  { name = "pcsx2"; defaultPackage = pkgs.pcsx2; description = "PCSX2"; }
  { name = "rpcs3"; defaultPackage = pkgs.rpcs3; description = "RPCS3"; }
  { name = "dolphin"; defaultPackage = pkgs.dolphin-emu; description = "Dolphin (GameCube/Wii)"; packageName = "dolphin-emu"; }
  { name = "yuzu"; defaultPackage = pkgs.yuzu; description = "Yuzu (Switch)"; }
  { name = "mupen64plus"; defaultPackage = pkgs.mupen64plus; description = "Mupen64Plus (N64)"; }
  { name = "citra"; defaultPackage = pkgs.citra; description = "Citra (3DS)"; }
  { name = "ryujinx"; defaultPackage = pkgs.ryujinx; description = "Ryujinx (Switch)"; }
  { name = "cemu"; defaultPackage = pkgs.cemu; description = "Cemu (Wii U)"; }
  { name = "ppsspp"; defaultPackage = pkgs.ppsspp; description = "PPSSPP (PSP)"; }
  { name = "melonds"; defaultPackage = pkgs.melonDS; description = "melonDS (DS)"; packageName = "melonDS"; }
  { name = "desmume"; defaultPackage = pkgs.desmume; description = "DeSmuME (DS)"; }
  { name = "flycast"; defaultPackage = pkgs.flycast; description = "Flycast (Dreamcast)"; }
  { name = "xemu"; defaultPackage = pkgs.xemu; description = "Xemu (Xbox)"; }
  { name = "mame"; defaultPackage = pkgs.mame; description = "MAME (Arcade)"; }
  { name = "fceux"; defaultPackage = pkgs.fceux; description = "FCEUX (NES)"; }
  { name = "snes9x"; defaultPackage = pkgs.snes9x; description = "Snes9x (SNES)"; }
]) { inherit config pkgs lib; }

