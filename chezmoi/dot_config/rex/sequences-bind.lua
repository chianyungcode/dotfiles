-- Match the sequences emitted by ../kanata/parts/tmux.kbd.
-- Docs: https://www.superlogical.com/rex/docs/customize/key-sequences
-- Remaining Kanata mappings need the connected client's action list:
-- rex client ls; rex -C <client-label> actions
-- Session detach, pane rename/swap, last session/tab/pane, copy mode,
-- worktree picker, and flash are not mapped yet.

-- Reload the Rex configuration.
rex.bind("ctrl+b>r", "client.config.reload")

-- Windows in tmux are tabs in Rex.
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>,", "client.tab.rename")
rex.bind("ctrl+b>shift+7", "client.tab.close")
rex.bind("ctrl+b>n", "client.tab.next")
rex.bind("ctrl+b>p", "client.tab.previous")
rex.bind("ctrl+b>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+b>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+b>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+b>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+b>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+b>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+b>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+b>8", "client.tab.goto", { index = 8 })

-- Toggle the sidebar, matching ../kanata/parts/herdr.kbd.
rex.bind("ctrl+b>b", "client.sidebar.toggle")

-- Session management; shifted keys match S and $ on a US layout.
rex.bind("ctrl+b>s", "session.switch")
rex.bind("ctrl+b>shift+s", "session.new")
rex.bind("ctrl+b>shift+4", "session.rename")
rex.bind("ctrl+b>g", "session.close")

-- Splits: | places panes side by side; - stacks them.
-- Rex matches unshifted keys, so | is shift+backslash on a US layout.
rex.bind("ctrl+b>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+b>-", "pane.split", { direction = "down" })
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")

-- Focus adjacent panes, matching the Kanata pane navigation mappings.
rex.bind("ctrl+b>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+b>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+b>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+b>l", "pane.focus", { direction = "right" })

-- Resize by five, matching the tmux configuration.
rex.bind("ctrl+b>left", "pane.resize", { direction = "left", amount = 5 })
rex.bind("ctrl+b>down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("ctrl+b>up", "pane.resize", { direction = "up", amount = 5 })
rex.bind("ctrl+b>right", "pane.resize", { direction = "right", amount = 5 })

-- Press Ctrl+b twice to forward Ctrl+b to the terminal (including nested tmux).
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
