local defaultSettings = {
	enabled = true,
	brightnessAtDarkest = 55,
	brightnessAtLightest = 45,
	debug = true
}

local settings

local function InitSettings()
	DynamicBrightnessSettings = DynamicBrightnessSettings or {}
	settings = DynamicBrightnessSettings
	for k, v in pairs(defaultSettings) do
		if settings[k] == nil then settings[k] = v end
	end
end

local function DebugPrint(...)
	if settings ~= nil and settings.debug then
   	print("|cff33ff99[DynamicBrightness]|r", ...)
	end
end

local function UpdateBrightness()
	if not settings.enabled then return end

	local hour, minute = GetGameTime()
	local time = hour + minute / 60
	local factor = (math.cos((time - 13) / 24 * 2 * math.pi) + 1) / 2
   local value = math.floor(settings.brightnessAtDarkest - factor * (settings.brightnessAtDarkest - settings.brightnessAtLightest) + 0.5)
   SetCVar("Brightness", math.floor(value + 0.5))

	DebugPrint(string.format("Brightness set to %d at %02d:%02d", value, hour, minute))
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, arg1)
	local ev = DynamicBrightnessSettings or {}

	if event == "ADDON_LOADED" and arg1 == "DynamicBrightness" then
    	DebugPrint("Addon loaded")
    	InitSettings()
		local category = Settings.RegisterVerticalLayoutCategory("DynamicBrightness")

		local function AddSlider(key, label, tooltip, min, max, step)
		    	local setting = Settings.RegisterAddOnSetting(category, "DynamicBrightness_" .. key, key, settings, "number", label, defaultSettings[key])
		    	setting:SetValueChangedCallback(function() UpdateBrightness() end)
		    	local options = Settings.CreateSliderOptions(min, max, step)
		    	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
		    	Settings.CreateSlider(category, setting, options, tooltip)
		end

		local enabled = Settings.RegisterAddOnSetting(category, "DynamicBrightness_enabled", "enabled", settings, "boolean", "Enabled", defaultSettings.enabled)
		Settings.CreateCheckbox(category, enabled, "Turn automatic brightness on or off")

		AddSlider("brightnessAtLightest", "Daytime brightness", "Brightness at the brightest part of the day", 0, 100, 1)
		AddSlider("brightnessAtDarkest", "Nighttime brightness", "Brightness at the darkest part of the day", 0, 100, 1)

		local debugSetting = Settings.RegisterAddOnSetting(category, "DynamicBrightness_debug", "debug", settings, "boolean", "Debug", defaultSettings.debug)
		Settings.CreateCheckbox(category, debugSetting, "Enable debug mode")

		Settings.RegisterAddOnCategory(category)
	elseif event == "PLAYER_LOGIN" then
		C_Timer.NewTicker(300, UpdateBrightness)
		UpdateBrightness()
	end
end)