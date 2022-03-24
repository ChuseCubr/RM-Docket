# RM-DOCKet

![banner](https://user-images.githubusercontent.com/27886422/159853369-5dfa8e37-ce1a-4483-905a-4984ecbd0e7b.png)

[Schedule](https://www.merriam-webster.com/thesaurus/docket) Dock

A Rainmeter skin/Lua script that parses spreadsheets and makes a dynamic, interactive schedule.

## Features

### Easy to use

Create your schedule in `schedule.csv`, load the skin in Rainmeter, and the script will handle everything. (Please read important notes.)

Events that take multiple rows are merged, so you don't have to make as many mostly empty rows to accomodate events that occupy irregular time slots.

### Customizable

Styles for every name label status (upcoming, ongoing, completed), their hover counterparts, and time labels are customizable.

Some settings are made accessible in the ini file, namely:

- `VerticalMode=[0|1]`
  - Arrange elements vertically.
- `TimeAbove=[0|1]`
  - Position time labels above name labels.
- `ChangeStyleOnHover=[0|1]`
  - Toggle the built-in hover mouse action.
- `Spacing`
  - Space in px between the centers of each element.
- `TimeOffset`
  - Difference in vertical positions between time and name labels in px.
- `SkinX` and `SkinY`
  - If left blank, centers the skin.
- `Delimiter`
  - To accomodate regional differences in CSV format (though there are still limitations; please read notes).

You can also customize mouse actions.

### Mouse actions support

Creating a CSV file in the `actions\` folder named after the mouse action will add that functionality to the schedule (e.g. `actions\MouseScrollUpAction.csv`).

Each action will only apply to its equivalent cell in `schedule.csv`. An example is provided.

Labels have built-in hover actions to change their own style, but you can extend these hover actions. (Built-in actions are appended to CSV actions.)

## Important notes

Times must be in a `HH:MM` 24-hour format in order to work properly (see banner or download skin for an example).

By default, the schedule is by week (starting on Sunday) and changes per day, but this behavior can be changed. Just change line 357 in `schedule.lua` to fit your needs.

I'm too small-brained to properly parse CSV files, so substitutions to certain characters must be made in order to:

- allow Excel to save to a parsable format (no quotes), and
- be able to parse columns properly (no excess separators)

I'm only aware of two substitutions that need to be done:

| From | To |
|:--|:--|
| Quotes (`"`) | Escaped apostrophes (`\'`) |
| Separators. This depends on region; a common one is commas (`,`) | `\sep ` (note the space. If you want a space after, you must add another.) |

For example:

```
[!SetOption Title Text \'Hello\sep  world! I'm alive!\']
```
