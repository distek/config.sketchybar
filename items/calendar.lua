local settings = require("settings")

local cal = sbar.add("item", {
	icon = {
		padding_right = 8,
		font = {
			style = settings.font,
			size = 14.0,
		},
	},
	label = {
		width = 45,
		align = "right",
		font = {
			style = settings.font,
			size = 14.0,
		},
	},
	position = "right",
	update_freq = 15,
})

local function update()
	local date = os.date("%Y/%m/%d")
	local time = os.date("%H:%M")
	cal:set({ icon = date, label = time })
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)

cal:subscribe("mouse.clicked", function(env)
	sbar.exec("yabai-scratchpad -n calendar")
end)
