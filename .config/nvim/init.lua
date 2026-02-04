-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.g.autoformat = false

vim.cmd([[
  highlight Normal ctermbg=none guibg=none
  highlight NormalNC ctermbg=none guibg=none
  highlight EndOfBuffer ctermbg=none guibg=none
  highlight SignColumn ctermbg=none guibg=none
  highlight VertSplit ctermbg=none guibg=none
]])

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd([[
      highlight Normal ctermbg=none guibg=none
      highlight NormalNC ctermbg=none guibg=none
      highlight EndOfBuffer ctermbg=none guibg=none
      highlight SignColumn ctermbg=none guibg=none
      highlight VertSplit ctermbg=none guibg=none
    ]])
  end,
})

local function open_floating_term(cmd)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "floatterm"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  if not cmd or cmd == "" then
    cmd = vim.o.shell
  end
  vim.fn.termopen(cmd)

  vim.cmd("startinsert")

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true })
end

-- Run single file
vim.api.nvim_create_user_command("Run", function()
  local ft = vim.bo.filetype
  local fname = vim.fn.expand("%")
  local cwd = vim.fn.getcwd()
  local venv_python = cwd .. "/.venv/bin/python"

  local cmake_target = (function()
    local path = vim.fn.getcwd() .. "/CMakeLists.txt"
    if vim.fn.filereadable(path) == 0 then
      return nil
    end
    for line in io.lines(path) do
      local target = line:match("add_executable%s*%(%s*([%w_%-]+)")
      if target then
        return target
      end
    end
  end)()

  local cmake = (cmake_target ~= nil and ("cmake -S . -B build && cmake --build build && ./build/" .. cmake_target))
    or nil

  local cmd = {
    python = ((vim.fn.filereadable(venv_python) == 1 and venv_python) or "python3") .. " " .. fname,
    lua = "lua " .. fname,
    javascript = "node " .. fname,
    typescript = "ts-node " .. fname,
    c = cmake or ("clang " .. vim.fn.glob("*.c") .. " -o /tmp/a.out && /tmp/a.out"),
    cpp = cmake or ("clang++ " .. vim.fn.glob("*.cpp") .. " -o /tmp/a.out && /tmp/a.out"),
    sh = "bash " .. fname,
    zsh = "zsh" .. fname,
    rust = "rustc " .. fname .. " -o /tmp/a.out && /tmp/a.out",
  }

  local run_cmd = cmd[ft]

  if run_cmd then
    vim.cmd("write")
    open_floating_term(run_cmd)
  else
    print("Unsupported file type: " .. ft)
  end
end, {})
