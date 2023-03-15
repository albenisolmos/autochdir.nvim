local has_plenary, Scan = pcall(require, 'plenary.scandir')
if not has_plenary then
	error('autochdir requires plenary to work', 1)
	return
end

local fn = vim.fn
local M = {}
local settings = {}
local default_settings = {
	generic_flags = {'README.md', '.git'},
	flags = {}
}

function tbl_has(tbl, value)
	for _, val in pairs(tbl) do
		if val == value then
			return true
		end
	end
end

function set_dir(path)
	vim.cmd(string.format('cd %s', path))
end

function M.drill_tree_dir(path)
	path = path or fn.expand('%:p:h')
	local extension = fn.expand('%:e')
	local break_now = false
	local dirs
	local flags = settings.flags
	local generic_flags = settings.generic_flags
	local regex = vim.regex([[.*\/]])

	while path ~= '/' do
		dirs = Scan.scan_dir(path, {hidden = true, depth = 1})
		print(vim.inspect(dirs))
		for _, _dir in pairs(dirs) do
			local dir = fn.fnamemodify(_dir, ':t')
			print('dir _dir:', dir, _dir)
			if flags[extension] == dir or
				tbl_has(generic_flags, dir)
				then
				set_dir(path)
				break_now = true
				break
			end
		end

		if break_now then
			break
		end

		print(path)
		local start, _end = regex:match_str(path)
		path = path:sub(start, _end)
	end
end

function M.setup(_settings)
	_settings = _settings or {}
	settings = vim.tbl_deep_extend('keep', default_settings, _settings)

	vim.api.nvim_create_user_command('AutochdirCd', function()
		M.drill_tree_dir()
	end, {})
	vim.api.nvim_create_user_command('AutochdirTest', function()
		local regex = vim.regex([[.*\/]])
		local path = '/path/to/dir'
		local start, _end = regex:match_str(path)
		print(path:sub(start, _end))
	end, {})
end

return M
