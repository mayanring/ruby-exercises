# You are given a square map of size nxn. Each cell of the map has a value
# denoting its depth. We will call a cell of the map a cavity if and only if this
# cell is not on the border of the map and each cell adjacent to it has strictly
# smaller depth.

# Cells are adjacent if they touch on the north, east, south or west side.

# You need to find all the cavities on the map and depict them with the uppercase
# character X.

# depth values are from 1-9.


# some irb testing methods...

# generic test
def sample_arr
  [
    [1,1,1,2],
    [1,9,1,2],
    [1,8,9,2],
    [1,2,3,4],
  ]
end

# test for 9 being on an border
def sample_5
  [
    [1,1,1,2,4],
    [1,9,2,2,3],
    [1,8,3,6,9],
    [1,2,4,1,5],
    [1,1,2,1,1]
  ]
end

def display(arr)
  arr.each do |row|
    puts row.join(' ')
  end

  puts
end


# assume arr is an array of arrays of size nxn
def mark_cavities(arr)
  n = arr.length
  marked = arr.map(&:clone)
  # marked = Array.new(n) { Array.new(n) }

  # we use 1, n - 1 as the ranges here because we want to avoid considering the borders
  for j in (1...n - 1) do
    for i in (1...n - 1) do
      neighbors = [
        arr[j - 1][i],
        arr[j][i - 1],
        arr[j][i + 1],
        arr[j + 1][i]
      ]

      marked[j][i] = 'X' if neighbors.all? { |neighbor| neighbor < arr[j][i] }
    end
  end

  marked
end
