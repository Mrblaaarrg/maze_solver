class Tile
    def initialize(position, content, parent = nil)
        @position = position
        @content = content
        @parent = parent
        @fvalue = 0
        @gvalue = 0
        @hvalue = 0
    end

    attr_reader :position, :content
    attr_accessor :fvalue, :gvalue, :hvalue, :parent
end