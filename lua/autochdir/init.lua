local fn = vim.fn
local api = vim.api
local M = {}
local settings = {}
local default_settings = {
	keep_dir = false,
	generic_flags = {'README.md', '.git'},
	flags = {}
}

local function log(...)
	if os.getenv("AUTOCHDIR_LOG") then
		vim.pretty_print(...)
	end
end

local function set_dir(path)
	log('set_dir: ', path)
	vim.cmd.cd(path)
end

local function has_flags(dir, extension_flag)
	local function _has_flags(_dir, flags)
		if not flags then return end

		for _, flag in pairs(flags) do
			local path_exists = fn.glob(string.format('%s/%s', _dir, flag)) ~= ''
			log(string.format('has_flags: %s/%s -> %s', _dir, flag, path_exists))

			if path_exists then
				return true
			end
		end
	end

	return _has_flags(dir, settings.flags[extension_flag]) or
		_has_flags(dir, settings.generic_flags)
end

function M.drill_tree_dir(dir)
	dir = dir or fn.expand('%:p:h')
	local original_dir = dir
	local extension = fn.expand('%:e')

	while dir ~= '/' do
		log('drill_tree_dir:', dir)

		-- if find flags set this directory
		if has_flags(dir, extension) then
			return dir, true
		end

		-- drill path
		dir = vim.fs.dirname(dir)
	end

	return original_dir, false
end

function M.chdir(force_drill)
	local dir = nil

	if force_drill then
		dir = vim.fs.dirname(fn.expand('%:p:h'))
	end

	set_dir(M.drill_tree_dir(dir))
end

function M.setup(_settings)
	_settings = _settings or {}
	settings = vim.tbl_deep_extend('keep', _settings, default_settings)
	local augroup_autochdir = api.nvim_create_augroup('Autochdir', {clear = true})
	local chdir_count = 0

	api.nvim_create_user_command('AutochdirCd', function(args)
		M.chdir(args.bang)
	end, {})

	api.nvim_create_autocmd({'BufEnter'}, {
		group = augroup_autochdir,
		callback = function()
			-- return if current window is floating
			if api.nvim_win_get_config(0).relative ~= '' then
				return
			end

			if settings.keep_dir and chdir_count == 1 then
				return
			end

			local dir, found_flag = M.drill_tree_dir()
			if found_flag then
				chdir_count = 1
			end

			set_dir(dir)
		end
	})
end

return M
