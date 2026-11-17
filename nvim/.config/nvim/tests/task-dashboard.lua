-- Run with: nvim --headless -u ~/.config/nvim/init.lua -l ~/.config/nvim/tests/task-dashboard.lua
local ok, err = pcall(function()
  assert(vim.fn.exists(':Tasks') == 2, 'Missing :Tasks dashboard command')
  assert(vim.fn.exists(':ObsidianTask') == 2, 'Task plugin not configured')
  assert(vim.fn.maparg(' ot', 'n') ~= '', 'Missing Space ot dashboard shortcut')
  vim.cmd('Tasks')
  local expected = vim.fn.expand('~/Documents/SpazVault/Task Dashboard.md')
  assert(vim.api.nvim_buf_get_name(0) == expected, 'Tasks opened the wrong note')
  assert(vim.wait(30000, function()
    return require('obsidian-tasks.render')._buffer_state[vim.api.nvim_get_current_buf()] ~= nil
  end, 50), 'Dashboard did not render')
  print('PASS: configured startup, dashboard command, shortcut, and real-vault rendering')

  -- All mutation checks run in a disposable vault, never on the user's tasks.
  local root = vim.fn.expand('~/.hermes/cache/scratch/task-dashboard-test-') .. vim.fn.getpid()
  vim.fn.mkdir(root .. '/.obsidian', 'p')
  vim.fn.mkdir(root .. '/zTemplates', 'p')
  vim.fn.writefile({ '# Tasks', '- [ ] Integration open task', '- [x] Integration completed task' }, root .. '/Source.md')
  vim.fn.writefile({ '- [ ] Integration template placeholder' }, root .. '/zTemplates/Daily.md')
  local query = { '# Dashboard', '', '```tasks', 'not done', 'path does not include zTemplates/', 'group by filename', 'sort by path', '```' }
  vim.fn.writefile(query, root .. '/Dashboard.md')
  vim.cmd.edit(vim.fn.fnameescape(root .. '/Dashboard.md'))
  local function task_row(needle)
    for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:find(needle, 1, true) then return row end
    end
  end
  assert(vim.wait(10000, function() return task_row('Integration open task') ~= nil end, 20), 'Fixture task did not render')
  assert(not task_row('Integration completed task'), 'Completed task leaked into open query')
  assert(not task_row('Integration template placeholder'), 'Template placeholder leaked into query')
  vim.api.nvim_win_set_cursor(0, { task_row('Integration open task'), 0 })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Space>tt', true, false, true), 'xt', false)
  assert(vim.wait(5000, function()
    return vim.fn.readfile(root .. '/Source.md')[2]:find('- [x]', 1, true) ~= nil
  end, 20), 'Dashboard toggle did not update source file')
  vim.cmd.write()
  assert(vim.deep_equal(vim.fn.readfile(root .. '/Dashboard.md'), query), 'Rendered rows leaked into saved dashboard')
  vim.cmd('ObsidianTask refresh')
  assert(vim.wait(5000, function() return not task_row('Integration open task') end, 20), 'Completed task remained after refresh')
  vim.cmd('enew!')
  vim.fn.delete(root, 'rf')
  print('PASS: cross-note query, template/completed exclusion, Space tt source write, clean dashboard save, and refresh')
end)
if not ok then
  io.stderr:write(tostring(err) .. '\n')
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
