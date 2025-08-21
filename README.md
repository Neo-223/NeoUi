# Neo UI Library

A clean, modern Roblox UI library with:
- Tabs & content pages
- Buttons, toggles, sliders, and labels
- Keybinds (with rebinding support)
- Built-in **Settings tab** (with Toggle Menu + Unload Menu binds)
- Automatic scrolling for overflowing content and sidebar tabs

---

## 📦 Setup

Load the library in your script:

```lua
local Neo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neo-223/NeoUi/main/NeoUI.lua"))()
```

##🖱️ Components

Displays a simple label.
```
CreateLabel(text: string)
```
Creates a clickable button.
```
CreateButton(text: string, callback: () -> ())
```
Creates a toggle button.
```
CreateToggle(text: string, callback: (boolean) -> ())
```
Creates a slider with a value label.
```
CreateSlider(text: string, min: number, max: number, defaultValue: number, callback: (number) -> ())
```
