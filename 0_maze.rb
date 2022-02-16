require "byebug"

class Array
    def pos_from_coords(coords)
        self[coords[0]][coords[1]]
    end
end

def import_maze(maze_name)
    File.readlines(maze_name).map(&:chomp).map { |line| line.split("") }
end

def print_maze(maze)
    maze.each do |line|
        p line.join
    end
    nil
end

def hash_tiles(maze)
    maze_rows = maze.length
    maze_cols = maze.first.length
    tiles = {}
    maze_rows.times do |row|
        maze_cols.times do |col|
            coords = [row, col]
            tiles[coords] = maze[row][col]
        end
    end
    tiles
end

def get_start_position(maze)
    start_row = 0
    start_col = 0
    (0...maze.length).each do |row|
        if maze[row].include?("S")
            start_row = row
        end
    end
    start_col = maze[start_row].index("S")
    [start_row, start_col]
end

def available_moves(maze, position)
    up = [position[0] - 1, position[1]]
    down = [position[0] + 1, position[1]]
    right = [position[0], position[1] + 1]
    left = [position[0], position[1] - 1]
    moves = {up: up, down: down, right: right, left: left}
    moves.select do |direction, coords|
        [" ", "E"].include?(maze[coords[0]][coords[1]])
    end
end

def advance(maze, current_pos)
    maze[current_pos[0]][current_pos[1]] = maze.pos_from_coords(current_pos) == "S" ? "S" : "X"
    options = available_moves(maze, current_pos)
    destination = options[:up] || options[:right] || options[:down] || options[:left]
end

def find_path(maze)
    start_pos = get_start_position(maze)
    current_pos = start_pos

    maze_solved = false
    no_more_path = false
    until no_more_path
        current_pos = advance(maze, current_pos)
        print_maze(maze)
        if maze.pos_from_coords(current_pos) == "E"
            no_more_path = true
            maze_solved = true
        elsif available_moves(maze, current_pos).length == 0
            no_more_path = true
            maze_solved = false
        end
    end
    maze_solved
end

if __FILE__ == $PROGRAM_NAME
    puts "Enter the name of the maze file to use (without the .txt):"
    maze_name = gets.chomp + ".txt"
    maze = import_maze(maze_name)
    if find_path(maze)
        puts "SUCCESS!"
    else
        puts "Failure, dead end."
    end
    print_maze(maze)
end