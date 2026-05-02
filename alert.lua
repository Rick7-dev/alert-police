script_name("Alert Police")
script_author("Rick7")
script_version("4.1")

require "lib.moonloader"
require "sampfuncs"

local imgui = require "mimgui"
local encoding = require "encoding"

encoding.default = "CP1251"
u8 = encoding.UTF8

local main_window = imgui.new.bool(false)

local enable_alert = imgui.new.bool(true)
local radius = imgui.new.float(150.0)

-- posição do alerta
local pos_x = imgui.new.float(0.50)
local pos_y = imgui.new.float(0.50)

-- cor do texto
local text_red = imgui.new.float(1.0)
local text_green = imgui.new.float(0.0)
local text_blue = imgui.new.float(0.0)

local font
local alpha = 0
local active = false
local current_text = ""
local current_color = 0xFFFFFFFF

local policeSkins = {
    [280]=true,[281]=true,[282]=true,[283]=true,
    [284]=true,[285]=true,[286]=true,[287]=true,[288]=true
}

function main()
    repeat wait(0) until isSampAvailable()

    font = renderCreateFont("Arial", 18, 5)

    sampRegisterChatCommand("irota", checkPolice)

    sampRegisterChatCommand("rrmenu", function()
        main_window[0] = not main_window[0]
    end)

    while true do
        wait(0)

        if active and alpha > 0 then
            drawAlert()
        end
    end
end

function checkPolice()

    if not enable_alert[0] then
        return
    end

    if isPoliceNearby() then

        local r = math.floor(text_red[0] * 255)
        local g = math.floor(text_green[0] * 255)
        local b = math.floor(text_blue[0] * 255)

        local color =
            bit.bor(
                0xFF000000,
                bit.lshift(r, 16),
                bit.lshift(g, 8),
                b
            )

        animate("MOVIMENTO PROXIMO!", color, 3, 1800)

    else
        animate("AREA LIMPA", 0xFFFFFFFF, 1, 2200)
    end
end

function isPoliceNearby()

    local myPed = PLAYER_PED

    if not doesCharExist(myPed) then
        return false
    end

    local mx, my, mz = getCharCoordinates(myPed)
    local _, myId = sampGetPlayerIdByCharHandle(myPed)

    for i = 0, sampGetMaxPlayerId(false) do

        if sampIsPlayerConnected(i) and i ~= myId then

            local result, ped =
                sampGetCharHandleBySampPlayerId(i)

            if result and doesCharExist(ped)
            and not isCharDead(ped) then

                if policeSkins[getCharModel(ped)] then

                    local x, y, z =
                        getCharCoordinates(ped)

                    local dist =
                        getDistanceBetweenCoords3d(
                            mx, my, mz,
                            x, y, z
                        )

                    if dist <= radius[0] then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function animate(msg, col, repeats, duration)

    lua_thread.create(function()

        current_text = msg
        current_color = col
        active = true

        for _ = 1, repeats do

            for a = 0, 255, 15 do
                alpha = a
                wait(8)
            end

            wait(duration / repeats - 350)

            for a = 255, 0, -15 do
                alpha = a
                wait(8)
            end

            wait(80)
        end

        alpha = 0
        active = false
    end)
end

function drawAlert()

    local sx, sy = getScreenResolution()

    local width =
        renderGetFontDrawTextLength(
            font,
            current_text
        )

    local height =
        renderGetFontDrawHeight(font)

    local x =
        (sx * pos_x[0]) - (width / 2)

    local y =
        (sy * pos_y[0]) - (height / 2)

    local finalColor =
        bit.bor(
            bit.band(current_color, 0x00FFFFFF),
            bit.lshift(alpha, 24)
        )

    local shadow =
        bit.bor(
            0x000000,
            bit.lshift(alpha, 24)
        )

    renderFontDrawText(
        font,
        current_text,
        x + 2,
        y + 2,
        shadow
    )

    renderFontDrawText(
        font,
        current_text,
        x,
        y,
        finalColor
    )
end

function aplicarEstilo()

    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col

    colors[clr.WindowBg] =
        imgui.ImVec4(0.10, 0.10, 0.14, 0.94)

    colors[clr.ChildBg] =
        imgui.ImVec4(0.15, 0.15, 0.20, 0.90)

    colors[clr.PopupBg] =
        imgui.ImVec4(0.12, 0.12, 0.16, 0.95)

    colors[clr.TitleBg] =
        imgui.ImVec4(0.25, 0.25, 0.35, 1.00)

    colors[clr.TitleBgActive] =
        imgui.ImVec4(0.35, 0.35, 0.45, 1.00)

    colors[clr.Button] =
        imgui.ImVec4(0.25, 0.40, 0.70, 0.80)

    colors[clr.ButtonHovered] =
        imgui.ImVec4(0.30, 0.50, 0.85, 1.00)

    colors[clr.ButtonActive] =
        imgui.ImVec4(0.20, 0.35, 0.60, 1.00)

    colors[clr.Header] =
        imgui.ImVec4(0.25, 0.40, 0.70, 0.60)

    colors[clr.HeaderHovered] =
        imgui.ImVec4(0.30, 0.50, 0.85, 0.80)

    colors[clr.HeaderActive] =
        imgui.ImVec4(0.35, 0.55, 0.90, 0.80)

    colors[clr.FrameBg] =
        imgui.ImVec4(0.18, 0.18, 0.24, 0.94)

    colors[clr.FrameBgHovered] =
        imgui.ImVec4(0.25, 0.40, 0.70, 0.60)

    colors[clr.FrameBgActive] =
        imgui.ImVec4(0.30, 0.50, 0.85, 0.70)

    colors[clr.CheckMark] =
        imgui.ImVec4(0.30, 0.50, 0.85, 1.00)

    style.WindowRounding = 12.0
    style.ChildRounding = 8.0
    style.FrameRounding = 6.0
    style.PopupRounding = 8.0
    style.ScrollbarRounding = 12.0
    style.GrabRounding = 6.0

    style.WindowPadding =
        imgui.ImVec2(16, 16)

    style.FramePadding =
        imgui.ImVec2(10, 8)

    style.ItemSpacing =
        imgui.ImVec2(12, 8)
end

imgui.OnFrame(
function()
    return main_window[0]
end,

function()

    aplicarEstilo()

    imgui.SetNextWindowSize(
        imgui.ImVec2(420, 520),
        imgui.Cond.FirstUseEver
    )

    imgui.SetNextWindowPos(
        imgui.ImVec2(50, 50),
        imgui.Cond.FirstUseEver
    )

    imgui.Begin(
        "Alert Police - By Rick7",
        main_window,
        bit.bor(imgui.WindowFlags.NoResize)
    )

    imgui.TextColored(
        imgui.ImVec4(0.2, 0.8, 1.0, 1.0),
        "ALERTA DE POLICIA"
    )

    imgui.SameLine()

    imgui.SetCursorPosX(300)

    imgui.TextDisabled("(v4.1)")

    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    imgui.TextColored(
        imgui.ImVec4(1,1,1,1),
        "CONFIGURACOES"
    )

    imgui.Checkbox(
        "Ativar alerta",
        enable_alert
    )

    imgui.Spacing()

    imgui.TextColored(
        imgui.ImVec4(1,1,1,1),
        "RAIO DE DETECCAO"
    )

    imgui.SliderFloat(
        "##radius",
        radius,
        20.0,
        500.0,
        "%.0f"
    )

    imgui.Spacing()

    imgui.TextColored(
        imgui.ImVec4(1,1,1,1),
        "POSICAO DO ALERTA"
    )

    imgui.SliderFloat(
        "Posicao X",
        pos_x,
        0.0,
        1.0,
        "%.2f"
    )

    imgui.SliderFloat(
        "Posicao Y",
        pos_y,
        0.0,
        1.0,
        "%.2f"
    )

    imgui.Spacing()

    imgui.TextColored(
        imgui.ImVec4(1,1,1,1),
        "COR DO ALERTA"
    )

    imgui.SliderFloat("R", text_red, 0.0, 1.0)
    imgui.SliderFloat("G", text_green, 0.0, 1.0)
    imgui.SliderFloat("B", text_blue, 0.0, 1.0)

    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    if active then

        if imgui.Button(
            "ALERTA ATIVO",
            imgui.ImVec2(-1, 45)
        ) then
        end

    else

        if imgui.Button(
            "TESTAR ALERTA",
            imgui.ImVec2(-1, 45)
        ) then

            local r = math.floor(text_red[0] * 255)
            local g = math.floor(text_green[0] * 255)
            local b = math.floor(text_blue[0] * 255)

            local color =
                bit.bor(
                    0xFF000000,
                    bit.lshift(r, 16),
                    bit.lshift(g, 8),
                    b
                )

            animate("MOVIMENTO PROXIMO", color, 3, 1800)
        end
    end

    imgui.Spacing()

    imgui.TextColored(
        imgui.ImVec4(1.0, 1.0, 0.0, 1.0),
        "Comandos:"
    )

    imgui.BulletText("/irota")
    imgui.BulletText("/rrmenu")

    imgui.End()
end)

function onScriptTerminate()
    if font then
        renderFontDestroy(font)
    end
end