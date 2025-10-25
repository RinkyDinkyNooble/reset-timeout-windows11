# reset-timeout-windows11
Disables automatic power timeouts by setting monitor, standby, and hibernate AC/DC values to 0 using powercfg. It reads current settings via GUIDs, checks for nonzero timeouts, resets them to 0, logs the changes, and displays a popup confirming successful timeout resets.
