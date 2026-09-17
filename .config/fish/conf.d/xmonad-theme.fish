# Load in non-interactive shells too: Tide renders segments in Fish workers.
if test -r "$__fish_config_dir/xmonad-theme.fish"
    source "$__fish_config_dir/xmonad-theme.fish"
end

if status is-interactive
    function _xmonad_reload_fish_theme --on-variable _xmonad_fish_theme_revision
        test -r "$__fish_config_dir/xmonad-theme.fish"; or return
        source "$__fish_config_dir/xmonad-theme.fish"

        # Tide compiles colors into fish_prompt and _tide_pwd. Reload those
        # caches as well as the variables, without changing the prompt layout.
        if functions -q _tide_sub_reload
            _tide_sub_reload
            set -e _tide_repaint
        end
        commandline -f repaint 2>/dev/null
    end
end
