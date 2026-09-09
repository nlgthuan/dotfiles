local M = {}

_G.java_test_pane_id = _G.java_test_pane_id or nil

M.run_java_test_in_tmux = function()
  -- 1. Ensure we are inside Tmux
  if os.getenv("TMUX") == nil then
    vim.notify("Not in a tmux session!", vim.log.levels.ERROR)
    return
  end

  -- 2. Extract Class and Method using Tree-sitter
  local node = vim.treesitter.get_node()
  if not node then
    vim.notify("No code node found under cursor.", vim.log.levels.WARN)
    return
  end

  local method_name = nil
  local class_name = nil

  local current = node
  while current do
    local type = current:type()
    if type == "method_declaration" and not method_name then
      for child in current:iter_children() do
        if child:type() == "identifier" then
          method_name = vim.treesitter.get_node_text(child, 0)
          break
        end
      end
    end
    if type == "class_declaration" then
      for child in current:iter_children() do
        if child:type() == "identifier" then
          class_name = vim.treesitter.get_node_text(child, 0)
          break
        end
      end
      break
    end
    current = current:parent()
  end

  local target = ""
  if class_name and method_name then
    target = string.format("%s#%s", class_name, method_name)
  elseif class_name then
    target = class_name
  else
    vim.notify("Could not find a Java class under cursor.", vim.log.levels.WARN)
    return
  end

  -- 3. Check if our stored pane is still open and valid
  local pane_exists = false
  if _G.java_test_pane_id then
    -- Ask tmux if this explicit pane ID still exists in the environment
    local check_cmd = string.format("tmux has-session -t %s 2>/dev/null", _G.java_test_pane_id)
    pane_exists = os.execute(check_cmd) == 0
  end

  -- 4. If the pane doesn't exist, split the window and capture its unique ID
  if not pane_exists then
    -- -P prints the information, -F formats it to return ONLY the clean raw ID string (e.g. "%2")
    local split_cmd = "tmux split-window -h -P -F '#{pane_id}'"
    local new_pane_id = vim.fn.system(split_cmd)

    -- Strip any trailing newlines from the terminal output and save it
    _G.java_test_pane_id = string.gsub(new_pane_id, "%s+", "")
  end

  -- 5. Construct the Maven command
  local maven_cmd = string.format("clear && mvn clean test -Dtest=%s", target)

  -- 6. Remotely send the command straight to that explicit ID
  local send_keys_cmd = string.format("tmux send-keys -t %s \"%s\" C-m", _G.java_test_pane_id, maven_cmd)
  vim.fn.system(send_keys_cmd)
end

return M
