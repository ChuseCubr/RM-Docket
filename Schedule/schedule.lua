local Refreshes
local NextThreshold
local PrevDay

local Schedule
local Thresholds

-- I've only tested the first 3
-- not sure if the rest work properly, but they should
local ValidActions = {
    "MouseOverAction",
    "MouseLeaveAction",
    "LeftMouseDownAction",
    "LeftMouseUpAction",
    "LeftMouseDoubleClickAction",
    "RightMouseDownAction",
    "RightMouseUpAction",
    "RightMouseDoubleClickAction",
    "MiddleMouseDownAction",
    "MiddleMouseUpActions",
    "MiddleMouseDoubleClickAction",
    "X1MouseDownAction",
    "X1MouseUpActions",
    "X1MouseDoubleClickAction",
    "X2MouseDownAction",
    "X2MouseUpActions",
    "X2MouseDoubleClickAction",
    "MouseScrollUpAction",
    "MouseScrollDownAction",
    "MouseScrollRightAction",
    "MouseScrollLeftAction",
    "MouseActionCursor",
    "MouseActionCursorName"
}


--=== schedule functions ===--
local function _fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function _parseCSV(file)
    local parsed = {}
    local sep = SKIN:GetVariable("Delimiter", "")

    if sep == "" then
        sep = ","
    end

    for line in io.lines(file) do
        -- imitate repetition
        local _, len = string.gsub(line, ",", ",")
        local pattern = "^"
        for i = 1, len, 1 do
            pattern = pattern..string.format("([^%s]*),", sep)
        end
        pattern = pattern..string.format("([^%s]*)$", sep)

        -- actually parse
        local vals = {string.match(line, pattern)}

        -- substitutions
        for i = 1, #vals, 1 do
            vals[i] = vals[i]:gsub("\\sep ", sep)
            vals[i] = vals[i]:gsub("\\'", "\"")
        end
        table.insert(parsed, vals)
    end
    table.remove(parsed, 1)
    return parsed
end

local function _setSched(week, day, now)
    for i = 1, #week, 1 do
        table.insert(Schedule,
            {
                Time = week[i][1],
                TimeStart = string.match(week[i][1], "([^%-]*)-"),
                TimeEnd = string.match(week[i][1], "-([^%-]*)"),
                Name = week[i][day],
            }
        )
        if now < Schedule[i].TimeStart then
            Schedule[i].Style="StyleUpcoming"
            Schedule[i].HoverStyle="StyleUpcomingHover"
        elseif now < Schedule[i].TimeEnd then
            Schedule[i].Style="StyleOngoing"
            Schedule[i].HoverStyle="StyleOngoingHover"
        else
            Schedule[i].Style="StyleCompleted"
            Schedule[i].HoverStyle="StyleCompletedHover"
        end
    end
end

local function _setActions(day)
    for j = 1, #ValidActions, 1 do
        if _fileExists(SKIN:MakePathAbsolute("actions\\"..ValidActions[j]..".csv")) then
            local commands = _parseCSV(SKIN:MakePathAbsolute("actions\\"..ValidActions[j]..".csv"))
            for i = 1, #Schedule, 1 do
                Schedule[i][ValidActions[j]] = commands[i][day]
            end
        end
    end
end

local function _removeEmpty()
    local i = 1

    while i <= #Schedule do
        if not (string.find(Schedule[i].Name, "^$") == nil) then
            table.remove(Schedule, i)
        else
            i = i + 1
        end
    end
end

local function _mergeLong()
    local i = 1

    while i < #Schedule do
        if (
            Schedule[i].Name == Schedule[i+1].Name and
            Schedule[i].TimeEnd == Schedule[i+1].TimeStart
        ) then
            Schedule[i].TimeEnd = Schedule[i+1].TimeEnd
            Schedule[i].Time = Schedule[i].TimeStart.."-"..Schedule[i].TimeEnd
            table.remove(Schedule, i+1)
        else
            i = i + 1
        end
    end
end

local function _setThresholds()
    Thresholds = {}
    for i = 1, #Schedule, 1 do
        table.insert(Thresholds, Schedule[i].TimeStart)
        table.insert(Thresholds, Schedule[i].TimeEnd)
    end
    table.sort(Thresholds)

    -- merge same values
    local i = 1
    while i < #Thresholds do
        if (Thresholds[i] == Thresholds[i+1]) then
            table.remove(Thresholds, i+1)
        else
            i = i + 1
        end
    end
end


--=== .inc file functions ===--
local function _getNumVar(name, default)
    local var

    if SKIN:GetVariable(name) == "" then
        var = default
    else
        var = tonumber(SKIN:GetVariable(name, default))
    end
    return var
end

local function _initContent()
    local content = string.format([[
; set here bc refresh bang resets everything
[Variables]
NextThreshold=%d
Refreshes=%d
PrevDay=%d
]],
        NextThreshold,
        Refreshes,
        PrevDay)
        
    -- invisible meters for positioning other meters
    if #Schedule >= 1 then
        content = content..string.format([[

[Slot]
Meter=String
MeterStyle=%s
StringAlign=Left
FontColor=0,0,0,0
X=0
Y=0
Text=%s

[Time]
Meter=String
MeterStyle=styleTimes
StringAlign=Left
FontColor=0,0,0,0
X=0
Y=0
Text=%s
]],
            Schedule[1].Style,
            Schedule[1].Name,
            Schedule[1].Time)
    end
    return content
end

-- actual displayed meters
local function _extendContent(incFile, offset, i)
    local content = incFile.content
    local vMode = incFile.vMode
    local space = incFile.space
    local timeAbove = incFile.timeAbove
    local timeOffset = incFile.timeOffset

    content = content..string.format([[
        
[Slot%d]
Meter=String
MeterStyle=%s
X=%.2f
Y=%.2f
Text=%s
]],
        i,
        Schedule[i].Style,
        (offset + (1-vMode) * (i-1) * space),
        (vMode * space * (i-1) + timeAbove * timeOffset),
        Schedule[i].Name)

    -- actions
    for j = 1, #ValidActions, 1 do
        if Schedule[i][ValidActions[j]] ~= nil then
            content = content..string.format("%s=%s", ValidActions[j], Schedule[i][ValidActions[j]])

            local hasHoverStyle = _getNumVar("ChangeStyleOnHover", 0)
            if hasHoverStyle == 1 then
                if ValidActions[j] == "MouseOverAction" then
                    content = content..string.format("[!SetOption Slot%d MeterStyle \"%s\"]", i, Schedule[i].HoverStyle)
                elseif ValidActions[j] == "MouseLeaveAction" then
                    content = content..string.format("[!SetOption Slot%d MeterStyle \"%s\"]", i, Schedule[i].Style)
                end
            end
            content = content.."\n"
        end
    end
    content = content..string.format([[DynamicVariables=1

[Time%d]
Meter=String
MeterStyle=StyleTimes
X=%.2f
Y=%.2f
Text=%s
DynamicVariables=1
]],
        i,
        (offset + (1-vMode) * (i-1) * space),
        ((1-timeAbove) * timeOffset + vMode * space * (i-1)),
        Schedule[i].Time)
    return content
end

local function _writeInc(content)
    local path = SKIN:MakePathAbsolute("schedule.inc")
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
end

local function _initInc()
    -- only ever refreshes after first load if threshold is hit
    if SKIN:GetMeasure("cCounter"):GetValue() > 1 then
        NextThreshold = NextThreshold + 1
    end
    local content = _initContent()

    -- to get widths for comparison
    _writeInc(content)
end

local function _extendInc()
    -- offset for centering based on name/time, depending on width
    local slotW = SKIN:GetMeter("Slot"):GetW()
    local timeW = SKIN:GetMeter("Time"):GetW()
    local incFile = {}
    
    incFile.content = _initContent()
    incFile.vMode = _getNumVar("VerticalMode", 0)
    incFile.space = _getNumVar("Spacing", 200)
    incFile.timeAbove = _getNumVar("TimeAbove", 0)
    incFile.timeOffset = _getNumVar("TimeOffset", 30)

    for i = 1, #Schedule, 1 do
        if slotW > timeW then
            incFile.content = _extendContent(incFile, slotW/2, i)
        else
            incFile.content = _extendContent(incFile, timeW/2, i)
        end
    end
    _writeInc(incFile.content)
end


--=== Update() functions ===--
local function updateInc()
    if Refreshes == 1 then
        _initInc()
        return
    else
        _extendInc()
    end
end

local function initSched(day, now)
    local path = SKIN:MakePathAbsolute("schedule.csv")
    local week = _parseCSV(path)
    Schedule = {}

    _setSched(week, day, now)
    _setActions(day)
    _removeEmpty()
    _mergeLong()
    _setThresholds()
end


--=== Rainmeter functions ===--
function Initialize()
    -- SKIN object doesn't get passed here
    -- so actual initialization happens in Update()
end

function Update()
    local now = os.date("%H:%M")
    local day = os.date("%w") + 2

    -- ignore .inc if first load
    if SKIN:GetMeasure("cCounter"):GetValue() == 1 then
        Refreshes     = 0
        NextThreshold = 1
        PrevDay       = 2
    end

    -- newly refreshed
    if Refreshes == nil then
        Refreshes     = tonumber(SKIN:GetVariable("Refreshes", 0))
        NextThreshold = tonumber(SKIN:GetVariable("NextThreshold", 1))
        PrevDay       = tonumber(SKIN:GetVariable("PrevDay", 2))
    end

    -- refresh on new day
    if PrevDay ~= day then
        Refreshes = 0
    end
    PrevDay = day

    -- read schedule file until no more refreshes
    if Refreshes < 3 then
        initSched(day, now)
        Refreshes = Refreshes + 1
    end

    -- refresh when threshold is hit
    if type(Thresholds) == "table" then
        if NextThreshold <= #Thresholds then
            if now >= Thresholds[NextThreshold] then
                Refreshes = 1
            end
        end
    end

    -- write and refresh
    if Refreshes < 3 then
        updateInc()
        SKIN:Bang("!Refresh")
    end
end
