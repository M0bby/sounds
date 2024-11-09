local _G = require("new_tools")
local ui, events, clipboard = _G.ui, _G.events, _G.clipboard
local a = ui.group("lua>tab a")

local tesxt = {
    "If you are switching between",
    "CS:Source and CS:GO 2018 or vice versa",
    "you must press the reset button"
}

local ui_e = {
    enable = a:checkbox("Custom Weapon Sounds"),
    sound_sel = a:combo("Weapon Sound Version", {"CS:Source", "CS:GO 2018"}),
    vol = a:slider("Weapon Volume", 0, 100, 1),
    reset = a:button("Reset Sounds", function()
        engine.exec("snd_restart")
        print("snd_restart was executed")
    end),
    readme = ui.group("lua>tab b"):list("README", -1, false, tesxt),

}



local function handle_ui()
    local main_state = ui_e.enable:get()
    for i, v in pairs(ui_e) do
        v:visibility(main_state)
    end
    ui_e.enable:visibility(true)
end

function on_game_event(event)
    if event:get_name() == "weapon_fire" then
        local me = entities.get_entity(engine.get_local_player())
        if not me or not me:is_alive() then
            return
        end
        local userid = engine.get_player_for_user_id(event:get_int('userid'))
        local weapon = event:get_string("weapon")
        local cur_weapon = (weapon:gsub("weapon_", ""))
        local cur_vol = (" " .. ui_e.vol:get() / 100)
        if userid == engine.get_local_player() then
            if ui_e.sound_sel:get() == 0 then
                engine.exec("playvol weaponsounds_cs_source/" .. cur_weapon .. cur_vol)
            else
                engine.exec("playvol weaponsounds_csgo_2018/" .. cur_weapon .. cur_vol)
            end
        end
    end
end

events.on_paint:set(function()
    handle_ui()
end)
