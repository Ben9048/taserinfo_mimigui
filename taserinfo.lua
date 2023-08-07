script_name('TaserInfo')
script_author('Ben_Puls')
script_description('Taser and Siren info')
local imgui = require 'mimgui'
local keys = require 'vkeys'
local ini = require 'inicfg'
local cfg = ini.load({ pos = { posX = 500, posY = 500 }, taser = { lock = true, size = 20,  style = 69}, siren = { lock = true }, infobar = { lock = false } }, 'taserinfo.ini')
local move = false
local font = renderCreateFont('Arial', cfg.taser.size, cfg.taser.style)
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8 
local faicons = require('fAwesome6')
local new = imgui.new       
local SliderOne = new.int(cfg.taser.size)
local SliderTwo = new.int(cfg.taser.style)
local taser = new.bool(cfg.taser.lock)
local siren = new.bool(cfg.siren.lock)     
local infobar = new.bool(cfg.infobar.lock)                          
local renderWindow = new.bool()
local sizeX, sizeY = getScreenResolution()
local info = new.bool(false)
local fonta = {}
local toggle = new.bool(cfg.taser.lock)


imgui.OnInitialize(function()
  
    imgui.DarkTheme()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\calibri.ttf'
    imgui.GetIO().Fonts:Clear() -- Удаляем стандартный шрифт на 14
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 15.0, nil, glyph_ranges) -- этот шрифт на 15 будет стандартным
    -- дополнительные шриты:
    fonta[25] = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 25.0, nil, glyph_ranges)
    fonta[40] = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 40.0, nil, glyph_ranges)
end)
imgui.OnFrame(function() return renderWindow[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
    imgui.DarkTheme()
    imgui.Begin("TaserInfo by Ben Puls", renderWindow,  imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    imgui.PushFont(fonta[25])
    imgui.CenterText('TaserInfo by Ben Puls')
    imgui.PopFont()

    if imgui.Button(u8' Положение') then
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8'Изменить положение текста')
            imgui.EndTooltip()
            move = not move
        end
    end
    imgui.SameLine()
    if imgui.Checkbox('Taser', taser) then
        cfg.taser.lock = not cfg.taser.lock
        ini.save(cfg, 'taserinfo.ini')
    end
    imgui.SameLine()
    if imgui.Checkbox('Siren', siren) then
        cfg.siren.lock = not cfg.siren.lock
        ini.save(cfg, 'taserinfo.ini')
    end
    imgui.SameLine()
    imgui.Separator()


    if imgui.SliderInt(u8' Размер шрифта', SliderOne, 3, 35) then
        cfg.taser.size = SliderOne[0]
        ini.save(cfg, 'taserinfo.ini')
        font = renderCreateFont('Arial', cfg.taser.size, cfg.taser.style)
    end
    if imgui.SliderInt(u8' Стиль текста', SliderTwo, 1, 50) then
        cfg.taser.style = SliderTwo[0]
        ini.save(cfg, 'taserinfo.ini')
        font = renderCreateFont('Arial', cfg.taser.size, cfg.taser.style)
    end
    imgui.Separator()
    if imgui.CollapsingHeader(u8' Параметры') then
        imgui.TextWrapped(u8'Taser: ' .. (cfg.taser.lock and u8"Включен" or u8"Выключен")..'\nSiren: ' .. (cfg.siren.lock and u8"Включен" or u8"Выключен")..'\nSize: '.. cfg.taser.size .. '\nStyle: '.. cfg.taser.style ..'\nPosition oX, oY: '..cfg.pos.posX..', '..cfg.pos.posY)
        imgui.Separator()
    end
    if imgui.CollapsingHeader(u8' Описание') then
        imgui.TextWrapped(u8'Скрипт отображает наличие Тайзера у персонажа.\nИ также проверяет наличие сирены.')
        imgui.Separator()
    end
    if imgui.CollapsingHeader(u8' Команды') then
        imgui.TextWrapped(u8'/taserinfo - Основная команда\n/tasers - Включение/выключение тайзера\n/sirens - Включение/выключение сирены \n/taserpos - Изменение положения индикаторов\n/tasersize 3-35 - Изменение размеров текста\n/taserstyle 1-73 - Изменение стиля текста')
        imgui.Separator()
    end
    imgui.End()
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{58c9b1}[TaserInfo by Ben Puls] {ffffff}успешно запущен (/taserinfo, /tasers, /sirens, /taserpos, /tasersize, /taserstyle)", -1)
    print("Has been started by Ben Puls")
    sampRegisterChatCommand('taserpos', function() move = not move end)
    sampRegisterChatCommand("taserinfo", function() renderWindow[0] = not renderWindow[0] end)
    sampRegisterChatCommand("tasers", function() cfg.taser.lock = not cfg.taser.lock ini.save(cfg, 'taserinfo.ini')
        sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Отображение тайзера: " .. (cfg.taser.lock and "{AAFFAA}Включено" or "{FFAAAA}Выключено"), 0xEEEEEE)
    end)
    sampRegisterChatCommand("tasersize", function(number) number = tonumber(number)
        if number ~= nil and (number >= 3 and number <= 35) then
            cfg.taser.size = number         
            ini.save(cfg, 'taserinfo.ini')
            font = renderCreateFont('Arial', cfg.taser.size, cfg.taser.font)
            sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Новый размер шрифта: {AAFFAA}" .. cfg.taser.size, 0xEEEEEE)
        else
            sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Используйте: {AAFFAA}/tasersize 3-35", 0xEEEEEE)
        end
    end)
    sampRegisterChatCommand("taserstyle", function(number)
        if tonumber(number) >= 1 and tonumber(number) <= 50 then
            cfg.taser.font = number         
            ini.save(cfg, 'taserinfo.ini')
            font = renderCreateFont('Arial', cfg.taser.size, cfg.taser.font)
            sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Новый стиль текста: {AAFFAA}" .. cfg.taser.font, 0xEEEEEE)
        else
            sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Используйте: {AAFFAA}/taserstyle 1-50", 0xEEEEEE)
        end
    end)
    sampRegisterChatCommand("sirens", function() cfg.siren.lock = not cfg.siren.lock ini.save(cfg, 'taserinfo.ini')
        sampAddChatMessage("{58c9b1}[TaserInfo]{FFFFFF} Отображение сирен: " .. (cfg.siren.lock and "{AAFFAA}Включено" or "{FFAAAA}Выключено"), 0xEEEEEE)
    end)

    while true do wait(0)     
        if move then
            showCursor(true)
            cfg.pos.posX, cfg.pos.posY = getCursorPos()
            if isKeyJustPressed(1) then
                if ini.save(cfg, 'taserinfo.ini') then
                    sampAddChatMessage('{58c9b1}[TaserInfo]{FFFFFF} Новое положение задано (oX, oY): {AAFFAA}'.. cfg.pos.posX..', '..cfg.pos.posY, -1)
                    move = false
                    showCursor(false)
                end
            end
        end
        if cfg.taser.lock then
            renderFontDrawText(font,'{FFFFFF}Taser: '..(getCurrentCharWeapon(1) == 23 and '{18EC18}ON!' or '{FF0000}OFF'), cfg.pos.posX, cfg.pos.posY, 0xFFFFFF00)
        end
        if cfg.siren.lock and isCharInAnyCar(PLAYER_PED) then
            renderFontDrawText(font,'{FFFFFF}Siren: '..(isCarSirenOn(storeCarCharIsInNoSave(PLAYER_PED)) and '{18EC18}ON!' or '{FF0000}OFF'), cfg.pos.posX, cfg.pos.posY + 30, 0xFFFFFF00)
        end

    end
end
function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1
    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 13
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5
    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.67, 0.23, 0.23, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.67, 0.23, 0.23, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.67, 0.23, 0.23, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.67, 0.23, 0.23, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.67, 0.23, 0.23, 0.70)
end

function imgui.theme()
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.07, 0.4) -- четвертое значение отвечает за прозрачность окна
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 0.4)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.07, 0.07, 0.07, 0.4)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.07, 0.07, 0.07, 0.4)

end

function onWindowMessage(m, p)
    if p == 0x1B and renderWindow[0] then
        consumeWindowMessage()
        renderWindow[0] = false
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.ToggleButton(str_id, bool)
    local rBool = false

    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end

    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end

    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()

    local height = imgui.GetTextLineHeightWithSpacing()
    local width = height * 1.70
    local radius = height * 0.50
    local ANIM_SPEED = type == 2 and 0.10 or 0.15
    local butPos = imgui.GetCursorPos()

    if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
        bool[0] = not bool[0]
        rBool = true
        LastActiveTime[tostring(str_id)] = os.clock()
        LastActive[tostring(str_id)] = true
    end

    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 8, butPos.y + 2.5))
    imgui.Text( str_id:gsub('##.+', '') )

    local t = bool[0] and 1.0 or 0.0

    if LastActive[tostring(str_id)] then
        local time = os.clock() - LastActiveTime[tostring(str_id)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool[0] and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(str_id)] = false
        end
    end

    local col_circle = bool[0] and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])) or imgui.ColorConvertFloat4ToU32(imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.TextDisabled]))
    dl:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg]), height * 0.5)
    dl:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, col_circle)
    return rBool
end