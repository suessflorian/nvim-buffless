local M = {}

-- Checks if a buffer is displayed in any window.
local function is_buffer_in_view(bufnr)
	for _, win_id in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win_id) == bufnr then
			return true
		end
	end
	return false
end

-- Callback for BufRead autocommand.
local function on_bufread()
	vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
		buffer = 0,
		once = true,
		callback = function()
			vim.fn.setbufvar(vim.api.nvim_get_current_buf(), 'bufpersist', 1)
		end
	})
end

-- Callback for BufEnter autocommand.
local function on_bufenter()
	local curbufnr = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_get_option(curbufnr, "buftype") ~= "" then
		return
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if not vim.api.nvim_buf_get_option(bufnr, 'buflisted') or is_buffer_in_view(bufnr) then
			goto continue
		end

		if vim.api.nvim_buf_get_option(bufnr, 'modified') then
			vim.fn.setbufvar(bufnr, 'bufpersist', 1)
			goto continue
		end

		if vim.fn.getbufvar(bufnr, 'bufpersist') ~= 1 then
			vim.cmd('bd ' .. tostring(bufnr))
		end
		::continue::
	end
end

-- Setup function to initialize the autocommands for the plugin.
function M.setup()
	local id = vim.api.nvim_create_augroup("nvim-buffless", { clear = false })

	vim.api.nvim_create_autocmd({ "BufRead" }, {
		group = id,
		pattern = { "*" },
		callback = on_bufread
	})

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = id,
		pattern = { "*" },
		callback = on_bufenter
	})
end

return M
