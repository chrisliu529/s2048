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
    possible_moves = get_possible_moves
    next_move = choose_move(possible_moves)
    move_to(next_move)
    #fill a new random 2 or 4 in blank cells
  end

  def get_possible_moves
    result = []
    #scan boarders
    scanners = {
      :left => method(:scan_left),
      :right => method(:scan_right),
      :up => method(:scan_up),
      :down => method(:scan_down)
    }
    scanners.each do |k, v|
      if v.call
        result.push2(k)
      end
    end
    return result
  end

  def scan_left
    (0..N_ROWS-1).each do |c|
      result = true
      (0..N_ROWS-2).each do |r|
        if @board[r, c] != 0
          result = false
          break
        end
      end
      return result if result
    end
    return false
  end

  def scan_right
    (1..N_ROWS).each do |c|
      result = true
      (0..N_ROWS-1).each do |r|
        if @board[r, c] != 0
          result = false
          break
        end
      end
      return result if result
    end
    return false
  end

  def scan_up
    (1..N_ROWS).each do |r|
      result = true
      (0..N_ROWS-1).each do |c|
        if @board[r, c] != 0
          result = false
          break
        end
      end
      return result if result
    end
    return false
  end

  def scan_down
    (0..N_ROWS-2).each do |r|
      result = true
      (0..N_ROWS-1).each do |c|
        if @board[r, c] != 0
          result = false
          break
        end
      end
      return result if result
    end
    return false
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
    return self
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
end
