require("full-border"):setup()
require("hxjump"):setup()
require("eza-preview"):setup({
	default_tree = true,
	level = 2,
	icons = true,
	follow_symlinks = false,
	all = false,
	ignore_glob = { ".git", "node_modules", "target", ".cache" },
	git_ignore = true,
	git_status = false,
})
require("yaziline"):setup({
  filename_max_length = 50,
  filename_truncate_length = 20,
  filename_truncate_separator = "..."
})
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})
require("linemode-plus"):setup({
	date_mode = "custom",
	custom = {
		order = { "day", "month", "year" },
		separator = ".",
		year_digits = 4,
	},
})
require("fs-usage"):setup({
	position = { parent = "Header", align = "RIGHT", order = 2000 },
	format = "both",
	bar = true,
	warning_threshold = 90,
})
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)
Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)
