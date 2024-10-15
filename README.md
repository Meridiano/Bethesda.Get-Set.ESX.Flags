# Bethesda.Get-Set.ESX.Flags

This utility allows you to set plugins flags like Master, Light/Small, Medium and even Unknown XX.

Launch the utility and select your plugin.

## Get

Use singe "g" command to print all plugin flags.

![](Images/Preview-Get.png)

## Set

Use "s (flag) (1/0)" command to set flag's value.
+ s 0x100 1 // will add Small flag (Starfield)
+ s 0x400 0 // will remove Medium flag (Starfield)
+ s 0x200 0 // will remove Light flag (Skyrim SE)

Backup is saved on any change: PluginName.esm ➔ PluginName.esm.YYYY-MM-DD-HH-MM-SS

## Ini

All flags info is stored in ini-file but no definitions provided in release, you download this file instead.

URL is read from "\[Config\]URL" key. If it's not empty, its web resource will be used as flags info holder.

You can change the URL value and \[Flags\] section to your own, this means custom definitions are supported.

This repo has 2 related ini-files:
+ [Starfield](./Configs/Starfield.ini) is default.
+ [Skyrim SE](./Configs/SkyrimSE.ini) can be switched to.
