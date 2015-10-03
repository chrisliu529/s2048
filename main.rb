require_relative "game"

g = Game.new
while true do
  g.print_board
  g.move
  sleep 1
end
