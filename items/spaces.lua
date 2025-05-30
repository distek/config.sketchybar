local settings = require("settings")
local colors = require("colors")

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function getSpaceCount()
	local h = io.popen([[yabai -m query --spaces | jq '.[] | .id' | wc -l]])

	if h == nil then
		return
	end

	local result = h:read("*a")
	h:close()

	return tonumber(result)
end

local function getSpaceWinCount(sid)
	local h =
		io.popen([[yabai -m query --windows --space ]] .. sid .. [[ | grep "\"id\":" | wc -l | tr -d '[:space:]']])

	if h == nil then
		return
	end

	local result = h:read("*a")
	h:close()

	return tonumber(result)
end

local function space_selection(env)
	local color = env.SELECTED == "true" and colors.white or colors.bg2

	sbar.set(env.NAME, {
		icon = { highlight = env.SELECTED },
		label = { highlight = env.SELECTED },
		background = { border_color = color },
	})
end

local spaces = {}
for i = 1, getSpaceCount(), 1 do
	local c = getSpaceWinCount(i)
	local space = sbar.add("space", {
		associated_space = i,
		icon = {
			string = i,
			padding_left = 10,
			padding_right = 10,
			color = c > 2 and colors.white or colors.bg2,
			highlight_color = colors.green,
		},
		padding_left = 2,
		padding_right = 2,
		label = {
			string = i,
			padding_right = 20,
			highlight_color = colors.white,
			font = {
				family = settings.font,
				style = "Regular",
				size = 14.0,
			},
			y_offset = -1,
			drawing = false,
		},
	})

	spaces[i] = space.name

	space:subscribe("space_change", space_selection)
end

sbar.add("bracket", spaces, {
	background = { color = colors.popup.bg, border_color = colors.bg1 },
})
