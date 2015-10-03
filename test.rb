require_relative "game"
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
    assert_equal([:left, :right, :up, :down],
                 Game.new.load_board('boards/1').get_possible_moves)
  end

  def test_move_left
    (2..4).each do |i|
      g = Game.new.load_board("boards/#{i}")
      g.move_left
      g2 = Game.new.load_board("boards/#{i}l")
      assert_equal(g2, g)
    end
  end

  def test_move_right
    (2..4).each do |i|
      g = Game.new.load_board("boards/#{i}")
      g.move_right
      g2 = Game.new.load_board("boards/#{i}r")
      assert_equal(g2, g)
    end
  end

  def test_move_up
    (2..4).each do |i|
      g = Game.new.load_board("boards/#{i}")
      g.move_up
      g2 = Game.new.load_board("boards/#{i}u")
      assert_equal(g2, g)
    end
  end
end
