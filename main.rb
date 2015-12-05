require_relative "game"

g = Game.new
puts "I"
g.print_board

while g.move do
  g.print_board
end

puts "E"
STDERR.puts "==== GAME OVER (#{g.max}) ===="
