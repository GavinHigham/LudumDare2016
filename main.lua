--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico

]]

require("Animation")
explosions = {}
robot = {x = 400, y = 300, vel = 1, sprite = nil}
tiles = nil
laserIsOn = false
tileWidth, tileHeight = 100, 100

function createTile()
	local tile = {up = false}
	return tile
end

function createTiles(numcols, numrows)
	local tiles = {}
	for i = 1, numrows do
		local row = {}
		for j = 1, numcols do
			table.insert(row, createTile())
		end
		table.insert(tiles, row)
	end
	return tiles
end

function love.load()
	explosionFrames = {}
	for i = 1, 100 do
		table.insert(explosionFrames, love.graphics.newImage(string.format("sprites/explosion/%.4u.png", i)))
	end
	robot.sprite = love.graphics.newImage("sprites/blob.png")
	tiles = createTiles(15, 15)
	tiles[2][2].up = true
end

function love.update(dt)
	for i, explosion in ipairs(explosions) do
		if explosion.playedOnce then
			explosions[i] = explosions[#explosions]
			explosions[#explosions] = nil
		end
	end
	Animation.update(dt)
	if love.mouse.isDown(1) then
		local newExplosion = Animation.new(explosionFrames)
		local x, y = love.mouse.getPosition()
		newExplosion.x = x-18
		newExplosion.y = y-85
		table.insert(explosions, newExplosion)
		laserIsOn = true
	else
		laserIsOn = false
	end
	robot.update()
end

function robot.update()
	if love.keyboard.isScancodeDown("w") then
		robot.y = robot.y - robot.vel
	end
	if love.keyboard.isScancodeDown("s") then
		robot.y = robot.y + robot.vel
	end
	if love.keyboard.isScancodeDown("a") then
		robot.x = robot.x - robot.vel
	end
	if love.keyboard.isScancodeDown("d") then
		robot.x = robot.x + robot.vel
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

	for i, explosion in ipairs(explosions) do
		Animation.draw(explosion, explosion.x, explosion.y)
	end

	if laserIsOn then
		local x, y = love.mouse.getPosition()
		love.graphics.setColor(255, 0, 0, 200)
		love.graphics.setLineWidth(2)
		love.graphics.line(robot.x+30, robot.y+30, x, y)
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.draw(robot.sprite, robot.x, robot.y)
end