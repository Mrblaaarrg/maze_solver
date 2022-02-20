require "byebug"
require_relative "1_tile"

class Maze

    def initialize(maze_name)
        @maze_layout = File.readlines(maze_name).map(&:chomp).map { |line| line.split("") }

        # From here A* modifications
        @open_list = {}
        @closed_list = {}
        # End A* mods

        @start_pos = self.get_start_position
        @exit_pos = self.get_exit_position
        @current_pos = @start_pos
        @path = [@start_pos]
    end

    attr_reader :maze_layout, :current_pos, :exit_pos, :path, :open_list, :closed_list

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
        right = [position[0], position[1] + 1]
        down = [position[0] + 1, position[1]]
        left = [position[0], position[1] - 1]
        upright = [position[0] - 1, position[1] + 1]
        downright = [position[0] + 1, position[1] + 1]
        downleft = [position[0] + 1, position[1] - 1]
        upleft = [position[0] - 1, position[1] - 1]
        moves = {up: up, right: right, down: down, left: left, upright: upright, downright: downright, downleft: downleft, upleft: upleft}
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
        options = available_moves(@current_pos).select { |k, v| k.length <= 5 }
        if options.size == 0
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
            elsif self[@current_pos] == "S" && self.available_moves(@current_pos).size == 0
                no_more_path = true
                maze_solved = false
            end
        end
        maze_solved
    end

    def read_tile(position)
        existent_tiles = @open_list.merge(@closed_list)
        existent_tiles[position]
    end

    def gscoring(position, cost = 10)
        existent_tiles = @open_list.merge(@closed_list)
        parent_tile = existent_tiles[position].parent
        return 0 if parent_tile.nil?
        gscore = cost + self.gscoring(parent_tile)
    end

    def hscoring(position)
        row_distance = (@exit_pos[0] - position[0]).abs
        col_distance = (@exit_pos[1] - position[1]).abs
        10 * (row_distance + col_distance)
    end

    def astar_search
        if self[@current_pos].upcase == "S"
            position = @current_pos
            content = self[position]
            start_tile = Tile.new(position, content)
            @open_list[position] = start_tile
        end

        @closed_list[@current_pos] = @open_list.delete(@current_pos)

        options = available_moves(@current_pos)
        options.each do |direction, coords|
            if @open_list.has_key?(coords)
                current_gvalue = @open_list[coords].gvalue
                new_gvalue = direction.length > 5 ? self.gscoring(coords, 14) : self.gscoring(coords)
                if current_gvalue < new_gvalue
                    @open_list[coords].parent = @current_pos
                    gscore = direction.length > 5 ? self.gscoring(coords, 14) : self.gscoring(coords)
                    hscore = self.hscoring(coords)
                    fscore = gscore + hscore
                    @open_list[coords].gvalue = gscore
                    @open_list[coords].hvalue = hscore
                    @open_list[coords].fvalue = fscore
                end
            end

            if !@closed_list.has_key?(coords) && !@open_list.has_key?(coords)
                content = self[coords]
                @open_list[coords] = Tile.new(coords, content, @current_pos)
                gscore = direction.length > 5 ? self.gscoring(coords, 14) : self.gscoring(coords)
                hscore = self.hscoring(coords)
                fscore = gscore + hscore
                @open_list[coords].gvalue = gscore
                @open_list[coords].hvalue = hscore
                @open_list[coords].fvalue = fscore
            end
        end

        next_tile = @open_list.each_value.inject do |minftile, tile|
            tile.fvalue < minftile.fvalue ? tile : minftile
        end

        @current_pos = next_tile.nil? ? @start_pos : next_tile.position
    end

    def draw_path(position)
        return [] if position.nil?
        self[position] = "o" if (self[position] != "E" && self[position] != "S")
        path = [position]
        parent = self.read_tile(position).parent
        path += draw_path(parent)
    end

    def astar_find_path
        maze_solved = false
        no_more_path = false
        until no_more_path
            self.astar_search
            if self[@current_pos] == "E"
                no_more_path = true
                maze_solved = true
            elsif @open_list.size == 0
                no_more_path = true
                maze_solved = false
            end
        end

        @path = self.draw_path(@current_pos)
        
        maze_solved
    end
end

if __FILE__ == $PROGRAM_NAME
    puts "Enter the name of the maze file to use (without the .txt):"
    maze_name = gets.chomp + ".txt"
    maze = Maze.new(maze_name)
    if maze.astar_find_path
        puts "\nSUCCESS!"
    else
        puts "\nFailure, dead end."
    end
    puts "\nTravelled #{maze.path.length} tiles"

    puts
    maze.print_maze
    puts

    puts "###############"
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