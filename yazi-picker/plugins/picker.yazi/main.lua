--- @since 25.5.31
--- @sync entry

-- Picker mode is selected by the launcher script via $YAZI_PICKER_MODE:
--   file  (default) - pick a single file
--   files            - pick one or more files
--   dir              - pick a single directory
local function mode() return os.getenv("YAZI_PICKER_MODE") or "file" end

-- Quits yazi and writes `urls` to --chooser-file, via the built-in
-- non-interactive `open` command (see yazi-actor/src/mgr/open.rs).
local function pick(urls) ya.emit("open", { targets = urls }) end

-- Enter on a directory navigates into it; Enter on a file picks it.
local function smart_enter()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		ya.emit("enter", {})
	elseif h then
		pick({ h.url })
	end
end

-- Enter on a directory picks that directory. Enter on a file, or in an
-- empty directory (nothing hovered), picks the current directory instead.
local function enter_dir_mode()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
		pick({ h.url })
	else
		pick({ cx.active.current.cwd })
	end
end

-- With an active selection, Enter picks the whole selection. Otherwise it
-- falls back to the single-file behavior (smart enter).
local function enter_files_mode()
	local selected = {}
	for _, f in pairs(cx.active.selected) do
		selected[#selected + 1] = f.url
	end
	if #selected > 0 then
		pick(selected)
	else
		smart_enter()
	end
end

local function on_enter()
	local m = mode()
	if m == "dir" then
		enter_dir_mode()
	elseif m == "files" then
		enter_files_mode()
	else
		smart_enter()
	end
end

-- Selection (space / select-all / invert) is only meaningful in "files"
-- mode; it's a no-op everywhere else, e.g. single-file selection via space
-- is not possible.
local function on_select(cmd, args)
	if mode() == "files" then
		ya.emit(cmd, args or {})
	end
end

local M = {}

function M:entry(job)
	local action = job.args[1]
	if action == "toggle" then
		on_select("toggle", {})
	elseif action == "toggle_all" then
		on_select("toggle_all", { state = job.args[2] })
	else
		on_enter()
	end
end

return M
