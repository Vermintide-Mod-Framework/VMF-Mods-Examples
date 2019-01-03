Example of loading/unloading resource packages at will. This will work only for VT2 as additional resource packages are not supported in VT1.

You can read about how it works in [VMF documentation](https://vmf-docs.verminti.de/#/packages).

# Mod's resource packages

This mod has 3 resource packages:

* `default`:
  ```json
  lua = [
    "scripts/mods/package_management_example/package_management_example"
    "scripts/mods/package_management_example/package_management_example_data"
  ]
  ```
  Default resource package which contains 2 lua scripts. It is preloaded by default before loading the mod, because it's stated in `packages` field of table returned by the `.mod` file.

* `package_one`:
  ```json
  material = [
    "materials/package_management_example/package_one_materials"
  ]
  ```
  It contains 1 material file, which defines only 1 material inside of it: `doge_one`

* `package_two`
  ```json
  material = [
    "materials/package_management_example/package_two_materials"
  ]
  ```
  It contains 1 material file, which defines only 1 material inside of it: `doge_two`

# What this mod do

This mod defines 2 chat commands:
* `load_package [package_number] [sync_loading]` - loads one of 2 packages
  * `package_number` \[number\] - number of loaded package (`1` for `package_one` and `2` for `package_two`)
  * `sync_loading`? \[boolean\] - if `true`, loads package in sync mode

* `unload_package [package_number]` - unloads one of 2 packages

When a package is loaded the material it contains will be drawn on the screen.

To feel the difference between sync and async loading use `load_package` command on the first loading screen which appears after splash screen. It's the time when Bitsquid package manager is busy the most.