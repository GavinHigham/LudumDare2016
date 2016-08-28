--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico

]]

require("Animation")
require("Tiles")
require("Enemy")

enemies = {numAlive = 1, maxAlive = 100, pool = {}}

explosions = {}

maxEngergy = 50
robot = {x = 400, y = 300, vel = 1, sprite = nil, energy = maxEnergy, range = 5}
laserIsOn = false

function love.load()
	explosionFrames = {}
	for i = 1, 100 do
		table.insert(explosionFrames, love.graphics.newImage(string.format("sprites/explosion/%.4u.png", i)))
	end
	robot.sprite = love.graphics.newImage("sprites/blob.png")
	tiles = createTiles(gridSize, gridSize)
	
	table.insert(enemies.pool, enemy.create(400, 500))
end

function love.update(dt)
	for i, explosion in ipairs(explosions) do
		if explosion.playedOnce then
			explosions[i] = explosions[#explosions]
			explosions[#explosions] = nil
		end
	end
	Animation.update(dt)
	
	local mx, my = love.mouse.getPosition()
	
	if love.mouse.isDown(1) then
		local newExplosion = Animation.new(explosionFrames)
		newExplosion.x = mx-18
		newExplosion.y = my-85
		table.insert(explosions, newExplosion)
		laserIsOn = true
	else
		laserIsOn = false
	end
	
	if love.mouse.isDown(2) then
		local tile = getTileAt(mx, my)
		if tile ~= nil and robot.checkRange(mx, my) then
			tile.up = true
		end
	end
	
	robot.update()
end

function robot.update()
	local move = true
	local dir = 0
	if love.keyboard.isScancodeDown("w") and love.keyboard.isScancodeDown("d") then
		dir = math.pi / -4
	elseif love.keyboard.isScancodeDown("s") and love.keyboard.isScancodeDown("d") then
		dir = math.pi / 4
	elseif love.keyboard.isScancodeDown("s") and love.keyboard.isScancodeDown("a") then
		dir = 3 * math.pi / 4
	elseif love.keyboard.isScancodeDown("w") and love.keyboard.isScancodeDown("a") then
		dir = 5 * math.pi / 4
	elseif love.keyboard.isScancodeDown("w") then
		dir = 3 * math.pi / 2
	elseif love.keyboard.isScancodeDown("s") then
		dir = math.pi / 2
	elseif love.keyboard.isScancodeDown("a") then
		dir = math.pi
	elseif love.keyboard.isScancodeDown("d") then
		dir = 0
	else
		move = false
	end
	
	if move then
		robot.tryToMoveIn(dir)
	end
end

function robot.checkRange(x, y)
	local col = math.floor(x / tileWidth)
	local row = math.floor(y / tileHeight)
	local robCol = math.floor(robot.x / tileWidth)
	local robRow = math.floor(robot.y / tileHeight)
	local dist = math.abs(col - robCol) + math.abs(row - robRow)
	if (dist <= robot.range and dist > 0) then
		return true
	else
		return false
	end
end

function robot.tryToMoveIn(dir)
	local piOverFour = math.pi / 4
	local ax = robot.x + (tileWidth / 2 + robot.vel) * math.cos(dir)
	local ay = robot.y + (tileHeight / 2 + robot.vel) * math.sin(dir)
	local bx = robot.x + (tileWidth / 2 + robot.vel) * math.cos(dir + piOverFour)
	local by = robot.y + (tileHeight / 2 + robot.vel) * math.sin(dir + piOverFour)
	local cx = robot.x + (tileWidth / 2 + robot.vel) * math.cos(dir - piOverFour)
	local cy = robot.y + (tileHeight / 2 + robot.vel) * math.sin(dir - piOverFour)
	local vel = robot.vel
	
	if checkTileCollisionAt(ax, ay) then
		vel = 0
	elseif checkTileCollisionAt(bx, by) and not checkTileCollisionAt(cx, cy) then
		dir = dir - piOverFour
	elseif checkTileCollisionAt(cx, cy) and not checkTileCollisionAt(bx, by) then
		dir = dir + piOverFour
	end
	
	robot.x = robot.x + vel * math.cos(dir)
	robot.y = robot.y + vel * math.sin(dir)
end

-- clear all tiles
function love.keypressed(key)
	if key == "space" then
		clearTiles()
	end
end

function love.draw()

	for i, row in ipairs(tiles) do
		for j, tile in ipairs(row) do
			local mode = "line"
			if tile.up then mode = "fill" end
			love.graphics.rectangle(mode, i*tileWidth, j*tileHeight, tileWidth, tileHeight)
		end
	end
	
	for _, en in ipairs(enemies.pool) do
		love.graphics.setColor(255, 0, 0, 150)
		love.graphics.circle("fill", en.x, en.y, 20)
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	
	for i, explosion in ipairs(explosions) do
		Animation.draw(explosion, explosion.x, explosion.y)
	end

	if laserIsOn then
		local x, y = love.mouse.getPosition()
		love.graphics.setColor(255, 0, 0, 200)
		love.graphics.setLineWidth(2)
		love.graphics.line(robot.x, robot.y-20, x, y)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.draw(robot.sprite, robot.x, robot.y, 0, 1, 1, robot.sprite:getWidth() / 2, robot.sprite:getHeight() * 0.8)
	love.graphics.setColor(255, 255, 255, 255)
end