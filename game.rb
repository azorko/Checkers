require './board.rb'
require 'byebug'

class Game
  
  attr_reader :board, :current_player, :players
  
  def initialize
    @board = Board.new
      @players = {
        white: HumanPlayer.new(:white),
        black: HumanPlayer.new(:black)
      }
      @current_player = :white  
  end
  
  def play
    until @board.tie?(current_player) || @board.team(current_player).size < 1
      @board.display
      players[current_player].play_turn(board)
      @current_player = (current_player == :white) ? :black : :white
    end

    @board.tie?(current_player) ? (p "It's a tie!") : (p "#{current_player} lost.")
  end
end

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn(board)
    puts "Current player: #{color}"
    begin
      from_pos = get_pos('From pos:')
      if board[from_pos] == nil || board[from_pos].color != @color
        raise ArgumentError.new 'That is not a valid piece to move, try again.'
      end
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      retry
    end
    begin  
      sequence = get_pos('Sequence of moves:')
      sequence = sequence.each_slice(2).to_a
      board[from_pos].perform_moves(sequence)
    rescue InvalidMoveError => e
      puts "Error: #{e.message}"
      retry
    end
  end

  private

  def get_pos(prompt)
    puts prompt
    gets.chomp.scan(/\d/).map!(&:to_i)
  end
end

g = Game.new
g.play