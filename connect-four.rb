require 'byebug'

class Grid
  GRID_COLUMNS = 7
  GRID_ROWS = 6
  CONNECT_LENGTH = 4

  attr_reader :columns, :rows
  attr_accessor :board

  def initialize(columns: GRID_COLUMNS, rows: GRID_ROWS)
    @columns = columns
    @rows = rows

    @board = Array.new(@rows) { Array.new(@columns) }
  end

  def draw
    puts
    @board.each_with_index do |row, i|
      row.each do |column|
        if column.nil?
          print ". "
        else
          print "#{column} "
        end
      end

      puts
    end

    puts
  end

  def game_over?(player_one, player_two)
    won_by_rows?(player_one) || won_by_columns?(player_one) || won_by_diagonals?(player_one) ||
    won_by_rows?(player_two) || won_by_columns?(player_two) || won_by_diagonals?(player_two)
  end

  # the player has won by columns if there are four continuous chips of the same color
  def won_by_columns?(player)
    @board.each do |row|
      ending_col = @columns - CONNECT_LENGTH

      (0..ending_col).each do |starting_col|
        target_arr = row.slice(starting_col, CONNECT_LENGTH)
        return true if target_arr.all? { |col| col == player }
      end
    end

    false
  end

  def won_by_rows?(player)
    ending_row = @rows - CONNECT_LENGTH

    (0..@columns - 1).each do |col|
      # move starting_row down by 1 each time until we've covered the whole row
      (0..ending_row).each do |starting_row|
        target_arr = []

        # starting with starting_row, check 4 rows (incl) for this col to see if we have won
        (starting_row...starting_row + CONNECT_LENGTH).each do |row|
          target_arr.push(@board[row][col])
        end

        return true if target_arr.all? { |j| j == player }
      end
    end

    false
  end

  def won_by_diagonals?(player)
    build_diagonals.each do |diagonal|
      target_arr = []

      diagonal.each do |row_col_pair|
        target_arr.push(@board[ row_col_pair[0] ][ row_col_pair[1] ])
      end

      return true if target_arr.all? { |e| e == player }
    end

    false
  end

  # player chooses column to make move
  def player_turn(player:, column:)
    row = next_available_row(column)
    return nil unless row

    place_move(player: player, column: column, row: row)
  end

  private
  # TODO: refactor this so it's generalized to any number of row and col
  def build_diagonals
    [
      [ [3, 0], [2, 1], [1, 2], [0, 3] ],  # there is a pattern here where row decreases while col increases ...
      [ [4, 0], [3, 1], [2, 2], [1, 3] ],
      [ [3, 1], [2, 2], [1, 3], [0, 4] ],
      [ [5, 0], [4, 1], [3, 2], [4, 1] ],
      [ [4, 1], [3, 2], [2, 3], [1, 4] ],
      [ [3, 2], [2, 3], [1, 4], [0, 5] ],
      [ [5, 1], [4, 2], [3, 3], [2, 4] ],
      [ [4, 2], [3, 3], [2, 4], [1, 5] ],
      [ [3, 3], [2, 4], [1, 5], [0, 6] ],
      [ [5, 2], [4, 3], [3, 4], [2, 5] ],
      [ [4, 3], [3, 4], [2, 5], [1, 6] ],
      [ [5, 3], [4, 4], [3, 5], [2, 6] ],
    ]
  end

  def next_available_row(column)
    next_row = @rows - 1

    @board.each_with_index do |row, i|
      # as soon as we find a used row, stop and return previous row
      if row[column]
        next_row = i - 1
        break
      end
    end

    next_row = nil if next_row == -1
    next_row
  end

  def place_move(player:, column:, row:)
    raise StandardError.new("column out of bounds") unless column < @columns
    raise StandardError.new("row out of bounds") unless row < @rows

    @board[row][column] = player
    @board
  end

end

# TODO: driver code to alternate between player turns
# TODO: move some functions to private
# TODO: test public functions
# check win conditions by diagonals
# generalize solution so we're not building diagonals specifically for 6 x 7 grid

