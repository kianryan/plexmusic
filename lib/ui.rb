
require "ncurses"

include Ncurses
include Ncurses::Form

class UI

  def initialize
    scr = Ncurses.initscr
    Ncurses.cbreak
    Ncurses.noecho
    Ncurses.keypad(scr, true)
  end

  def self.finalize
    Ncurses.endwin
  end

  def login
    login_field = FIELD.new(1, 30, 0, 1, 0, 0)
    login_field.set_field_back(A_UNDERLINE)
    #login_field.set_field_type(TYPE_ALNUM, 0)

    password_field = FIELD.new(1, 30, 2, 1, 0, 0)
    password_field.set_field_back(A_UNDERLINE)
    #password_field.set_field_type(TYPE_ALNUM, 0)

    form = FORM.new([login_field, password_field])
    rows = Array.new
    cols = Array.new
    form.scale_form(rows, cols)

    win = WINDOW.new(rows[0] + 3, cols[0] + 14, 1, 1)
    win.keypad(TRUE)

    form.set_form_win(win)
    form.set_form_sub(win.derwin(rows[0], cols[0], 1, 12));

    win.box(0, 0)
    form.post_form

    win.mvaddstr(1, 2, "Username")
    win.mvaddstr(3, 2, "Password")

    win.wrefresh

    form_input(win, form)

    username = login_field.field_buffer(0).strip
    password = password_field.field_buffer(0).strip

    form.unpost_form
    form.free_form
    login_field.free_field
    password_field.free_field

    [username, password]
  end

  def init_list list
    Ncurses.curs_set(0)

    @win = WINDOW.new(0, Ncurses.COLS, 0, 0) if ! defined?(@win)
    @cur_line = 0
    @page_line = 0
    @list = list
    @win.box(0, 0)
    @win.keypad(TRUE)
    display_list
    list_input
  end

  def display_list 

    page_size = Ncurses.getmaxy(@win) - 3

    start_line = @page_line
    end_line = start_line + page_size

    @list[start_line..end_line].each_with_index{ |item, i|
      draw_line i, i.to_s + " " + item.to_s, @cur_line - start_line == i
    }
    @win.wrefresh
  end

  def display_loading message
    @win.attroff(A_REVERSE)
    @win.mvaddstr(0,0,"Loading..." + message.to_s + "   ")
  end

  def draw_line index, text, reverse
      @win.attron(A_REVERSE) if reverse
      @win.attroff(A_REVERSE) unless reverse

      @win.move(index + 1, 1)

      width = Ncurses.getmaxx(@win) - 2
      @win.addstr(text[0..width].ljust(width))
  end

  private
  def form_input win, form
    # Loop through to get user requests
    while((ch = win.getch()) != 27)
      case ch
      when KEY_DOWN
        # Go to next field */
        form.form_driver(REQ_VALIDATION);
        form.form_driver(REQ_NEXT_FIELD);
        # Go to the end of the present buffer
        # Leaves nicely at the last character
        form.form_driver(REQ_END_LINE);

      when KEY_UP
        # Go to previous field
        form.form_driver(REQ_VALIDATION);
        form.form_driver(REQ_PREV_FIELD);
        form.form_driver(REQ_END_LINE);

      when KEY_LEFT
        # Go to previous field
        form.form_driver(REQ_PREV_CHAR);

      when KEY_RIGHT
        # Go to previous field
        form.form_driver(REQ_NEXT_CHAR);

      when KEY_BACKSPACE
        form.form_driver(REQ_DEL_PREV);
      else
        # If this is a normal character, it gets Printed    
        form.form_driver(ch);
      end
    end
  end

  def list_input 
    while((ch = @win.getch()) != 27)
      case ch
      when KEY_DOWN
        @cur_line = @cur_line + 1 unless @cur_line > (@list.count - 2)
        @page_line = @page_line + 1 if @cur_line > @page_line + Ncurses.getmaxy(@win) - 3
        display_list
      when KEY_UP
        @cur_line = @cur_line - 1 unless @cur_line < 1
        @page_line = @page_line - 1 if @cur_line < @page_line
        display_list
      when 10 # Return
        return @cur_line
      end
    end
  end
end

