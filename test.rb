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
    ['1', 'a', '5'].each do |f|
      assert_equal([:left, :right, :up, :down],
                   Game.new.load_board("boards/#{f}").get_possible_moves)
    end
  end

  def gen_cases(direction)
    (2..4).each do |i|
      g = Game.new.load_board("boards/#{i}")
      case direction
      when 'l'
        g.move_left
      when 'r'
        g.move_right
      when 'u'
        g.move_up
      when 'd'
        g.move_down
      end
      g2 = Game.new.load_board("boards/#{i}#{direction}")
      assert_equal(g2, g)
    end
  end

  def test_move
    'lrud'.split('').each do |c|
      gen_cases(c)
    end
  end
end
