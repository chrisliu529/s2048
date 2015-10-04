require_relative "game"

g = Game.new
g.print_board

while g.move do
  g.print_board
end

puts "==== GAME OVER (#{g.max}) ===="
