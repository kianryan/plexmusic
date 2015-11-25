
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

    page_length = Ncurses.getmaxy(@win) - 3

    start_line = @page_line
    end_line = start_line + page_length

    lines = @list[start_line..end_line]
    lines = lines + Array.new(page_length - lines.length + 1) { |i| "" }

    lines.each_with_index{ |item, i|
      draw_line i, lines.find_index(item), item.to_s, @cur_line - start_line == i
    }
    
    @win.wrefresh
  end

  def display_loading message
    @win.attroff(A_REVERSE)
    @win.mvaddstr(0,0,"Loading..." + message.to_s + "   ")
  end

  def draw_line index, col1, col2, reverse
      @win.attron(A_REVERSE) if reverse
      @win.attroff(A_REVERSE) unless reverse

      width = Ncurses.getmaxx(@win) - 1

      col1 = col1.nil? ? "" : col1.to_s
      col2 = col2.nil? ? "" : col2.to_s

      col1_dims = [1, 10]
      col2_dims = [10, width]

      #col1
      @win.move(index + 1, col1_dims[0])
      @win.addstr(col1[0..col1_dims[1] - col1_dims[0]].ljust(col1_dims[1] - col1_dims[0]))
      
      #col2
      @win.move(index + 1, col2_dims[0])
      @win.addstr(col2[0..col2_dims[1] - col2_dims[0]].ljust(col2_dims[1] - col2_dims[0]))
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
    page_size = Ncurses.getmaxy(@win) - 3

    while((ch = @win.getch()) != 27)
      case ch
      when KEY_DOWN
        @cur_line = @cur_line + 1 unless @cur_line > (@list.count - 2)
        @page_line = @page_line + 1 if @cur_line > @page_line + page_size
        display_list
      when KEY_UP
        @cur_line = @cur_line - 1 unless @cur_line < 1
        @page_line = @page_line - 1 if @cur_line < @page_line
        display_list
      when KEY_PPAGE
        @cur_line = @cur_line - page_size > 0 ? @cur_line - page_size : 0
        @page_line = @page_line - page_size > 0 ? @page_line - page_size : 0
        display_list
      when KEY_NPAGE
        @cur_line = @cur_line + page_size > @list.count - 1 ? @list.count - 1 : @cur_line + page_size
        @page_line = @page_line + page_size > @list.count - 1 ? @list.count - 1 : @page_line + page_size
        display_list
      when 10 # Return
        return @cur_line
      end
    end
  end
end

