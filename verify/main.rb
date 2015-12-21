require 'yaml'
require 'scanf'
require 'erb'

class GenericTemplate
  include ERB::Util
  attr_accessor :items, :template, :date

  def initialize(items, template, date=Time.now)
    @date = date
    @items = items
    @template = template
  end

  def render()
    ERB.new(@template).result(binding)
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end
end

module AdaCmpVerify
  class Context
    attr_reader :error

    def initialize(rows)
      cells = []
      (0..N_ROWS-1).each do |r|
        (0..N_ROWS-1).each do |c|
          v = rows[r][c]
          if v != 0
            cells << v
          end
        end
      end
      @error = (not (cells.length == 3 and cells.all? {|x| x == 2}))
      @board = rows
    end

    def check_sanity(move, rows)
      actions = {
        :left => method(:move_left),
        :right => method(:move_right),
        :up => method(:move_up),
        :down => method(:move_down)
      }
      actions[move].call
      @error = (not matched(rows))
      @board = rows
    end

    def matched(rows)
      extra = []
      (0..N_ROWS-1).each do |r|
        (0..N_ROWS-1).each do |c|
          v = rows[r][c]
          if @board[r][c] != v
            return false if @board[r][c] != 0
            extra << v
          end
        end
      end
      return false if extra.length != 1 or (extra[0] != 2 and extra[0] != 4)
      true
    end

    N_ROWS = 4

    def move_left
      (0..N_ROWS-1).each do |r|
        numbers = []
        prev = 0
        merged = false
        (0..N_ROWS-1).each do |c|
          num = @board[r][c]
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
          @board[r][i] = v
        end
      end
    end

    def move_right
      (0..N_ROWS-1).each do |r|
        numbers = []
        prev = 0
        merged = false
        (0..N_ROWS-1).each do |c|
          num = @board[r][N_ROWS-1-c]
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
          @board[r][N_ROWS-1-i] = v
        end
      end
    end

    def move_up
      (0..N_ROWS-1).each do |c|
        numbers = []
        prev = 0
        merged = false
        (0..N_ROWS-1).each do |r|
          num = @board[r][c]
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
          @board[i][c] = v
        end
      end
    end

    def move_down
      (0..N_ROWS-1).each do |c|
        numbers = []
        prev = 0
        merged = false
        (0..N_ROWS-1).each do |r|
          num = @board[N_ROWS-1-r][c]
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
          @board[N_ROWS-1-i][c] = v
        end
      end
    end

    def check_over
      #fake imp
      true
    end

    def score
      arr = @board.flatten.sort { |x,y| y <=> x }
      arr[0] + arr[1]
    end
  end

  class FileParser
    attr_reader :result

    def initialize(path)
      @infile = File.open(path, "r")
      @result = {}
    end

    def read_line
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
          raise("Line##{line_no + i} unexpected line:#{line}")
        end
      end
      return rows
    end

    def parse
      begin
        @result = do_parse()
      rescue RuntimeError => err
        @result[:error] = err
      end
    end

    def do_parse
      state = :init
      line_no = 1
      moves = {"U" => :up, "D" => :down, "L" => :left, "R" => :right}
      move_cnt = 0
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
          raise('bad init board') if context.error
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
            raise("Line##{line_no} bad transform") if context.error
            line_no += 4
            move_cnt += 1
          end
        when :done
          return {moves: move_cnt, score: context.score}
        else
          abort("unknown state: #{state}")
        end
      end
    end
  end
end

def main
  config = YAML.load_file('config.yml')
  records = []
  max_score = 0
  time_cost = 0
  config['times'].to_i.times do |i|
    puts "=== running #{i} ==="
    out_file = "run#{i}.txt"
    t0 = Time.now
    pid = Process::spawn("#{config['cmd']} > #{out_file}")
    watcher = Thread.new {
      remained_time = config['timeout'] - time_cost
      sleep remained_time
      if Process::waitpid(pid, Process::WNOHANG).nil?
        puts "halt for timeout"
        puts "kill #{pid}, #{pid + 1}"
        %x{kill -9 #{pid}}
        %x{kill -9 #{pid+1}}
      end
    }
    wait_res = Process::waitpid(pid)
    puts "wait return #{wait_res}"
    elapsed = Time.now - t0
    time_cost += elapsed
    remained_time = config['timeout'] - time_cost
    if remained_time <= 0
      records << {elapsed: 'timeout'}
      break
    end
    p = AdaCmpVerify::FileParser.new(out_file)
    p.parse
    err = p.result[:error]
    if err.nil?
      score = p.result[:score]
      max_score = score if score > max_score
      records << {score: score, moves: p.result[:moves],
        elapsed: elapsed, output: out_file}
    else
      puts"error: #{err} in #{i} run"
      return
    end
  end
  puts records
  report_html =
    GenericTemplate.new({max_score: max_score, records: records}, File.read('report.html.erb'))
  report_html.save('report.html')
end

main
