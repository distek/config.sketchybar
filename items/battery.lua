local icons = require("icons")

local battery = sbar.add("item", {
	position = "right",
	icon = {
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
	label = {
		drawing = false,
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"

		local _, _, charge = batt_info:find("(%d+)%%")
		local chargeStr = "" .. charge .. "%"

		if string.find(batt_info, "AC Power") then
			icon = icons.battery.charging
		else
			local chargeN = tonumber(charge)

			if chargeN > 80 then
				icon = icons.battery._100
			elseif chargeN > 60 then
				icon = icons.battery._75
			elseif chargeN > 40 then
				icon = icons.battery._50
			elseif chargeN > 20 then
				icon = icons.battery._25
			else
				icon = icons.battery._0
			end
		end
		battery:set({ icon = icon, label = { string = chargeStr, drawing = true } })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
