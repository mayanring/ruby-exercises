require 'json'

# Board (n x n) can be used in two modes:
# 1. keep track of your own ship locations and whether they've been hit "your ships"
# 2. keep track of your hits and misses (without ship info) "enemy ships" and no attempts

class Board
  BOARD_MODES = %i(your_ships enemy_ships)
  attr_accessor :grid, :ships

  def initialize(mode, size = 10)
    raise StandardError.new("Board mode must be either :your_ships or :enemy_ships") unless BOARD_MODES.include?(mode)

    @grid = Array.new(size) { Array.new(size) }
    @ships = []
    @mode = mode
  end

  def draw
    @grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        output = '. '

        if @mode == :your_ships
          ship = @ships.find { |ship| ship.hit?(j, i) }
          output =  if ship && ship.damaged?(j, i)
                      "x "
                    elsif ship
                      "#{Ship::SHIP_LENGTHS[ship.type]} "
                    else
                      ". "
                    end
        else  # enemy ships
          output = cell ? "#{cell} " : '. '
        end

        print output
      end

      print "\n"
    end

    puts
  end

  # this causes an attack on a player's board
  def attack!(x, y)
    raise "Cannot call attack! on :enemy_ships board" unless @mode == :your_ships

    ship = @ships.find { |ship| ship.hit?(x, y) }

    if ship
      ship.mark_as_hit(x, y)
      attack_successful = true
    else
      attack_successful = false
    end

    attack_successful
  end

  def set_ship_locations(locations_hsh)
    locations_hsh.each do |ship_type, ships_to_create|
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

  SHIP_TYPES = %i(carrier battleship cruiser destroyer)

  SHIP_LENGTHS = {
    carrier: 5,
    battleship: 4,
    cruiser: 3,
    destroyer: 2
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


class Player
  attr_accessor :ships, :enemy_ships, :name

  def initialize(name, filename)
    @name = name
    file = File.read(filename)
    ship_locations = JSON.parse(file, symbolize_names: true)
    @ships = Board.new(:your_ships)
    @ships.set_ship_locations(ship_locations)

    @enemy_ships = Board.new(:enemy_ships)
  end

  def attack(x, y)
    @ships.attack!(x, y)
  end

  def fire_on(player, x, y)
    hit = player.attack(x, y)
    marker = hit ? 'x' : 'o'

    @enemy_ships.grid[y][x] = marker

    hit
  end

  def defeat?
    @ships.lose?
  end
end


puts "BATTLESHIP RUBY EDITION"
puts

puts "Player one, what is your name?"
player_one_name = gets.chomp

puts "Player two, what is your name?"
player_two_name = gets.chomp

current_player = Player.new(player_one_name, "player_one.json")
next_player = Player.new(player_two_name, "player_two.json")

puts
puts

while 1 do
  puts
  puts
  puts "*** #{current_player.name} ***"
  puts "Enemy ships:"
  current_player.enemy_ships.draw
  puts "Your ships:"
  current_player.ships.draw

  puts "Fire at #{next_player.name} (x, y): "
  target = gets.chomp.split(',')

  hit = current_player.fire_on(next_player, target[0].to_i, target[1].to_i)

  if hit
    puts "You hit #{next_player.name}!"
  else
    puts "You missed!"
  end

  if next_player.defeat?
    puts "#{current_player.name} has won!!!!1111"
    break
  end

  current_player, next_player = next_player, current_player
end
