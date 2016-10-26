# VIM Fullscreen Plugin
# Copyright (C) 2015 Ruediger Hanke
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. Neither the name of the organization nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY Ruediger Hanke ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Ruediger Hanke BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import vim
import win32api
import win32con
import win32gui

vim.vars.update({ 'fullscreen_python_win32ext_available': 1 })

def maximize():
    top_wnd = win32gui.FindWindow('Vim', None)
    win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_MAXIMIZE, 0)

def activate():
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
            win32con.WS_CHILD,
            0, 0, dx-x, dy-y,
            top_wnd,
            None, win32api.GetModuleHandle(None), None)
    win32gui.SetWindowPos(bkgnd_wnd, win32con.HWND_BOTTOM, 0, 0, 0, 0,
            win32con.SWP_NOACTIVATE | win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)

    restore_data = { 'window_placement': old_window_placement , 'style': old_style , 'exstyle': old_exstyle , 'class_atom': class_atom, 'bkgnd_wnd': bkgnd_wnd }
    vim.vars.update({ 'fullscreen_restoredata': restore_data })
    vim.vars.update({ 'fullscreen_active': 1 })

def deactivate():
    restore_data = vim.vars.get('fullscreen_restoredata')
    win32gui.DestroyWindow(restore_data.get('bkgnd_wnd'))
    win32gui.UnregisterClass(restore_data.get('class_atom'), None)

    top_wnd = win32gui.FindWindow('Vim', None)
    win32api.SetWindowLong(top_wnd, win32con.GWL_STYLE, restore_data.get('style'))
    win32api.SetWindowLong(top_wnd, win32con.GWL_EXSTYLE, restore_data.get('exstyle'))

    win32gui.SetWindowPlacement(top_wnd, restore_data.get('window_placement'))
    if restore_data.get('window_placement')[1] == win32con.SW_SHOWMAXIMIZED:
      win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_RESTORE, 0)
      win32api.SendMessage(top_wnd, win32con.WM_SYSCOMMAND, win32con.SC_MAXIMIZE, 0)
    vim.vars.update({ 'fullscreen_restoredata': {} })
    vim.vars.update({ 'fullscreen_active': 0 })
