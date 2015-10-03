require_relative "main"
require "test/unit"

class TestGame < Test::Unit::TestCase

  def test_push2
    arr = []
    arr.push2(2)
    assert_equal([2],  arr)
    arr.push2(2)
    assert_equal([2],  arr)
  end

  def test_get_possible_moves
    g = Game.new.load_board('boards/1')
    arr = g.get_possible_moves
    assert_equal([:left, :right, :up, :down],  arr)
  end
end
