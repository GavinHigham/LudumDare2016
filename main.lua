--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico

]]

require("Animation")
require("Tiles")
require("Enemy")
require("Robot")

enemies = {numAlive = 1, maxAlive = 100, pool = {}}

explosions = {}

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