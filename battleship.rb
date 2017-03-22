# grid keeps track of an n x n grid
# board keeps track of no attempt and misses only, leaves hits up to ships.

class Board
  attr_accessor :grid, :ships

  def initialize(size = 10)
    @grid = Array.new(size) { Array.new(size) }
    @ships = []
  end

  def draw
    @grid.each_with_index do |row, i|

      row.each_with_index do |cell, j|
        ship = @ships.find { |ship| ship.hit?(j, i) }
        output =  if ship && ship.damaged?(j, i)
                    "x "
                  elsif ship
                    "#{Ship::SHIP_LENGTHS[ship.type]} "
                  else
                    if cell
                      "#{cell} "
                    else
                      '. '
                    end
                  end

        print output
      end

      print "\n"
    end

    puts
  end

  def attack(x, y)
    ship = @ships.find { |ship| ship.hit?(x, y) }

    if ship
      ship.mark_as_hit(x, y)
      attack_successful = true
    else
      # mark as miss
      @grid[y][x] = 'o'
      attack_successful = false
    end

    attack_successful
  end

  def set_default_ship_locations
    default_locations.each do |ship_type, ships_to_create|
      ships_to_create.each do |ship_locations|
        ship = Ship.new(ship_type)

        ship_locations.each do |loc|
          ship.add_part(loc[0], loc[1])
        end

        @ships << ship
      end
    end
  end

  def lose?
    @ships.all? { |ship| ship.sunk? }
  end

  private

  def default_locations
    # each one of these values is an array of ships
    # inside each ship array is a list of positions

    # this can be potentially loaded via yaml or in a params hash as part of a request
    {
      carrier: [
        [[9, 1], [9, 2], [9, 3], [9, 4], [9, 5]]
      ],
      battleship: [
        [[7, 4], [7, 5], [7, 6], [7, 7]]
      ],
      cruiser: [
        [[2, 6], [3, 6], [4, 6]]
      ],
      destroyer: [
        [[1, 1], [1, 2]],
        [[3, 4], [4, 4]]
      ],
      submarine: [
        [[3, 2]],
        [[1, 8]]
      ]
    }
  end
end

class Part
  attr_accessor :x, :y, :hit

  def initialize(x, y)
    @x = x
    @y = y
    @hit = false
  end
end

# ships needs to keep track of where their segments (parts) are

class Ship
  attr_accessor :type

  SHIP_TYPES = %i(carrier battleship cruiser destroyer submarine)

  SHIP_LENGTHS = {
    carrier: 5,
    battleship: 4,
    cruiser: 3,
    destroyer: 2,
    submarine: 1
  }

  def initialize(type)
    raise StandardError.new("invalid ship type") unless SHIP_TYPES.include?(type)

    @parts = []
    @type = type
  end

  def add_part(x, y)
    if @parts.length < SHIP_LENGTHS[@type]
      @parts << Part.new(x, y)
    else
      raise StandardError.new("#{@type.to_s} is limited to a length of #{SHIP_LENGTHS[@type]}")
    end

    self
  end

  def hit?(x, y)
    @parts.any? { |part| part.x == x && part.y == y }
  end

  def damaged?(x, y)
    !!@parts.find { |part| part.x == x && part.y == y && part.hit }
  end

  def mark_as_hit(x, y)
    part = @parts.find { |part| part.x == x && part.y == y }
    part.hit = true
  end

  def sunk?
    @parts.all? { |part| part.hit }
  end
end


# what is Grid responsible

# what would a rails implementation of this look like?
  # file upload of ship positions?
  # what kind of database storage?
    # validations
