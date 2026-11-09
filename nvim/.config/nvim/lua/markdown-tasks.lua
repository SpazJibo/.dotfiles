-- Obsidian-style checkbox toggle (<leader>x) for ANY markdown file.
-- Inside the SpazVault workspace, obsidian-markdown.lua's own 'enter_note'
-- callback already binds <leader>x via `Obsidian toggle_checkbox` (richer:
-- respects checkbox.order, LSP-aware, etc.) -- skip there to avoid clobbering it.
local vault = vim.fn.expand('~/Documents/SpazVault')

local function in_vault(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  return path:sub(1, #vault) == vault
end

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()

  -- "- [ ] text" / "* [x] text" / "+ [X] text"
  local bullet, box, rest = line:match('^(%s*[-*+]%s+)%[([ xX])%]%s*(.*)$')
  if bullet then
    local new_box = (box == ' ') and 'x' or ' '
    vim.api.nvim_set_current_line(bullet .. '[' .. new_box .. '] ' .. rest)
    return
  end

  -- "1. [ ] text" / "2) [x] text"
  local num_bullet, nbox, nrest = line:match('^(%s*%d+[.)]%s+)%[([ xX])%]%s*(.*)$')
  if num_bullet then
    local new_box = (nbox == ' ') and 'x' or ' '
    vim.api.nvim_set_current_line(num_bullet .. '[' .. new_box .. '] ' .. nrest)
    return
  end

  -- Plain bullet/numbered list item with no checkbox yet -> create one (unchecked).
  local plain_bullet, prest = line:match('^(%s*[-*+]%s+)(.*)$')
  if plain_bullet then
    vim.api.nvim_set_current_line(plain_bullet .. '[ ] ' .. prest)
    return
  end
  local plain_num, pnrest = line:match('^(%s*%d+[.)]%s+)(.*)$')
  if plain_num then
    vim.api.nvim_set_current_line(plain_num .. '[ ] ' .. pnrest)
    return
  end

  -- Not a list item at all -> turn the whole line into a new checkbox item.
  local indent, text = line:match('^(%s*)(.*)$')
  vim.api.nvim_set_current_line(indent .. '- [ ] ' .. text)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('markdown-tasks', { clear = true }),
  pattern = 'markdown',
  callback = function(ev)
    if in_vault(ev.buf) then return end
    vim.keymap.set('n', '<leader>x', toggle_checkbox, { buffer = ev.buf, desc = 'Toggle/create checkbox' })
  end,
})
