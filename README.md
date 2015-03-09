Vim Fullscreen
==============

Fullscreen mode plugin for VIM.

I have seen that meanwhile there are a few of them. Pick whatever you like 
best. I had my reasons to write this, mostly for Windows, because I had issues 
with other plugins: the Vim window would still be covered by the taskbar at 
times, and an ugly grey border around the VIM text area window was left.

Features
--------

- Toggle Vim window fullscreen
- Maximize Vim window (I like to do this on Windows on startup)
- Works with MacVim and GVim on Windows (no fullscreen support on other 
  systems yet)

Requirements
------------

On Windows, "true" fullscreen and maximize functionality requires the Python 
Win32 Extensions installed. Get them here:

[Python Win32 Extensions on SourceForge](http://sourceforge.net/projects/pywin32/)

You will probably have to install the one matching the architecture of your 
VIM.

Installation
------------

Please use your favorite plugin manager. Depending on the plugin manager used, 
the line to be added to your `.vimrc` should be one of:

    NeoBundle 'ruedigerha/vim-fullscreen', { 'gui' : 1 }
    Plug 'ruedigerha/vim-fullscreen'
    Plugin 'ruedigerha/vim-fullscreen'

Usage
-----

Offers two commands:

- `ToggleFullscreen` (key mapping: `<Plug>(fullscreen_toggle)`)
- `MaximizeWindow` (key mapping: `<Plug>(fullscreen_maximize)`)

They do what the names suggest. No surprises there.

The default key mapping is `Ctrl-Return` because it is slightly easier to type 
than `F11` on a notebook. You can map a different key for toggling fullscreen 
mode on and off:

    let g:vimfullscreen_default_keymap = 0
    nmap <silent> <F11> <Plug>(fullscreen_toggle)

If you wish to maximize the VIM window on startup:

    au GUIEnter * :MaximizeWindow

