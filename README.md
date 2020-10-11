Register global shortcuts in windows.

```nim
import globalHotkeys
let doStuff =  register('r', [MAlt, MControl])
let doOtherStuff =  register('a', [MAlt, MShift])
let doEvenMoreStuff =  register('b', [MAlt])
let doQuit = register('q', [MAlt])

while true:
  let hotkeyOpt = getHotkey()
  if hotkeyOpt.isNone: continue
  let hotkey = hotkeyOpt.get()
  if hotkey == doStuff:
    echo "doStuff"
  elif hotkey == doOtherStuff:
    echo "doOtherStuff"
  elif hotkey == doEvenMoreStuff:
    echo "doEvenMoreStuff"
  elif hotkey == doQuit:
    echo "bye bye..."
    quit()
```