local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	height = 30,
	color = colors.bar.bg,
	y_offset = 5,
	border_color = colors.bar.border,
	shadow = true,
	sticky = true,
	padding_right = 10,
	padding_left = 10,
	blur_radius = 20,
	topmost = "off",
})
