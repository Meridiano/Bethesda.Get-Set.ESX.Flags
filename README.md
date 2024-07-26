# Starfield.Get-Set.ESX.Flags

This utility allows you to set any Starfield plugin flag like Master, Small, Medium and even Unknown XX.

Launch the utility and select your plugin.

## Get

Use singe 'g' command to print all plugin flags.

![](Images/Preview-Get.png)

## Set

Use 's <flag> <1/0>' command to set flag's value.
+ s 0x100 1 // will add 'Small' flag
+ s 0x400 0 // will remove 'Medium' flag

Backup is saved on any change: PluginName.esm ➔ PluginName.esm.YYYY-MM-DD-HH-MM-SS
