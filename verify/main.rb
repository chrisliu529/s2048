require 'yaml'
require 'scanf'

module AdaCmpVerify
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

  class FileParser
    attr_reader :result

    def initialize(path)
      @infile = File.open(path, "r")
      @result = {}
    end

    def read_line()
      s = @infile.gets
      s.strip if not s.nil?
    end

    def read_board(line_no)
      rows = []
      4.times do |i|
        line = read_line()
        row = line.scanf("|%d||%d||%d||%d|")
        if row.length == 4
          rows.push(row)
        else
          abort("Line##{line_no + i} unexpected line:#{line}")
        end
      end
      return rows
    end

    def parse()
      state = :init
      line_no = 1
      moves = {"U" => :up, "D" => :down, "L" => :left, "R" => :right}
      while (true)
        case state
        when :init
          line = read_line()
          line_no += 1
          raise('first line must be I') if line != 'I'
          state = :read_init_board
        when :read_init_board
          rows = read_board(line_no)
          context = Context.new rows
          line_no += 4
          state = :read_move
        when :read_move
          line = read_line()
          line_no += 1
          if line == 'E'
            raise("it's not the end yet") if not context.check_over
            state = :done
          else
            move = moves[line]
            raise("Line##{line_no} illegal move:#{line}") if move.nil?
            context.check_sanity(move, read_board(line_no))
            line_no += 4
          end
        when :done
          return :ok
        else
          abort("unknown state: #{state}")
        end
      end
    end
  end
end

config = YAML.load_file('config.yml')
config['times'].to_i.times do |i|
  out_file = "run#{i}.txt"
  t0 = Time.now
  %x{#{config['cmd']} > #{out_file}}
  elapsed = Time.now - t0
  p = AdaCmpVerify::FileParser.new(out_file)
  p.parse
  err = p.result[:error]
  if err.nil?
    puts "score: #{p.result[:score]}"
    puts "moves: #{p.result[:moves]}"
    puts "elapsed time: #{"%.3f" % elapsed} sec"
    puts "record: #{out_file}"
  else
    puts"error: #{err}"
  end
end
