local chull = require("convex_hull")
local table_helper = require("table_helper")

local raw_points = {}
local boundary = {}
local boundary_text = {}

local phase = "CREATE_POINTS"

local normal_length = 30
local color = {
	blue   = {000,000,255},
	red    = {255,000,000},
	green  = {000,255,000},
	yellow = {000,255,255},
	white  = {255,255,255}
}

function love.mousepressed(x,y,button)
	if phase == "CREATE_POINTS" then
		table.insert(raw_points,{x,y})
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
	end
end

function love.mousereleased(x, y, button)
	if phase == "CREATE_POINTS" then
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
	end
end

function love.wheelmoved(x, y)
	if phase == "CREATE_POINTS" then
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
	end
end

function love.load()
	love.graphics.setPointSize(5)
end

function love.update(dt)
end

function love.keypressed( key, scancode, isrepeat )
	if phase == "CREATE_POINTS" then
		if key == "return" and not isrepeat then
			boundary = chull.points(raw_points)

			table.insert(boundary,boundary[1]) -- make boundary list circular

			phase = "SET_BOUNDARY_CONDITIONS"
		end
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
		if key == "backspace" and not isrepeat then
			boundary_text[draw_closest().min_index] = ""
		end
	end
end

function love.textinput(key)
	if phase == "CREATE_POINTS" then
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
		boundary_text[draw_closest().min_index] = (boundary_text[draw_closest().min_index] or "") .. key
	end
end

function draw_boundary()
	for index,point in ipairs(boundary) do
		local nextx = boundary[index + 1 <= table.getn(boundary) and index + 1 or 2][1] - point[1]
		local nexty = boundary[index + 1 <= table.getn(boundary) and index + 1 or 2][2] - point[2]

		local nextl = math.sqrt(nextx*nextx + nexty*nexty)
		nextx = nextx / nextl
		nexty = nexty / nextl

		local prevx = boundary[index - 1 >= 1 and index - 1 or index - 2 + table.getn(boundary)][1] - point[1]
		local prevy = boundary[index - 1 >= 1 and index - 1 or index - 2 + table.getn(boundary)][2] - point[2]

		local prevl = math.sqrt(prevx*prevx + prevy*prevy)
		prevx = prevx / prevl
		prevy = prevy / prevl

		local dx = (nextx + prevx)/2
		local dy = (nexty + prevy)/2

		local dl = math.sqrt(dx*dx+dy*dy)
		dx = dx/dl
		dy = dy/dl

		love.graphics.setColor(color.red)
		love.graphics.points({
			point[1]-normal_length*dx,
			point[2]-normal_length*dy
		})

		love.graphics.setColor(color.blue)
		love.graphics.line({
			point[1],
			point[2],
			point[1]-normal_length*dx,
			point[2]-normal_length*dy,
		})

		love.graphics.setColor(color.white)
		love.graphics.print(boundary_text[index] or "",point[1],point[2])
	end
end

function draw_closest()
	local h = love.graphics.getHeight()
	local w = love.graphics.getWidth()
	local min_dist = h*h+w*w
	local min_point = nil
	local min_index = nil

	local x = love.mouse.getX( )
	local y = love.mouse.getY( )

	for index,point in ipairs(boundary) do
		local dx = x - point[1]
		local dy = y - point[2]

		if dx*dx + dy*dy < min_dist then
			min_dist = dx*dx+dy*dy
			min_point = point
			min_index = index
		end
	end

	love.graphics.setColor(color.white)
	love.graphics.line(min_point[1],min_point[2],x,y)

	return {
		min_point = min_point,
		min_dist  = min_dist,
		min_index = min_index
	}
end

function love.draw()

	love.graphics.setColor(color.yellow)
	love.graphics.print(phase, 5,5)

	if phase == "CREATE_POINTS" then
	elseif phase == "SET_BOUNDARY_CONDITIONS" then
		love.graphics.setColor(color.green)
		love.graphics.line(table_helper.flatten(boundary))

		draw_closest()
		draw_boundary()
	end

	love.graphics.points(raw_points)
end
