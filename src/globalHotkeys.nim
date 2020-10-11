# # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerhotkey
import winim, strutils, options
import bitops, sets
export options
type
  Modifier* = enum
    MAlt = MOD_ALT,
    MControl = MOD_CONTROL,
    MShift = MOD_SHIFT,
    MWin = MOD_WIN
  HotkeyPress* = object
    key*: char
    mods*: HashSet[Modifier]
    orgLparam*: LPARAM
    orgId*: LPARAM

proc `==`*(hpA, hpB: HotkeyPress): bool =
  ## To test if the hotkey matches our matcher
  hpA.key == hpB.key and
  hpA.mods == hpB.mods

proc unpackHotkey*(lparam: LPARAM): HotkeyPress =
  ## Unpack the lParam that describes the hotkey pressed.
  ## https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-hotkey
  result.orgLparam = lparam
  let parts = cast[array[2, int16]](lparam)
  result.key = chr(parts[1])
  if 0 < parts[0].bitand(MAlt.int16): result.mods.incl MAlt
  if 0 < parts[0].bitand(MShift.int16): result.mods.incl MShift
  if 0 < parts[0].bitand(MControl.int16): result.mods.incl MControl
  if 0 < parts[0].bitand(MWin.int16): result.mods.incl   MWin

proc unregister*(id: int | LPARAM) =
  UnregisterHotKey(0, id.int32)

proc unregister*(hotkeyPress: HotkeyPress) =
  unregister(hotkeyPress.orgId)

proc register*(key: char, mods: openArray[Modifier], id = 1): HotkeyPress =
  ## registers a new global hotkey.
  ## key must be upper letter!
  ## returns HotkeyPress, use this to test if your hotkey was pressed
  ## id: the id used for register the key (must be unregistered with the same key)
  var orsum = 0
  for modd in mods:
    orsum = orsum or modd.int
  if 0 == RegisterHotKey(0, id.int32, orsum.UINT, key.toUpperAscii().ord.UINT).bool:
    raise newException(OsError, "could not register hotkey")
  return HotkeyPress(key: key.toUpperAscii(), mods: toHashSet(mods), orgId: id)

proc getHotkey*(): Option[HotkeyPress] =
  ## Must be called in a loop!
  ## raises OsError exception in case of an error
  ## when a hotkey is pressed the returned option is isSome[HotkeyPress]
  ## this calles GetMessage internally, so when you already calling GetMessage use, unpackHotkey manually!
  var msg: MSG
  if false == GetMessage(addr(msg), 0, 0, 0).bool:
    raise newException(OsError, "could not get hotkey")
  if msg.message == WM_HOTKEY:
    return some(unpackHotkey(msg.lParam))
  return

when isMainModule:
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