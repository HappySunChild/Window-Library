# Documentation

too lazy to complete lol deal with it 

### element
- Menu `frame`
---
### configBase
- Elements `{element}`
#### configBase:AddButton(text: string, callback: () -> nil)
- Creates a button inside the configBase with the text as `text`
- Returns a element
#### configBase:AddSlider(name: string, min: number, max: number, default: number?, callback: (number) -> nil)
- Creates a slider inside the configBase with the minimum and maximum values as `min` and `max`
- Returns a sliderelement
---
### Module
- BaseSize `UDim2`
#### module.new(title: string, toggleWindowActiveKey: Enum.KeyCode?, animate: boolean?)
- Returns a `Window`
---
### Window
- Menu `frame`
- IsOpen `boolean`
- Dragging `boolean`
- Tabs `{tab}`

##### window:AddTab(name: string)
- Adds a tab to the window with `name`
- Returns a `Tab`
##### window:Open()
- Opens the window
##### window:Close()
- Closes the window
##### window:Destroy()
- Returns `nil`
- Deletes window
---
### Tab
- Selected `boolean`
#### Inherits `configBase`
#### Inherits `element`
