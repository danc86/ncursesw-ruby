#!/usr/bin/env ruby

# ncurses-ruby is a ruby module for accessing the FSF's ncurses library
# (C) 2002, 2004 Tobias Peters <t-peters@users.berlios.de>
# (C) 2005, 2009, 2011 Tobias Herzke
# (C) 2013 Gaute Hope <eg@gaute.vetsj.com>
#
# This module is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This module is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this module; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

# $Id: extconf_ncursesw.rb,v 1.1 2011-05-30 23:05:50 t-peters Exp $

require "mkmf"

$CFLAGS  += " -g -Wformat -Werror=format-security -Waddress"

if find_executable('pkg-config')
  $CFLAGS  += ' ' + `pkg-config --cflags ncursesw`.strip
  $LDFLAGS += ' ' + `pkg-config --libs ncursesw`.strip
end

dir_config("ncurses")

have_header("unistd.h")
have_header("locale.h")

if have_header ("ncursesw/curses.h") # ubuntu 13
  curses_header = "ncursesw/curses.h"
elsif have_header("ncurses.h")
  curses_header = "ncurses.h"
elsif have_header("ncurses/curses.h")
  curses_header = "ncurses/curses.h"
elsif have_header("curses.h")
  curses_header = "curses.h"
else
  raise "ncurses header file not found"
end

if have_library("ncursesw", "wmove")
  curses_lib = "ncursesw"
elsif have_library("ncurses", "add_wch")
  curses_lib = "ncurses"
  curses_is_wide = true
elsif have_library("pdcurses", "wmove")
  curses_lib = "pdcurses"
else
  raise "ncurses library not found"
end

have_func("newscr")
have_func("TABSIZE")
have_func("ESCDELAY")
have_func("keybound")
have_func("curses_version")
have_func("tigetstr")
have_func("getwin")
have_func("putwin")
have_func("ungetmouse")
have_func("mousemask")
have_func("wenclose")
have_func("mouseinterval")
have_func("wmouse_trafo")
have_func("mcprint")
have_func("has_key")

have_func("delscreen")
have_func("define_key")
have_func("keyok")
have_func("resizeterm")
have_func("use_default_colors")
have_func("use_extended_names")
have_func("wresize")
have_func("attr_on")
have_func("attr_off")
have_func("attr_set")
have_func("chgat")
have_func("color_set")
have_func("filter")
have_func("intrflush")
have_func("mvchgat")
have_func("mvhline")
have_func("mvvline")
have_func("mvwchgat")
have_func("mvwhline")
have_func("mvwvline")
have_func("noqiflush")
have_func("putp")
have_func("qiflush")
have_func("scr_dump")
have_func("scr_init")
have_func("scr_restore")
have_func("scr_set")
have_func("slk_attr_off")
have_func("slk_attr_on")
have_func("slk_attr")
have_func("slk_attr_set")
have_func("slk_color")
have_func("tigetflag")
have_func("tigetnum")
have_func("use_env")
have_func("vidattr")
have_func("vid_attr")
have_func("wattr_on")
have_func("wattr_off")
have_func("wattr_set")
have_func("wchgat")
have_func("wcolor_set")
have_func("getattrs")

puts "checking for ncursesw (wide char) functions..."
if not (have_func("wget_wch") and
        have_func("add_wch") and
        have_func("get_wch"))
  raise "no wget_wch, add_wch and/or get_wch found."
end


puts "checking which debugging functions to wrap..."
have_func("_tracef")
have_func("_tracedump")
have_func("_nc_tracebits")
have_func("_traceattr")
have_func("_traceattr2")
have_func("_tracechar")
have_func("_tracechtype")
have_func("_tracechtype2")
have_func("_tracemouse")

puts "checking for other functions that appeared after ncurses version 5.0..."
have_func("assume_default_colors")
have_func("attr_get")

puts "checking for the panel library..."
if have_header("panel.h") or have_header("ncursesw/panel.h")
  have_library("panelw", "panel_hidden")
else
  raise "panel library not found"
end

puts "checking for the form library..."
if have_header("form.h") or have_header("ncursesw/form.h")
  if not have_library("formw", "new_form") ||
      (curses_is_wide && have_library("form", "new_form"))
    raise "formw library not found"
  end
else
  raise "form library not found."
end

if have_library("formw", "form_driver_w")
  $CFLAGS += " -DHAVE_FORM_DRIVER_W"
end

puts "checking for the menu library..."
if have_header("menu.h") or have_header("ncursesw/menu.h")
  have_library("menu", "new_menu")
else
  raise "menu library not found."
end

puts "checking for various ruby and standard functions.."
if have_func("rb_thread_fd_select")
  $CFLAGS  += " -DHAVE_RB_THREAD_FD_SELECT"
end

if have_func("clock_gettime")
  $CFLAGS += " -DHAVE_CLOCK_GETTIME"
end

# check if we have sys/time.h, should increase portability
# https://github.com/sup-heliotrope/ncursesw-ruby/issues/25
# http://stackoverflow.com/questions/7889678/how-can-adding-a-header-increase-portability-sys-time-h
have_header("sys/time.h")

$CXXFLAGS  = $CFLAGS

create_makefile('ncursesw_bin')
