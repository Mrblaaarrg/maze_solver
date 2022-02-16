require "byebug"

class Maze

    def initialize(maze_name)
        @maze_layout = File.readlines(maze_name).map(&:chomp).map { |line| line.split("") }
        @start_pos = self.get_start_position
        @exit_pos = self.get_exit_position
        @current_pos = @start_pos
    end

    attr_reader :maze_layout, :current_pos, :exit_pos

    def get_start_position
        start_row = 0
        start_col = 0
        (0...self.maze_layout.length).each do |row|
            if self.maze_layout[row].include?("S")
                start_row = row
            end
        end
        start_col = self.maze_layout[start_row].index("S")
        [start_row, start_col]
    end

    def get_exit_position
        exit_row = 0
        exit_col = 0
        (0...self.maze_layout.length).each do |row|
            if self.maze_layout[row].include?("E")
                exit_row = row
            end
        end
        exit_col = self.maze_layout[exit_row].index("E")
        [exit_row, exit_col]
    end

    def print_maze
        self.maze_layout.each do |line|
            puts line.join
        end
        nil
    end

    def hash_tiles
        maze_rows = self.maze_layout.length
        maze_cols = self.maze_layout.first.length
        tiles = {}
        maze_rows.times do |row|
            maze_cols.times do |col|
                coords = [row, col]
                tiles[coords] = self.maze_layout[row][col]
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
            [" ", "E"].include?(self.maze_layout[coords[0]][coords[1]])
        end
    end

    def pos_from_coords(coords)
        self.maze_layout[coords[0]][coords[1]]
    end

    def advance
        options = available_moves(self.current_pos)
        destination = options[:up] || options[:right] || options[:down] || options[:left]
        @current_pos = destination
        @maze_layout[self.current_pos[0]][self.current_pos[1]] = self.pos_from_coords(self.current_pos) == "E" ? "E" : "X"
    end

    def find_path
        maze_solved = false
        no_more_path = false
        until no_more_path
            self.advance
            if self.pos_from_coords(self.current_pos) == "E"
                no_more_path = true
                maze_solved = true
            elsif self.available_moves(self.current_pos).length == 0
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
    puts
    maze.print_maze
    puts
end