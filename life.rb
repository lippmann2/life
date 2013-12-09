#M. Lippmann
#A Conway's Game of Life ASCII Animation running on Ruby 1.9.2

#load 'life.rb'

def test_smoke_test
  starting_board = [[0,1,0,0,0],
                    [1,0,0,1,1],
                    [1,1,0,0,1],
                    [0,1,0,0,0],
                    [1,0,0,0,1]]
  one_step = [[0,0,0,0,0],
              [1,0,1,1,1],
              [1,1,1,1,1],
              [0,1,0,0,0],
              [0,0,0,0,0]]
  board = Board.new(starting_board)
  board.step(1)
  board.state_equals?(one_step)
end

class Board

  def initialize(starting_board)
    raise "Board is wrong type" unless starting_board.class==Array &&
                                       starting_board.each {|row| row.class==Array }
    raise "Board is not rectangular." if ragged_board?(starting_board)
    raise "Board should contain only 0's and 1's." if bad_elements?(starting_board)
    
    @board = Marshal.load(Marshal.dump(starting_board))
    @rows = starting_board.length
    @cols = starting_board[0].length

  end

  def to_s
    @board.each do |r|
      r.each do |c|
        print c.to_s
      end
      puts ''
    end
  end

  def step(steps)
    return if steps<1
    for i in 1..steps
      next_board = Marshal.load(Marshal.dump(@board))
      for r in 0..@rows-1
        for c in 0..@cols-1
          next_board[r][c] = next_state(r,c)
        end
      end
      @board = next_board
    end
  end
  
  def state
    Marshal.load(Marshal.dump(@board))
  end

  def state_equals?(another_board)
    @board.flatten == another_board.flatten  
  end

  private

  def ragged_board?(possible_board)
    row_length = nil
    possible_board.each do |row|
      row_length = row.length if !row_length
      return true if row_length != row.length
    end
    false
  end

  def bad_elements?(possible_board)
    possible_board.each do |row|
      return true if row.any? { |element| element!=0 && element != 1 }
    end
    false
  end

  def next_state(r,c)
    case living_neighbors(r,c)
      when 0, 1 #underpopulation
        0
      when 2 #survival
        @board[r][c]
      when 3 #survival, reproduction
        1
      when 4..8 #overcrowding
        0
     end
  end

  def living_neighbors(r,c)
    a=0
    a+=north_of(r,c)
    a+=northeast_of(r,c)
    a+=east_of(r,c)
    a+=southeast_of(r,c)
    a+=south_of(r,c)
    a+=southwest_of(r,c)
    a+=west_of(r,c)
    a+=northwest_of(r,c)
    a
  end
  
  def north_of(r,c)
    return 0 if r==0
    @board[r-1][c]
  end
  def northeast_of(r,c)
    return 0 if r==0 || c==@cols-1
    @board[r-1][c+1]
  end
  def east_of(r,c)
    return 0 if c==@cols-1
    @board[r][c+1]
  end
  def southeast_of(r,c)
    return 0 if r==@rows-1 || c==@cols-1
    @board[r+1][c+1]
  end
  def south_of(r,c)
    return 0 if r==@rows-1
    @board[r+1][c]
  end
  def southwest_of(r,c)
    return 0 if r==@rows-1 || c==0
    @board[r+1][c-1]
  end
  def west_of(r,c)
    return 0 if c==0
    @board[r][c-1]
  end
  def northwest_of(r,c)
    return 0 if r==0 || c==0
    @board[r-1][c-1]
  end
end

def main
  raise "Smoke test failed!" unless test_smoke_test
  gosper_glider_gun_animation()
end

#console must be at least 80x24
def gosper_glider_gun_animation
  
  #coordinates from: https://github.com/jeffomatic/life/blob/master/patterns.py
  coordinates = [[24, 8], [22, 7], [24, 7], [12, 6], [13, 6], [20, 6],
                 [21, 6], [34, 6], [35, 6], [11, 5], [15, 5], [20, 5],
                 [21, 5], [34, 5], [35, 5], [0, 4], [1, 4], [10, 4],
                 [16, 4], [20, 4], [21, 4], [0, 3], [1, 3], [10, 3],
                 [14, 3], [16, 3], [17, 3], [22, 3], [24, 3], [10, 2],
                 [16, 2], [24, 2], [11, 1], [15, 1], [12, 0], [13, 0]]

  starting_board = []
  row = []
  50.times {row << 0}
  20.times { starting_board << Array.new(row) } 
  coordinates.each { |pair| starting_board[pair[1]+10][pair[0]+2]=1 }
  board = Board.new(starting_board)
  
  while true
    board.step(1)
    200.times {puts ''}
    board.to_s
    puts "Infinite Gosper Glider Gun (Hit ^C to abort!)"
    sleep(0.05)
  end

end 

main()

