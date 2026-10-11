## Devices & hosts

- The Viwoods tablet is USB-attached to THIS machine (Windows), not to host g. Check `adb devices` locally before assuming another host.
- Tablet .24 is often offline. Skip it, report it, and keep going with the other devices.
- On Android devices, simulate taps via `adb shell input tap` / uiautomator instead of asking me to tap by hand.
- Do not assume a device's settings are defaults. Read the actual config first.
- Before heavy jobs, check free RAM and free space on C:. Prefer W:/D: for large workspaces and scratch data.
