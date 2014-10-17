# require './board.rb'
require 'byebug'

class InvalidMoveError < RuntimeError
end

class Piece
  
  attr_accessor :pos, :unic, :color, :king
  
  def initialize(pos, color, board, king = false)
    @pos = pos
    @color = color
    @unic = (color == :white ? "\u25cf" : "\u25cb")
    @board = board
    @king = king
  end
  
  SLIDING_MOVES = [
    [1, -1],
    [1, 1],
    [-1, -1],
    [-1, 1]
  ]
  
  JUMPING_MOVES = [
    [-2, 2],
    [-2, -2],
    [2, 2],
    [2, -2]
  ]
  
  RANGE = (0..7).to_a
  
  def dup(board)
    Piece.new(self.pos, self.color, board, self.king)
  end
  
  def king_jumps
    move_directions = self.move_diffs
    valid_moves = []
    pos_dup = @pos.dup
    move_directions.each do |dir|
      jump_counter = 0
      loop do
        move = [ pos_dup[0] + dir[0], pos_dup[1] + dir[1] ]
        if valid_range?(move) && @board[move] != nil
          if @board[move].color != @color
            jump_counter += 1
          else
            break
          end
        end
        break if !valid_range?(move) || jump_counter > 1
        valid_moves << move if jump_counter == 1 && @board[move] == nil
        pos_dup = move
      end
      pos_dup = @pos.dup
      next
    end
    
    valid_moves
  end
  
  def king_slides
    move_directions = self.move_diffs
    valid_moves = []
    pos_dup = @pos.dup
    move_directions.each do |dir|
      loop do
        move = [ pos_dup[0] + dir[0], pos_dup[1] + dir[1] ]
        break if !valid_range?(move) || @board[move] != nil
        valid_moves << move
        pos_dup = move
      end
      pos_dup = @pos.dup
      next
    end
    
    valid_moves
  end
  
  def move_diffs
    return SLIDING_MOVES if @king
    @color == :black ? SLIDING_MOVES[0..1] : SLIDING_MOVES[2..3]
  end
  
  def maybe_promote(to_pos)
    @king = true if @color == :black && to_pos[0] == 7
    @king = true if @color == :white && to_pos[0] == 0
  end
  
  def pawn_jumps
    move_directions = JUMPING_MOVES
    possible_moves = []
    move_directions.each do |move|
      jump_over_pos = [@pos[0] + move[0] / 2, @pos[1] + move[1] / 2]
      if valid_range?(jump_over_pos) && @board[jump_over_pos] != nil && @board[jump_over_pos].color != self.color
        possible_moves << [ @pos[0] + move[0], @pos[1] + move[1] ]
      end
    end
    valid_moves = possible_moves.select { |move| valid_range?(move) && @board[move].nil? }
  end
  
  def pawn_slides
    move_directions = self.move_diffs
    possible_moves = []
    move_directions.each { |move| possible_moves << [ @pos[0] + move[0], @pos[1] + move[1] ] }
    valid_moves = possible_moves.select { |move| valid_range?(move) && @board[move].nil? }
  end
  
  #returns true/false if valid move as well as removes the jumped piece if valid
  #pawns can jump backwards as well
  def perform_jump?(to_pos)
    if @king
      valid_moves = self.king_jumps
    else
      valid_moves = self.pawn_jumps
    end
    if valid_moves.include?(to_pos)
      jump_over_pos = []
      diff = [ to_pos[0] - @pos[0], to_pos[1] - @pos[1] ]
      diff.each_with_index { |el, ind| jump_over_pos << (el > 0 ? (to_pos[ind] - 1) : (to_pos[ind] + 1) ) }
      @board[jump_over_pos] = nil
      self.maybe_promote(to_pos) if @king == false
      return true
    end
    
    false
  end
  
  def perform_moves(sequence)
    return if !valid_move_seq?(sequence)
    perform_moves!(sequence)
  end
  
  def perform_moves!(seq)
    seq.each do |row, col|
      pos = [row, col]
      if perform_slide?(pos)
        @board[@pos] = nil
        @pos = pos
        @board[pos] = self
      elsif perform_jump?(pos)
        @board[@pos] = nil
        @pos = pos
        @board[pos] = self
      else
        raise InvalidMoveError.new 'This sequence of moves is not valid, try again.'
        false
      end
    end
    true
  end
  
  #returns true/false if the piece can perform the following move
  #assumed that this function is always called on a valid piece
  #this method only checks that the to_pos is valid
  def perform_slide?(to_pos)
    if @king
      valid_moves = self.king_slides
    else
      valid_moves = self.pawn_slides
    end
    
    if valid_moves.include?(to_pos)
      self.maybe_promote(to_pos) if @king == false
      return true
    end
    
    false
  end
  
  def valid_move_seq?(seq)
    dup_board = @board.dup
    dup_piece = dup(dup_board)
    return true if dup_piece.perform_moves!(seq)
    false
  end
  
  def valid_range?(move)
    move.all? { |el| RANGE.include?(el) }
  end
  
end