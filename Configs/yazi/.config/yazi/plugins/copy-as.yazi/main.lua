local function notify(level, content)
	ya.notify({
		title = "Copy as",
		content = content,
		level = level,
		timeout = 5,
	})
end

local get_target = ya.sync(function()
	local tab = cx.active
	local selected = {}

	for _, url in pairs(tab.selected) do
		selected[#selected + 1] = url
	end

	if #selected > 1 then
		return {
			error = "multiple",
			count = #selected,
		}
	end

	local url = selected[1] or (tab.current.hovered and tab.current.hovered.url)
	if not url then
		return nil
	end

	return {
		cwd = tostring(tab.current.cwd),
		source = tostring(url),
		name = tostring(url):match("([^/]+)$") or tostring(url),
	}
end)

return {
	entry = function()
		ya.emit("escape", { visual = true })

		local target = get_target()
		if not target then
			return notify("warn", "No file selected")
		end

		if target.error == "multiple" then
			return notify("warn", "Select only one file")
		end

		local new_name, event = ya.input({
			title = "Copy as:",
			value = target.name,
			pos = { "top-center", y = 3, w = 40 },
		})
		if event ~= 1 or not new_name or new_name == "" then
			return
		end

		local destination = Url(target.cwd):join(new_name)
		local destination_str = tostring(destination)

		if destination_str == target.source then
			return notify("warn", "Source and destination are the same")
		end

		if fs.cha(destination) then
			return notify("warn", "Destination already exists")
		end

		local output, err = Command("cp"):arg("-a"):arg(target.source):arg(destination_str):output()

		if not output then
			return notify("error", "Failed to run cp: " .. tostring(err))
		end

		if not output.status.success then
			return notify("error", output.stderr:gsub("^cp:%s*", ""))
		end

		ya.emit("reveal", { destination })
	end,
}
