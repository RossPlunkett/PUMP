local G = {}


local grass_area = {}
grass_area.start = {}
grass_area.start.x = -2500
grass_area.start.y = -2000
grass_area.the_end = {}
grass_area.the_end.x = 2500
grass_area.the_end.y = 2000

G.gf_atlas = love.graphics.newImage("assets/gfx/gentle_forest.png")

G.basic_grass= love.graphics.newQuad(80,32,48,16,G.gf_atlas:getDimensions())

local grass_scale = 3
local grass_width = 48*grass_scale
local grass_height = 16*grass_scale

G.flower_quads = {
love.graphics.newQuad(0, 144, 16, 16, G.gf_atlas:getDimensions()),
love.graphics.newQuad(16, 144, 16, 16, G.gf_atlas:getDimensions()),
love.graphics.newQuad(0, 160, 16, 16, G.gf_atlas:getDimensions()),
love.graphics.newQuad(16, 160, 16, 16, G.gf_atlas:getDimensions()),
love.graphics.newQuad(32, 160, 16, 16, G.gf_atlas:getDimensions())
}

local flower_scale = 2


function G:draw_grass()

    local save_the_start = grass_area.start.x

    local draw_pos = {}
    draw_pos.x = grass_area.start.x
    draw_pos.y = grass_area.start.y

    while draw_pos.y < grass_area.the_end.y do
        if draw_pos.x > grass_area.the_end.x then
            --start a new row
            grass_area.start.x = grass_area.start.x - 4
            draw_pos.y = draw_pos.y + grass_height
            draw_pos.x = grass_area.start.x
        end
        love.graphics.setColor(0.85, 0.85, 0.85, 1)
        love.graphics.draw(self.gf_atlas, self.basic_grass,draw_pos.x,draw_pos.y, 0, grass_scale, grass_scale)
        --advance x
        draw_pos.x = draw_pos.x + grass_width
    end

    grass_area.start.x = save_the_start

end

function G:make_flowers()

    self.flowers = {}

    local i = 0
    while i < 200 do
        local posx = grass_area.start.x + math.random(grass_area.the_end.x - grass_area.start.x)
        local posy = grass_area.start.y + math.random(grass_area.the_end.y - grass_area.start.y)
        local flower = math.random(#self.flower_quads)
        table.insert(self.flowers, {posx, posy, flower})
        i = i + 1
    end
end

function G:draw_flowers()

    for _, v in ipairs(self.flowers) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.gf_atlas, self.flower_quads[v[3]], v[1], v[2], 0, flower_scale, flower_scale)
    end
end

return G