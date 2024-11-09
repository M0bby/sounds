local primo_events = {
    ["render"] = "PAINT",
    ["aim_hit"] = "AIMBOT_HIT",
    ["aim_ack"] = "AIMBOT_MISS",
    ["aim_shot"] = "AIMBOT_SHOOT",
    ["draw_model"] = "DRAW_MODEL",
    ["on_watermark"] = "DRAW_WATERMARK",
    ["command_end"] = "FINISH_COMMAND",
    ["on_hitscan"] = "HITSCAN",
    ["net_update"] = "NET_UPDATE",
    ["on_esp"] = "PLAYER_ESP",
    ["run_command"] = "RUN_COMMAND",
    ["on_screen_hitmarker"] = "SCREEN_HITMARKER",
    ["setup_command"] = "SETUP_COMMAND",
    ["shutdown"] = "SHUTDOWN",
    ["on_sup_rec"] = "SUPPORTIVE_RECTANGLE",
    ["on_target_selection"] = "TARGET_SELECTION",
    ["on_world_hitmarker"] = "WORLD_HITMARKER",
    ["antiaim"] = "ANTIAIM",
    ["game_event"] = "EVENT"
}
local events = setmetatable({}, {
    __index = function(tbl, key)
        local newEvent = {
            set = function(self, func)
                if primo_events[tostring(key)] == nil then
                    callbacks.add(e_callbacks.EVENT, function(...)
                        func(...)
                    end, tostring(key))
                else
                    callbacks.add(e_callbacks[primo_events[tostring(key)]], function(...)
                        func(...)
                    end)
                end
            end
        }
        tbl[key] = newEvent
        return newEvent
    end
})
local ui = (function()
    local ui = {}
    ui.__type = {
        group = -1,
        button = 0,
        keybind = 1,
        text_input = 2,
        text = 3,
        separator = 4,
        list = 5,
        checkbox = 6,
        color_picker = 7,
        multi_selection = 8,
        selection = 9,
        slider = 10
    }
    ui.__metasave = true
    ui.__data = {}
    ui.create = function(_group, _column)
        local data = {
            group = _group,
            column = _column,
            id = ui.__type.group
        }
        menu.set_group_column(_group, _column)
        ui.__index = ui
        return setmetatable(data, ui)
    end
    function ui:create_element(_id, _name, _options)
        local ref = nil
        if _id == ui.__type.button then
            ref = menu.add_button(self.group, _name, _options.fn)
        elseif _id == ui.__type.checkbox then
            ref = menu.add_checkbox(self.group, _name, _options.default_value)
        elseif _id == ui.__type.color_picker then
            ref = _options.parent.ref:add_color_picker(_name, _options.default_value, _options.alpha)
        elseif _id == ui.__type.keybind then
            ref = _options.parent.ref:add_keybind(_name, _options.default_value)
        elseif _id == ui.__type.list then
            ref = menu.add_list(self.group, _name, _options.items, _options.visible_count)
        elseif _id == ui.__type.multi_selection then
            ref = menu.add_multi_selection(self.group, _name, _options.items, _options.visible_count)
        elseif _id == ui.__type.selection then
            ref = menu.add_selection(self.group, _name, _options.items, _options.visible_count)
        elseif _id == ui.__type.slider then
            ref = menu.add_slider(self.group, _name, _options.min, _options.max, _options.step, _options.precision, _options.suffix)
        elseif _id == ui.__type.text_input then
            ref = menu.add_text_input(self.group, _name)
        elseif _id == ui.__type.text then
            ref = menu.add_text(self.group, _name)
        elseif _id == ui.__type.separator then
            ref = menu.add_separator(self.group)
        end
        local data = {
            name = _name,
            id = _id,
            ref = ref,
            group = self.group,
            get = function(self, _item)
                if self.id == ui.__type.multi_selection then
                    return self.ref:get(_item)
                else
                    return self.ref:get()
                end
            end
        }
        if not ui.__data[self.group] then
            ui.__data[self.group] = {}
        end
        ui.__data[self.group][_name] = data
        if ui.__metasave then
            if not ui[self.group] then
                ui[self.group] = {}
            end
            ui[self.group][_name] = data
            self[_name] = data
        end
        return setmetatable(data, ui)
    end
    function ui:button(_name, _fn)
        _fn = _fn or function()
        end
        return self:create_element(ui.__type.button, _name, {
            fn = _fn
        })
    end
    function ui:checkbox(_name, _default_value)
        return self:create_element(ui.__type.checkbox, _name, {
            default_value = _default_value
        })
    end
    function ui:color_picker(_parent, _name, _default_value, _alpha)
        return self:create_element(ui.__type.color_picker, _name, {
            parent = _parent,
            default_value = _default_value,
            alpha = _alpha
        })
    end
    function ui:keybind(_parent, _name, _default_value)
        return self:create_element(ui.__type.keybind, _name, {
            parent = _parent,
            default_value = _default_value
        })
    end
    function ui:list(_name, _items, _visible_count)
        return self:create_element(ui.__type.list, _name, {
            items = _items,
            visible_count = _visible_count
        })
    end
    function ui:multi_selection(_name, _items, _visible_count)
        return self:create_element(ui.__type.multi_selection, _name, {
            items = _items,
            visible_count = _visible_count
        })
    end
    function ui:selection(_name, _items, _visible_count)
        return self:create_element(ui.__type.selection, _name, {
            items = _items,
            visible_count = _visible_count
        })
    end
    function ui:slider(_name, _min, _max, _step, _precision, _suffix)
        return self:create_element(ui.__type.slider, _name, {
            min = _min,
            max = _max,
            step = _step,
            precision = _precision,
            suffix = _suffix
        })
    end
    function ui:text_input(_name)
        return self:create_element(ui.__type.text_input, _name)
    end
    function ui:text(_name, _options)
        return self:create_element(ui.__type.text, _name, _options)
    end
    function ui:separator()
        return self:create_element(ui.__type.separator, "separator")
    end
    ui.export = function()
        local d = {}
        for i, v in pairs(ui.__data) do
            d[i] = {}
            for i0, v0 in pairs(v) do
                if not (v0.id < ui.__type.checkbox) then
                    if v0.id == ui.__type.multi_selection then
                        local s = {}
                        for i1, v1 in pairs(v0.ref:get_items()) do
                            table.insert(s, {v1, v0.ref:get(v1)})
                        end
                        table.insert(d[i], {v0.name, s})
                    elseif v0.id == ui.__type.color_picker then
                        local clr = v0.ref:get()
                        table.insert(d[i], {v0.name, clr.r, clr.g, clr.b, clr.a})
                    else
                        table.insert(d[i], {v0.name, v0.ref:get()})
                    end
                end
            end
        end
        return json.encode(d)
    end
    ui.import = function(data)
        local db = json.parse(data)
        for i, v in pairs(db) do
            for i0, v0 in pairs(v) do
                if not (ui.__data[i] == nil or ui.__data[i][v0[1]] == nil) then
                    if ui.__data[i][v0[1]].id == ui.__type.multi_selection then
                        for i1, v1 in pairs(v0[2]) do
                            ui.__data[i][v0[1]].ref:set(v1[1], v1[2])
                        end
                    elseif ui.__data[i][v0[1]].id == ui.__type.color_picker then
                        ui.__data[i][v0[1]].ref:set(color_t(v0[2], v0[3], v0[4], v0[5]))
                    else
                        ui.__data[i][v0[1]].ref:set(v0[2])
                    end
                end
            end
        end
    end
    function ui:depend(...)
        local args = {...}
        local result = nil
        for i, v in pairs(args) do
            local con = nil
            if type(v[1]) == "boolean" then
                con = v[1]
            else
                con = v[1].ref:get() == v[2]
            end
            if result ~= nil then
                result = (result and con)
            else
                result = con
            end
        end

        if self.id == -1 then
            menu.set_group_visibility(self.group, result)
        else
            self.ref:set_visible(result)
        end

    end
    return ui
end)()


local tesxt = {
    "If you are switching between",
    "CS:Source and CS:GO 2018 or vice versa",
    "you must press the reset button"
}

local sounds = ui.create("Sounds", 1)
local readme = ui.create("README", 2)
local ui_e = {
    enable = sounds:checkbox("Custom Weapon Sounds"),
    sound_sel = sounds:selection("Weapon Sound Version", {"CS:Source", "CS:GO 2018"}),
    vol = sounds:slider("Weapon Volume",0, 100, 1, 0, "%"),
    reset = sounds:button("Reset Sounds",function()
        engine.execute_cmd("snd_restart")
        print("snd_restart was executed")
        client.log_screen("snd_restart was executed")
    end),
    read1 = readme:text(tesxt[1]),read2 = readme:text(tesxt[2]),read3 = readme:text(tesxt[3]),
}

local function handle_ui()
    local main_state = ui_e.enable:get()
    for i, v in pairs(ui_e) do
        v:depend({(main_state)})
    end
    ui_e.enable:depend({(true)})
end

events.game_event:set(function(e)
    if e.name == "weapon_fire" then
        local me = entity_list.get_local_player()
        local player = entity_list.get_player_from_userid(e.userid)
        if me == player then
            if not ui_e.enable:get() then
                return
            end
            local cur_weapon = me:get_active_weapon():get_name()
            local cur_vol = (" " .. ui_e.vol:get() / 100)
            if ui_e.sound_sel:get() == 1 then
                engine.execute_cmd("playvol weaponsounds_cs_source/" .. cur_weapon .. cur_vol)
            else
                engine.execute_cmd("playvol weaponsounds_csgo_2018/" .. cur_weapon .. cur_vol)
            end
        end
    end
end)

events.render:set(function()
    handle_ui()
end)