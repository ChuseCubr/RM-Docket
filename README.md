# DOCKet

![banner](https://user-images.githubusercontent.com/27886422/159879078-210da2cc-d449-4fba-bd2e-e45bf6564bce.png)

[Schedule](https://www.merriam-webster.com/thesaurus/docket) Dock

A [Rainmeter](https://www.rainmeter.net/) skin/Lua script that parses spreadsheets and makes a dynamic, interactive schedule.

Here's a showcase of hover and click actions:

![suite_showcase](https://user-images.githubusercontent.com/27886422/159912205-dd269250-f1c4-47ee-b858-f598084b8074.gif)

[Wallpaper](https://www.deviantart.com/aaronolive/art/Firewatch-Mods-619259473)

## Dependencies

Of course, you're gonna need [Rainmeter](https://www.rainmeter.net/), but that's about it.

## Installation

Go to the [releases tab](https://github.com/ChuseCubr/RM-Docket/releases), download the .rmskin file, and open it with Rainmeter.

Edit `Schedule\schedule.csv` to your needs. By default, it's set to ISO weeks (Sunday first day of the week). To change, please see [configuration section](#configuration).

> If you want to turn off or change the example mouse actions, go into the `Schedule\Actions` folder and edit the CSV files.

## Configuration

On top of configurable styles, you can also adjust the layout in `Schedule\schedule.ini`

```ini
;-- schedule.ini
[Variables]
; vertical layout
VerticalMode=0

; spacing between each subject
Spacing=200

; toggle displaying the time label above the subject
TimeAbove=0

; adjust spacing between subject and time range
TimeOffset=30

; toggle the built-in hover action (change color)
ChangeStyleOnHover=1

; subject name align
LabelAlign=Center

; subject status colors (needed for hover action)
OngoingColor="255,255,255,200"
UpComingColor="255,255,255,200"
CompletedColor="255,255,255,100"

OngoingHoverColor="255,255,255,255"
UpComingHoverColor="255,255,255,255"
CompletedHoverColor="255,255,255,180"

; see important notes
Delimiter=,
```

By default, the schedule is by iso week (starts on Sunday), but you can change this in line 380 of `Schedule\schedule.lua`:

```lua
-- schedule.lua
function Update()
    -- +2 = iso week (Sunday first day of the week)
    -- +1 = non iso week (Monday first day of the week)
    local day = os.date("%w") + 2
```

Times must be in a `HH:MM` 24-hour format in order to work properly (see banner or download skin for an example).

### Mouse Actions

The skin already has built-in MouseOverActions for changing colors, but you can extend these with your own.

Creating a CSV file in the `Schedule\Actions` folder named after the mouse action will add that functionality to the schedule (e.g. `Schedule\Actions\MouseScrollUpAction.csv`).

Similarly to how you set a mouse action for meters, these actions are set through bangs. Each cell will map to its counterpart in `Schedule\Schedule.csv`. A few examples are provided in the skin:

* LeftMouseDownAction: open a link in your browser
* MouseOverAction: display some text (set in `Description\`)
* MouseLeaveAction: stop displaying text (set in `Description\`)

I'm too small-brained to properly parse CSV files, so substitutions to certain characters must be made in order to:

* allow Excel to save to a parsable format (no quotes), and
* be able to parse columns properly (no excess separators)

I'm only aware of two substitutions that need to be done:

| From | To |
|:--|:--|
| Quotes (`"`) | Escaped apostrophes (`\'`) |
| Separators. This depends on region; a common one is commas (`,`) | `\sep ` (note the space. If you want a space after, you must add another.) |

For example:

```
[!SetOption Title Text \'Hello\sep  world! I'm alive!\']
    notice the 2 spaces ----------^^
```
