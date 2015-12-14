require 'yaml'
require 'scanf'

class Context
  def initialize(rows)
    @board = rows
  end

  def check_sanity(move, rows)
    #fake imp
    @board = rows
  end

  def check_over
    #fake imp
    true
  end
end

def read_line(infile)
  s = infile.gets
  s.strip if not s.nil?
end

def read_board(infile, line_no)
  rows = []
  4.times do |i|
    line = read_line(infile)
    row = line.scanf("|%d||%d||%d||%d|")
    if row.length == 4
      rows.push(row)
    else
      abort("\Line##{line_no + i} unexpected line:#{line}")
    end
  end
  return rows
end

def parse_file(path)
  state = :init
  line_no = 1
  moves = {"U" => :up, "D" => :down, "L" => :left, "R" => :right}
  File.open(path, "r") do |infile|
    while (true)
      case state
      when :init
        line = read_line(infile)
        line_no += 1
        abort('first line must be I') if line != 'I'
        state = :read_init_board
      when :read_init_board
        rows = read_board(infile, line_no)
        context = Context.new rows
        state = :read_move
        line_no += 4
      when :read_move
        line = read_line(infile)
        line_no += 1
        if line == 'E'
          abort("it's not the end yet") if not context.check_over
        else
          move = moves[line]
          abort("illegal move: #{line}") if move.nil?
          context.check_sanity(move, read_board(infile, line_no))
          line_no += 4
        end
      else
        abort("unknown state: #{state}")
      end
    end
  end
end

config = YAML.load_file('config.yml')
config['times'].to_i.times do |i|
  out_file = "run#{i}.txt"
  %x{#{config['cmd']} > #{out_file}}
  parse_file(out_file)
end
