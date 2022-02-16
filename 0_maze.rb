require "byebug"

class Maze

    def initialize(maze_name)
        @maze_layout = File.readlines(maze_name).map(&:chomp).map { |line| line.split("") }
        @start_pos = self.get_start_position
        @exit_pos = self.get_exit_position
        @current_pos = @start_pos
        @path = [@start_pos]
    end

    attr_reader :maze_layout, :current_pos, :exit_pos, :path

    def get_start_position
        start_row = 0
        start_col = 0
        (0...@maze_layout.length).each do |row|
            if @maze_layout[row].include?("S")
                start_row = row
            end
        end
        start_col = @maze_layout[start_row].index("S")
        [start_row, start_col]
    end

    def get_exit_position
        exit_row = 0
        exit_col = 0
        (0...@maze_layout.length).each do |row|
            if @maze_layout[row].include?("E")
                exit_row = row
            end
        end
        exit_col = @maze_layout[exit_row].index("E")
        [exit_row, exit_col]
    end

    def print_maze
        @maze_layout.each do |line|
            puts line.join
        end
        nil
    end

    def hash_tiles
        maze_rows = @maze_layout.length
        maze_cols = @maze_layout.first.length
        tiles = {}
        maze_rows.times do |row|
            maze_cols.times do |col|
                coords = [row, col]
                tiles[coords] = @maze_layout[row][col]
            end
        end
        tiles
    end

    def available_moves(position)
        up = [position[0] - 1, position[1]]
        down = [position[0] + 1, position[1]]
        right = [position[0], position[1] + 1]
        left = [position[0], position[1] - 1]
        moves = {up: up, down: down, right: right, left: left}
        moves.select do |direction, coords|
            [" ", "E"].include?(@maze_layout[coords[0]][coords[1]])
        end
    end

    def pos_from_coords(coords)
        @maze_layout[coords[0]][coords[1]]
    end

    def [](coords)
        @maze_layout[coords[0]][coords[1]]
    end

    def []=(coords, value)
        @maze_layout[coords[0]][coords[1]] = value
    end

    def dumb_advance
        options = available_moves(@current_pos)
        destination = options[:up] || options[:right] || options[:down] || options[:left]
        @current_pos = destination
        self[@current_pos] = self[@current_pos] == "E" ? "E" : "o"
    end

    def advance
        options = available_moves(@current_pos)
        if options.length == 0
            self[@current_pos] = "x"
            @path.pop
            @current_pos = @path.last
        else
            destination = options[:up] || options[:right] || options[:down] || options[:left]
            @current_pos = destination
            self[@current_pos] = self[@current_pos] == "E" ? "E" : "o"
            @path << @current_pos
        end
    end

    def find_path
        maze_solved = false
        no_more_path = false
        until no_more_path
            self.advance
            if self[@current_pos] == "E"
                no_more_path = true
                maze_solved = true
            elsif self[@current_pos] == "S" && self.available_moves(@current_pos).length == 0
                no_more_path = true
                maze_solved = false
            end
        end
        maze_solved
    end
end

if __FILE__ == $PROGRAM_NAME
    puts "Enter the name of the maze file to use (without the .txt):"
    maze_name = gets.chomp + ".txt"
    maze = Maze.new(maze_name)
    if maze.find_path
        puts "\nSUCCESS!"
    else
        puts "\nFailure, dead end."
    end
    puts "\nTravelled #{maze.path.length} tiles"

    puts
    maze.print_maze
    puts
end