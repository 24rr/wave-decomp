# wave-decomp

It decompiles scripts and tells u if it can't read them. It displays the decompiled script and saves it in a folder named after the place ID in ur workspace. The tool also digs deep to find all functions, upvalues, constants, and details, giving a thorough breakdown. It scans services like StarterGui, Workspace, ReplicatedStorage, ServerScriptService (unsure), StarterPlayer, and Players. Just point it to the right service, and it handles the rest, making it easy to understand and analyze scripts. Note that some scripts might not be saved cuz of the executor's decompile function limitations.

# msg

this script was made ENTIRELY for the wave users because this is requested

# how to use it?

- run the script.lua first
- then open a new tab and type:
  ```
  _G.decomp('path_here')
  ```

### Available paths

- StarterGui
- Workspace
- ReplicatedStorage
- StarterPlayer
- Players
