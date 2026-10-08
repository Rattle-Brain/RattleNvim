-- Git: inline blame (<leader>gb) and branch in the statusline, no plugins

local ns = vim.api.nvim_create_namespace('rs.blame')
local blame_on = false

local function clear(buf)
  if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
end

local function show_blame()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  clear(buf)
  if not blame_on or file == '' or vim.bo[buf].buftype ~= '' then return end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  -- --contents - : blame the buffer as it is now, unsaved edits included
  vim.system(
    { 'git', 'blame', '--porcelain', '-L', line .. ',' .. line, '--contents', '-', '--', vim.fs.basename(file) },
    { cwd = vim.fs.dirname(file), text = true,
      stdin = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n') .. '\n' },
    vim.schedule_wrap(function(r)
      if r.code ~= 0 or not blame_on or vim.api.nvim_get_current_buf() ~= buf
          or vim.api.nvim_win_get_cursor(0)[1] ~= line then return end
      local info = {}
      for k, v in r.stdout:gmatch('\n([%w-]+) ([^\n]*)') do info[k] = v end
      local sha = r.stdout:sub(1, 8)
      local text = sha:match('^0+$') and ' Not committed yet'
        or (' %s • %s • %s • <%s>'):format(info.summary or '',
          os.date('%m-%d-%Y %H:%M:%S', tonumber(info['author-time']) or 0), info.author or '?', sha)
      clear(buf)
      vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
        virt_text = { { text, 'Comment' } }, virt_text_pos = 'eol', hl_mode = 'combine',
      })
    end))
end

vim.api.nvim_create_autocmd({ 'CursorHold', 'BufEnter' }, { callback = show_blame })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter' }, {
  callback = function(ev) clear(ev.buf) end,
})

vim.keymap.set('n', '<leader>gb', function()
  blame_on = not blame_on
  if blame_on then show_blame() else clear(0) end
  vim.notify('Git blame ' .. (blame_on and 'on' or 'off'))
end, { desc = 'Git blame toggle' })

-- Branch name in front of the default statusline
local function update_branch(ev)
  local buf = ev.buf
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = file ~= '' and vim.fs.dirname(file) or vim.fn.getcwd()
  if vim.fn.isdirectory(dir) == 0 then return end
  vim.system({ 'git', 'branch', '--show-current' }, { cwd = dir, text = true }, vim.schedule_wrap(function(r)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local branch = r.code == 0 and vim.trim(r.stdout) or ''
    vim.b[buf].rs_branch = branch ~= '' and (' ' .. branch .. '  ') or ''
    vim.cmd.redrawstatus()
  end))
end
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'DirChanged' }, { callback = update_branch })

local default_statusline = vim.api.nvim_get_option_info2('statusline', {}).default
vim.o.statusline = "%{get(b:,'rs_branch','')}" .. default_statusline
