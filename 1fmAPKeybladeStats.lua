-----------------------------------
------ Kingdom Hearts 1 FM AP -----
------         by Gicu        -----
-----------------------------------

LUAGUI_NAME = "kh1fmAP"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Kingdom Hearts 1FM AP Integration"

local offset = 0x3A0606

local keyblade_stats_base_address = 0x2D288B8 - offset

local canExecute = false
local finished = false
frame_count = 0

if os.getenv('LOCALAPPDATA') ~= nil then
    client_communication_path = os.getenv('LOCALAPPDATA') .. "\\KH1FM\\"
else
    client_communication_path = os.getenv('HOME') .. "/KH1FM/"
    ok, err, code = os.rename(client_communication_path, client_communication_path)
    if not ok and code ~= 13 then
        os.execute("mkdir " .. path)
    end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function read_keyblade_stats()
    if file_exists(client_communication_path .. "keyblade_stats.cfg") then
        file = io.open(client_communication_path .. "keyblade_stats.cfg", "r")
        io.input(file)
        keyblade_stats = split(io.read(),",")
        io.close(file)
        return keyblade_stats
    elseif file_exists(client_communication_path .. "Keyblade Stats.cfg") then
        file = io.open(client_communication_path .. "Keyblade Stats.cfg", "r")
        io.input(file)
        keyblade_stats = split(io.read(),",")
        io.close(file)
        return keyblade_stats
    else
        return nil
    end
end

function write_keyblade_stats(keyblade_stats)
    i = 1
    j = 0
    while i <= #keyblade_stats do
        str = tonumber(keyblade_stats[i])
        mp  = tonumber(keyblade_stats[i+1])
        WriteByte(keyblade_stats_base_address + (0x58 * j) + 0x30, str)
        WriteByte(keyblade_stats_base_address + (0x58 * j) + 0x38, mp)
        i = i + 2
        j = j + 1
    end
end

function give_dream_weapons()
    inventory_address = 0x2DE5E69 - offset
    WriteArray(inventory_address + 82, {1,1,1})
end

function main()
    keyblade_stats = read_keyblade_stats()
    if keyblade_stats ~= nil and not finished then
        write_keyblade_stats(keyblade_stats)
        finished = true
    end
    give_dream_weapons()
end

function _OnInit()
    if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
        canExecute = true
        ConsolePrint("KH1 detected, running script")
    else
        ConsolePrint("KH1 not detected, not running script")
    end
end

function _OnFrame()
    if frame_count == 0 and canExecute then
        main()
    end
    frame_count = (frame_count + 1) % 30
end