require("full-border"):setup()
require("starship"):setup({config_file = "~/.config/yazi/starship_for_yazi.toml",})
require("yaziline"):setup({
  filename_max_length = 50,
  filename_truncate_length = 20,
  filename_truncate_separator = "..."
})
