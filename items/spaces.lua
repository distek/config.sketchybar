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

local function split(str, sep)
	local lines = {}
	for line in str:gmatch("([^" .. sep .. "]*)" .. sep .. "?") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end

	return lines
end

local function getWorkspaces()
	local h = io.popen([[aerospace list-workspaces --all | grep -v scratchpad]])

	if h == nil then
		return
	end

	local result = h:read("*a")
	h:close()

	return split(result, "\n")
end

local function getCurrentWorkspace()
	local h = io.popen([[aerospace list-workspaces --focused]])

	if h == nil then
		return
	end

	local result = h:read("*a")
	h:close()

	return tonumber(result)
end

local function getSpaceWinCount(sid)
	local h = io.popen([[aerospace list-windows --workspace ]] .. sid .. [[ --count]])

	if h == nil then
		return
	end

	local result = h:read("*a")
	h:close()

	return tonumber(result)
end

local function workspaceExists(sid)
	for _, v in ipairs(getWorkspaces()) do
		if tonumber(v) == sid then
			return true
		end
	end

	return false
end

local function getWorkspaceDisplay(sid)
	local h = io.popen([[aerospace list-workspaces --all --format  "%{workspace},%{monitor-id}"| grep -v scratchpad]])

	if h == nil then
		return 1
	end

	local result = h:read("*a")
	h:close()

	for _, v in ipairs(split(result, "\n")) do
		if v ~= "" then
			local s = split(v, ",")
			if tonumber(s[1]) == sid then
				return tonumber(s[2])
			end
		end
	end

	return 1
end

local function getIfOnlyWorkspaceOnDisplay(sid)
	local h = io.popen([[aerospace list-workspaces --all --format  "%{workspace},%{monitor-id}"| grep -v scratchpad]])

	if h == nil then
		return false
	end

	local result = h:read("*a")
	h:close()

	local count = 0
	local monitor = 0
	local resSplit = split(result, "\n")
	for _, v in ipairs(resSplit) do
		if v ~= "" then
			local s = split(v, ",")
			if tonumber(s[1]) == sid then
				monitor = tonumber(s[2])
				break
			end
		end
	end

	for _, v in ipairs(resSplit) do
		if v ~= "" then
			local s = split(v, ",")
			if tonumber(s[2]) == monitor then
				count = count + 1
			end
		end
	end

	return count == 1
end

local function isValid(sid, focused)
	local c = getSpaceWinCount(sid)
	return c > 0 or focused == sid or getIfOnlyWorkspaceOnDisplay(sid)
end

local function space_selection(env)
	local sid = tonumber(env.SID)
	local focused = tonumber(env.FOCUSED_WORKSPACE)
	local c = getSpaceWinCount(sid)
	local color = focused == sid and colors.green or c > 0 and colors.white or colors.bg2

	local d = 1
	if workspaceExists(sid) then
		d = getWorkspaceDisplay(sid)
	end

	local space = {
		associated_space = sid,
		display = d,
		icon = {
			string = sid,
			padding_left = isValid(sid, focused) and 10,
			padding_right = isValid(sid, focused) and 10,
			color = color,
			highlight_color = colors.green,
			drawing = isValid(sid, focused),
		},
		padding_left = isValid(sid, focused) and 2,
		padding_right = isValid(sid, focused) and 2,
		label = {
			string = sid,
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
	}

	sbar.set(env.NAME, space)
end

local focused = getCurrentWorkspace()

local spaces = {}
for i = 1, 10 do
	local c = getSpaceWinCount(i)

	local d = 1
	if workspaceExists(i) then
		d = getWorkspaceDisplay(i)
	end

	local space = sbar.add("space", "space_" .. i, {
		associated_space = i,
		display = d,
		icon = {
			string = i,
			padding_left = isValid(i, focused) and 10,
			padding_right = isValid(i, focused) and 10,
			color = focused == i and colors.green or c > 0 and colors.white or colors.bg2,
			highlight_color = colors.green,
			drawing = c > 0,
		},
		padding_left = isValid(i, focused) and 2,
		padding_right = isValid(i, focused) and 2,
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

	space:subscribe("aerospace_workspace_change", space_selection)
end

sbar.add("bracket", spaces, {
	background = { color = colors.popup.bg, border_color = colors.bg1 },
})
