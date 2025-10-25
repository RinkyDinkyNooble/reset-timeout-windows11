# reset-timeout-windows11
Disables automatic power timeouts by setting monitor, standby, and hibernate AC/DC values to 0 using powercfg. It reads current settings via GUIDs, checks for nonzero timeouts, resets them to 0, logs the changes, and displays a popup confirming successful timeout resets.

### How It Works

1. **Define Power Setting GUIDs**  
   Each power feature (monitor, standby, hibernate) is identified by a unique Windows GUID. These are stored in a hashtable for reference.

2. **Query Current Power Settings**  
   The script uses `powercfg /Q` to read current AC/DC timeout values. It extracts the relevant hexadecimal values using regex and converts them to numbers.

3. **Compare and Reset Timeouts**  
   If any timeout is not already `0`, it executes `powercfg -change` commands to reset them:
   - `powercfg -change -monitor-timeout-ac 0`
   - `powercfg -change -monitor-timeout-dc 0`
   - `powercfg -change -standby-timeout-ac 0`
   - and so on for all power states.

4. **Track and Log Changes**  
   For each modified setting, the script records which GUID and power mode were changed. These logs are combined into a summary message.

5. **Display Confirmation**  
   Once all changes are applied, a popup message appears via `WScript.Shell` confirming that timeouts were successfully reset.

### Result

After running this script:
- The display will **never turn off automatically**.
- The computer will **not enter sleep or hibernate** on its own.
- Applies to both **battery** and **plugged-in** modes.
- A summary popup confirms the operation’s success.

### Example Output

```text
GUID: 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e
Name: monitor
Type: AC
GUID: 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e
Name: monitor
Type: DC
