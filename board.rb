require './piece.rb'
require 'byebug'
require 'colorize'

class Board
  
  def initialize(fill_board = true)
    @board = Array.new(8) { Array.new(8) }
    self.make_board if fill_board
  end
  
  def [](pos)
    @board[pos[0]][pos[1]]
  end
  
  def []=(pos, val)
    @board[pos[0]][pos[1]] = val
  end
  
  def display
    bool = true
    (0..7).each do |row|
      bool = !bool
      puts
      (0..7).each do |col|
        if @board[row][col].nil?
          print (' ' * 3).colorize(:background => :black) if bool
          print (' ' * 3).colorize(:background => :white) if !bool
        else
          print (' ' + @board[row][col].unic + ' ').colorize(:color => :white, :background => :black) if bool
        end
       bool = !bool
      end
    end
    puts
  end
  
  def dup
    new_board = Board.new(false)
    pieces = @board.flatten.compact
    pieces.each do |piece|
      new_board[piece.pos] = piece.dup(new_board)
    end

    new_board
  end
  
  def fill_rows(color)
    rows = (color == :black ? [0, 1, 2] : [5, 6, 7] )
    skip = (color == :black ? true : false) #black skips first col, white does not skip first col
    rows.each do |row|
      (0..7).each do |col|
        if skip
          skip = !skip
          next
        end
        @board[row][col] = Piece.new([row, col], color, self)
        skip = !skip
      end
      skip = !skip
    end
    
  end
  
  def make_board
    [:black, :white].each { |color| fill_rows(color) }
  end
  
  def team(color)
    @board.flatten.compact.select { |piece| piece.color == color }
  end
  
  def tie?(color)
    pieces_left = team(color)
    valid_moves = []
    pieces_left.each do |piece|
      valid_moves += piece.pawn_jumps + piece.pawn_slides if !piece.king
      valid_moves += piece.king_jumps + piece.king_slides if piece.king
    end
    valid_moves.empty?
  end

end