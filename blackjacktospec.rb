require 'minitest/autorun'

class Card
  
  attr_reader :rank, :suit

  def initialize rank, suit
    @rank = rank
    @suit = suit
  end

  def value
    if rank == :J || rank == :Q || rank == :K
      10
    elsif rank = :A
      1
    else
      rank
    end
  end
  
  def to_s
    "#{rank}#{suit}"
  end
end

class Deck
  
   attr_reader :cards, :drawn_card

  def initialize 
    @cards = %w[A 2 3 4 5 6 7 8 9 T J Q K].product(%w[:C :D :H S]).map(&:join)
  end

  def draw 
    @drawn_card = cards.shift
  end

  def drawn
    cards.unshift(@drawn_card)
  end
end


class Hand
  
  attr_reader :hand
  
  def initialize
    @hand = []
  end

  def add *things
    hand.push(*things)
  end
  
  def value
    running_total = 0
    hand.each do |x|
      running_total = x.value + running_total
    end
    if running_total <= 11 && hand.to_s.include("A")
      running_total + 10
    else
      running_total
    end
  end
  
  def to_a
    hand.map{ |card| card.to_s }
  end
  
  def to_s
    hand.map{ |card| card.to_s }.join(",")
  end
  
  def busted?
    value > 21
  end
  
  def blackjack
    value == 21 && hand.to_a.count == 2
  end
end
 
class TestCard < Minitest::Test
  def test_number_card_value
    2.upto(10) do |x|
      card = Card.new(x, :S)
      assert_equal card.value, x
    end
  end
 
  def test_face_card_value
    [:K, :Q, :J].each do |rank|
      card = Card.new(rank, :H)
      assert_equal card.value, 10
    end
  end
 
  def test_ace_value
    card = Card.new(:A, :D)
    assert_equal card.value, 1
  end
end
 
class TestDeck < Minitest::Test
  def test_counting_cards
    deck = Deck.new
    assert_equal deck.cards.count, 52
  end
 
  def test_counting_draws
    deck = Deck.new
    deck.draw
    assert_equal deck.cards.count, 51
  end
 
  def test_tracking_draws
    deck = Deck.new
    drawn_card = deck.draw
    assert_equal deck.cards.count, 51
    refute_includes deck.cards, drawn_card
    assert_includes deck.drawn, drawn_card
  end
end
 
class TestHand < Minitest::Test
  def test_hand_value_with_number_cards
    hand = Hand.new
    hand.add(Card.new(9, :H), Card.new(7, :S))
    assert_equal hand.value, 16
 
    hand.add(Card.new(4, :D))
    assert_equal hand.value, 20
  end
 
  def test_hand_value_with_face_cards
    hand = Hand.new
    hand.add(Card.new(9, :H), Card.new(:K, :S))
    assert_equal hand.value, 19
  end
 
  def test_hand_value_with_aces
    hand = Hand.new
    hand.add(Card.new(:A, :H), Card.new(:K, :S))
    assert_equal hand.value, 21
 
    hand.add(Card.new(5, :S))
    assert_equal hand.value, 16
  end
 
  def test_busting
    hand = Hand.new
    hand.add(Card.new(6, :H), Card.new(:K, :S), Card.new(9, :H))
    assert hand.busted?
  end
 
  def test_blackjack
    hand = Hand.new
    hand.add(Card.new(:A, :H), Card.new(:K, :S))
    assert hand.blackjack?
  end
 
  def test_hand_as_string
    hand = Hand.new
    hand.add(Card.new(:A, :H), Card.new(:K, :S))
    hand.add(Card.new(5, :S))
    assert_equal hand.to_s, 'AH, KS, 5S'
  end
end


