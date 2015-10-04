require 'matrix'
require 'scanf'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class Array
  def push2(e)
    if not self.include? e
      self.push(e)
    end
  end
end

class Game
  N_ROWS = 4
  N_GRIDS = 16

  attr_reader :board

  def initialize
    @board = Matrix.zero(N_ROWS)
    @moves = 0
    arr = []
    while arr.length < 3 do
      arr.push2(Random.rand(N_GRIDS))
    end
    arr.each do |i|
      set_grid(i, 2)
    end
  end

  def set_grid(pos, n)
    @board[pos / N_ROWS, pos % N_ROWS] = n.to_i
  end

  def move
    @moves += 1
    possible_moves = get_possible_moves()
    next_move = choose_move(possible_moves)
    move_to(next_move)
    add_new_elem()
  end

  def choose_move(moves)
    moves[Random.rand(moves.length)]
  end

  def move_to(direction)
    actions = {
      :left => method(:move_left),
      :right => method(:move_right),
      :up => method(:move_up),
      :down => method(:move_down)
    }
    actions[direction].call
  end

  def move_left
    (0..N_ROWS-1).each do |r|
      numbers = []
      prev = 0
      merged = false
      (0..N_ROWS-1).each do |c|
        num = @board[r, c]
        if num != 0
          if prev == num and not merged
            numbers.pop
            numbers.push(2*num)
            merged = true
          else
            numbers.push(num)
          end
          prev = num
        end
      end
      n = numbers.length
      next if n == N_ROWS
      (N_ROWS-n).times do
        numbers.push(0)
      end
      numbers.each_with_index do |v, i|
        @board[r, i] = v
      end
    end
  end

  def move_right
    (0..N_ROWS-1).each do |r|
      numbers = []
      prev = 0
      merged = false
      (0..N_ROWS-1).each do |c|
        num = @board[r, N_ROWS-1-c]
        if num != 0
          if prev == num and not merged
            numbers.pop
            numbers.push(2*num)
            merged = true
          else
            numbers.push(num)
          end
          prev = num
        end
      end
      n = numbers.length
      next if n == N_ROWS
      (N_ROWS-n).times do
        numbers.push(0)
      end
      numbers.each_with_index do |v, i|
        @board[r, N_ROWS-1-i] = v
      end
    end
  end

  def move_up
    (0..N_ROWS-1).each do |c|
      numbers = []
      prev = 0
      merged = false
      (0..N_ROWS-1).each do |r|
        num = @board[r, c]
        if num != 0
          if prev == num and not merged
            numbers.pop
            numbers.push(2*num)
            merged = true
          else
            numbers.push(num)
          end
          prev = num
        end
      end
      n = numbers.length
      next if n == N_ROWS
      (N_ROWS-n).times do
        numbers.push(0)
      end
      numbers.each_with_index do |v, i|
        @board[i, c] = v
      end
    end
  end

  def move_down
    (0..N_ROWS-1).each do |c|
      numbers = []
      prev = 0
      merged = false
      (0..N_ROWS-1).each do |r|
        num = @board[N_ROWS-1-r, c]
        if num != 0
          if prev == num and not merged
            numbers.pop
            numbers.push(2*num)
            merged = true
          else
            numbers.push(num)
          end
          prev = num
        end
      end
      n = numbers.length
      next if n == N_ROWS
      (N_ROWS-n).times do
        numbers.push(0)
      end
      numbers.each_with_index do |v, i|
        @board[N_ROWS-1-i, c] = v
      end
    end
  end

  def add_new_elem
    empty_pos = []
    @board.each_with_index do |e, r, c|
      if e == 0
        empty_pos.push(r*N_ROWS + c)
      end
    end
    set_grid(empty_pos[Random.rand(empty_pos.length)], 2*Random.rand(2))
  end

  def get_possible_moves
    result = []
    scanners = {
      :left => method(:scan_left),
      :right => method(:scan_right),
      :up => method(:scan_up),
      :down => method(:scan_down),
      :row => method(:scan_row),
      :col => method(:scan_col)
    }
    scanners.each do |k, v|
      if v.call
        if k == :row
          result.push2(:left)
          result.push2(:right)
        elsif k == :col
          result.push2(:up)
          result.push2(:down)
        else
          result.push2(k)
        end
      end
    end
    result
  end

  def scan_left
    (0..N_ROWS-1).each do |r|
      state = nil
      (0..N_ROWS-1).each do |c|
        case state
        when nil, :found_number
          if @board[r, c] == 0
            state = :found_empty
          else
            state = :found_number
          end
        when :found_empty
          if @board[r, c] != 0
            return true
          end
        end
      end
    end
    false
  end

  def scan_right
    (0..N_ROWS-1).each do |r|
      state = nil
      (0..N_ROWS-1).each do |c|
        case state
        when nil, :found_empty
          if @board[r, c] == 0
            state = :found_empty
          else
            state = :found_number
          end
        when :found_number
          if @board[r, c] == 0
            return true
          end
        end
      end
    end
    false
  end

  def scan_up
    (0..N_ROWS-1).each do |c|
      state = nil
      (0..N_ROWS-1).each do |r|
        case state
        when nil, :found_number
          if @board[r, c] == 0
            state = :found_empty
          else
            state = :found_number
          end
        when :found_empty
          if @board[r, c] != 0
            return true
          end
        end
      end
    end
    false
  end

  def scan_down
    (0..N_ROWS-1).each do |c|
      state = nil
      (0..N_ROWS-1).each do |r|
        case state
        when nil, :found_empty
          if @board[r, c] == 0
            state = :found_empty
          else
            state = :found_number
          end
        when :found_number
          if @board[r, c] == 0
            return true
          end
        end
      end
    end
    false
  end

  def scan_row
    (0..N_ROWS-1).each do |r|
      prev = 0
      (0..N_ROWS-1).each do |c|
        cur = @board[r, c]
        next if cur == 0
        return true if cur == prev
        prev = cur
      end
    end
    false
  end

  def scan_col
    (0..N_ROWS-1).each do |c|
      prev = 0
      (0..N_ROWS-1).each do |r|
        cur = @board[r, c]
        next if cur == 0
        return true if cur == prev
        prev = cur
      end
    end
    false
  end

  def load_board(path)
    rows = []
    File.open(path, "r") do |infile|
      while (line = infile.gets)
        row = line.scanf("|%d||%d||%d||%d|")
        if row.length == 4
          rows.push(row)
        end
      end
    end
    pos = 0
    rows.each do |row|
      row.each do |e|
        set_grid(pos, e)
        pos += 1
      end
    end
    self
  end

  def print_board
    puts "=================#{@moves}================"
    @board.to_a.each do |r|
      r.each do|e|
        print "|#{e}|"
      end
      puts
    end
  end

  def ==(another)
    @board == another.board
  end
end
