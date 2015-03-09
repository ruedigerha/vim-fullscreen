" VIM Fullscreen Plugin
" Copyright (C) 2015 Ruediger Hanke
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
" 1. Redistributions of source code must retain the above copyright
" notice, this list of conditions and the following disclaimer.
" 2. Redistributions in binary form must reproduce the above copyright
" notice, this list of conditions and the following disclaimer in the
" documentation and/or other materials provided with the distribution.
" 3. Neither the name of the organization nor the
" names of its contributors may be used to endorse or promote products
" derived from this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY Ruediger Hanke ''AS IS'' AND ANY
" EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL Ruediger Hanke BE LIABLE FOR ANY
" DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
" ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
" SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

let s:restore_data = {}

" TODO: There isn't much error handling code here

function fullscreen#windows#maximize()
  if fullscreen#windows#is_active()
    return
  endif
python <<
import win32api
import win32con
import win32gui

top_wnd = win32gui.FindWindow('Vim', None)
win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_MAXIMIZE, 0)
.
endfunction

function fullscreen#windows#activate()
python <<
import vim
import win32api
import win32con
import win32gui

bkgndWndClass = win32gui.WNDCLASS()
bkgndWndClass.hbrBackground = win32gui.GetStockObject(win32con.BLACK_BRUSH)
bkgndWndClass.hCursor = win32gui.LoadCursor(0, win32con.IDC_ARROW)
bkgndWndClass.lpszClassName = 'VimFullscreenBkgnd'
class_atom = win32gui.RegisterClass(bkgndWndClass)

top_wnd = win32gui.FindWindow('Vim', None)
mon = win32api.MonitorFromRect(win32gui.GetWindowRect(top_wnd), win32con.MONITOR_DEFAULTTONEAREST)
(x, y, dx, dy) = win32api.GetMonitorInfo(mon)['Monitor']
old_window_placement = win32gui.GetWindowPlacement(top_wnd)
old_style = win32api.GetWindowLong(top_wnd, win32con.GWL_STYLE)
old_exstyle = win32api.GetWindowLong(top_wnd, win32con.GWL_EXSTYLE)
win32api.SetWindowLong(top_wnd, win32con.GWL_STYLE, old_style & ~(win32con.WS_CAPTION | win32con.WS_BORDER | win32con.WS_THICKFRAME))
win32api.SetWindowLong(top_wnd, win32con.GWL_EXSTYLE, old_exstyle & ~win32con.WS_EX_WINDOWEDGE)
win32gui.SetWindowPos(top_wnd, win32con.HWND_TOP, x, y, dx-x, dy-y, win32con.SWP_SHOWWINDOW | win32con.SWP_FRAMECHANGED)

# Black background
bkgnd_wnd = win32gui.CreateWindow(class_atom, '',
              win32con.WS_CHILD | win32con.WS_VISIBLE,
              0, 0, dx-x, dy-y,
              top_wnd,
              None, win32api.GetModuleHandle(None), None)
win32gui.SetWindowPos(bkgnd_wnd, win32con.HWND_BOTTOM, 0, 0, 0, 0,
             win32con.SWP_NOACTIVATE | win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)

restore_data = vim.bindeval('s:restore_data')
restore_data['window_placement'] = old_window_placement
restore_data['style'] = old_style
restore_data['exstyle'] = old_exstyle
restore_data['class_atom'] = class_atom
.
endfunction

function fullscreen#windows#deactivate()
python <<
import vim
import win32api
import win32con
import win32gui

top_wnd = win32gui.FindWindow('Vim', None)
restore_data = vim.bindeval('s:restore_data')

bkgnd_wnd = 0
def find_bg_wnd(hwnd, lparam):
  global bkgnd_wnd
  if win32gui.GetClassName(hwnd) == 'VimFullscreenBkgnd':
    bkgnd_wnd = hwnd
    return True
  return True
win32gui.EnumChildWindows(top_wnd, find_bg_wnd, None)
win32gui.DestroyWindow(bkgnd_wnd)
win32gui.UnregisterClass(restore_data['class_atom'], None)

win32api.SetWindowLong(top_wnd, win32con.GWL_STYLE, restore_data['style'])
win32api.SetWindowLong(top_wnd, win32con.GWL_EXSTYLE, restore_data['exstyle'])

win32gui.SetWindowPlacement(top_wnd, restore_data['window_placement'])
if restore_data['window_placement'][1] == win32con.SW_SHOWMAXIMIZED:
  win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_RESTORE, 0)
  win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_MAXIMIZE, 0)
.
let s:restore_data = {}
endfunction

function fullscreen#windows#is_active()
  return !empty(s:restore_data)
endfunction

