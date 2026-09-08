-- Free Claude Code - Roblox AI Analyzer
-- Safe analyzer: sends only client-visible Instance metadata to your local FCC server.
-- It does NOT fire remotes, hook metamethods, decompile scripts, or execute generated actions.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LOCAL_URL = "http://127.0.0.1:8000/v1/roblox/analyze"
local MAX_INSTANCES = 6000
local REQUEST = (syn and syn.request) or (http and http.request) or request or http_request

if not REQUEST then
    warn("[FCC] No supported HTTP request function was found in this executor.")
    return
end

local old = CoreGui:FindFirstChild("FCC_RobloxAIAnalyzer")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FCC_RobloxAIAnalyzer"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(650, 470)
frame.Position = UDim2.new(0.5, -325, 0.5, -235)
frame.BackgroundTransparency = 0.08
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "🤖 FCC • ROBLOX AI ANALYZER"
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local analyze = Instance.new("TextButton")
analyze.Size = UDim2.fromOffset(180, 38)
analyze.Position = UDim2.fromOffset(10, 58)
analyze.Text = "🔍 Analizar juego"
analyze.TextSize = 16
analyze.Font = Enum.Font.GothamBold
analyze.Parent = frame
Instance.new("UICorner", analyze).CornerRadius = UDim.new(0, 8)

local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(200, 38)
search.Position = UDim2.fromOffset(200, 58)
search.PlaceholderText = "Buscar..."
search.Text = ""
search.TextSize = 15
search.Font = Enum.Font.Gotham
search.Parent = frame
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -420, 0, 38)
status.Position = UDim2.fromOffset(420, 58)
status.BackgroundTransparency = 1
status.Text = "Listo"
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -110)
list.Position = UDim2.fromOffset(10, 105)
list.BackgroundTransparency = 0.2
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollBarThickness = 6
list.Parent = frame
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local findings = {}

local function clearList()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function addResult(f)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -12, 0, 125)
    card.BackgroundTransparency = 0.08
    card.Parent = list
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -16, 1, -12)
    text.Position = UDim2.fromOffset(8, 6)
    text.BackgroundTransparency = 1
    text.TextWrapped = true
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.Gotham
    text.TextSize = 14
    text.Text = string.format(
        "[%s] %s • %d%%\n\nEvidencia: %s\n\n%s\n\nConcepto: %s",
        tostring(f.category), tostring(f.name), tonumber(f.confidence) or 0,
        table.concat(f.evidence or {}, " | "), tostring(f.explanation or ""),
        tostring(f.concept or "")
    )
    text.Parent = card
end

local function render()
    clearList()
    local q = string.lower(search.Text or "")
    for _, f in ipairs(findings) do
        local hay = string.lower((f.category or "") .. " " .. (f.name or "") .. " " .. (f.explanation or ""))
        if q == "" or string.find(hay, q, 1, true) then addResult(f) end
    end
end

local function snapshot()
    local out = {}
    local count = 0
    for _, obj in ipairs(game:GetDescendants()) do
        count += 1
        if count > MAX_INSTANCES then break end
        table.insert(out, {
            path = obj:GetFullName(),
            name = obj.Name,
            class_name = obj.ClassName,
        })
    end
    return out
end

local function analyzeGame()
    analyze.Text = "⏳ Analizando..."
    analyze.Active = false
    status.Text = "Recopilando estructura visible..."

    task.spawn(function()
        local payload = {
            game_name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
            place_id = tostring(game.PlaceId),
            instances = snapshot(),
        }

        local ok, response = pcall(function()
            return REQUEST({
                Url = LOCAL_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload),
            })
        end)

        if not ok or not response then
            status.Text = "Error HTTP"
            warn("[FCC] Analyzer request failed:", response)
        else
            local success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if success and data then
                findings = data.findings or {}
                render()
                status.Text = string.format("%d resultados", #findings)
            else
                status.Text = "Respuesta inválida"
                warn("[FCC] Invalid analyzer response:", response.Body)
            end
        end

        analyze.Text = "🔍 Analizar juego"
        analyze.Active = true
    end)
end

analyze.MouseButton1Click:Connect(analyzeGame)
search:GetPropertyChangedSignal("Text"):Connect(render)
