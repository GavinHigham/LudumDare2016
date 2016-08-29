--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico
	
	TODO:
	
		GRAPHICS
		- Temple graphic
		- Depth handling for graphics
		
		SOUND
		- Add sounds for tiles raising/lowering
		
		GAMEPLAY
		- Enemy spawning (enemies spawn at the bottom of the screen)
		- Enemy movement logic (enemies will update steering every half second)
			- Enemy A* path finding to top of screen
		- Enemy collision with robot and raised tiles (destroyed if hit raised tile)
		
		- Robot health
		- Robot energy system
		- Robot melee attack to kill enemies (slow cooldown, 1 hit kill, robot is slow)
		- Robot projectile (collides with enemies and tiles, slow fire rate, 1 hit kill)
		- prevent robot from raising tile when an enemy is on it (tile "canRaise" property)
		
		- lose condition when enemy reaches temple for x-amount of time
]]

require("Animation")
require("Tiles")
require("Enemy")
require("Robot")

enemies = {numAlive = 1, maxAlive = 150, pool = {}}

explosions = {}

function loadImages()
	explosionFrames = {}
	for i = 1, 100 do
		table.insert(explosionFrames, love.graphics.newImage(string.format("sprites/explosion/%.4u.png", i)))
	end
	robot.sprite = love.graphics.newImage("sprites/blob.png")
	backgroundImage = love.graphics.newImage("sprites/background.png")
	tileUp = love.graphics.newImage("sprites/tile0001.png")
	tileDown = love.graphics.newImage("sprites/tile0002.png")
end

function love.load()
	loadImages()
	robot.x = tileWidth * gridSize / 2
	robot.y = tileHeight * gridSize / 4
	tiles = createTiles(gridSize, gridSize)
	
	table.insert(enemies.pool, Enemy:new(400, 500))
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
	
	--[[
	if love.mouse.isDown(1) then
		local newExplosion = Animation.new(explosionFrames)
		newExplosion.x = mx-18
		newExplosion.y = my-85
		table.insert(explosions, newExplosion)
		laserIsOn = true
	else
		laserIsOn = false
	end
	]]
	
	if love.mouse.isDown(1) then
		local tile = getTileAt(mx, my)
		if tile ~= nil and robot.checkRange(mx, my) then
			if (robot.energy > 0 and not tile.up) then
				robot.energy = robot.energy - 1
				tile.up = true
			end
		end
	end
	
	robot.update()
	
	if (love.math.random() < 0.02 and enemies.numAlive < enemies.maxAlive) then
		enemies.numAlive = enemies.numAlive + 10
		table.insert(enemies.pool, 
			Enemy:new(
				(love.math.random(gridSize - 1) + 0.5) * tileWidth,
				tileHeight * (gridSize + 0.5)))
	end
	
	local deadEnemies = {}
	local numDead = 0
	
	for i, en in ipairs(enemies.pool) do
		en.y = en.y - 1
		if doesEnemyDie(en.x, en.y) then
			local newExplosion = Animation.new(explosionFrames)
			newExplosion.x = en.x - 18
			newExplosion.y = en.y - 85
			table.insert(explosions, newExplosion)
			table.insert(deadEnemies, i)
			numDead = numDead + 1
		elseif (en.y < tileHeight) then
			love.event.quit()
		end
	end
	
	enemies.numAlive = enemies.numAlive - numDead
	
	for i, j in ipairs(deadEnemies) do
		table.remove(enemies.pool, j - (i - 1))
	end
	
end

-- clear all tiles
function love.keypressed(key)
	if key == "space" then
		clearTiles()
		robot.energy = maxEnergy
	end
end

function love.draw()
	-- draw background
	love.graphics.draw(backgroundImage)
	love.graphics.setColor(50, 200, 255, 150)
	-- draw temple
	love.graphics.rectangle("fill", tileWidth, 0, gridSize * tileWidth, tileHeight)
	
	love.graphics.setColor(255, 255, 255, 255)
	
	-- draw grid of tiles
	for i, row in ipairs(tiles) do
		for j, tile in ipairs(row) do
			local x, y = i*tileWidth, j*tileHeight - tileHeight
			if tile.up then
				love.graphics.draw(tileUp, x, y)
			else
				love.graphics.draw(tileDown, x, y)
			end
		end
	end
	
	-- draw tiles within robot's range
	love.graphics.setColor(0, 255, 0, 50)
	local robCol = math.floor(robot.x / tileWidth)
	local robRow = math.floor(robot.y / tileHeight)
	local n = 0
	for r = robRow-robot.range, robRow+robot.range do
		for c = robCol - n, robCol + n do
			if  tileInBounds(r, c) then
				love.graphics.rectangle("fill", c*tileWidth, r*tileHeight, tileWidth, tileHeight)
			end
		end
		if r < robRow then n = n + 1 else n = n - 1 end
	end
	
	-- draw enemies
	love.graphics.setColor(255, 0, 0, 255)
	for _, en in ipairs(enemies.pool) do
		love.graphics.circle("fill", en.x, en.y, 10)
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	
	-- draw explosions
	for i, explosion in ipairs(explosions) do
		Animation.draw(explosion, explosion.x, explosion.y)
	end

	-- draw laser
	if laserIsOn then
		local x, y = love.mouse.getPosition()
		love.graphics.setColor(255, 0, 0, 200)
		love.graphics.setLineWidth(2)
		love.graphics.line(robot.x, robot.y-20, x, y)
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	-- draw robot
	love.graphics.draw(robot.sprite, robot.x, robot.y, 0, 1, 1, robot.sprite:getWidth() / 2, robot.sprite:getHeight() * 0.8)
	love.graphics.setColor(255, 255, 255, 255)
end

function doesEnemyDie(x, y)
	local dir = 3 * math.pi / 2
	local piOverFour = math.pi / 4
	local vel = 1
	local ax = x + (tileWidth / 2 + vel) * math.cos(dir)
	local ay = y + (tileHeight / 2 + vel) * math.sin(dir)
	local bx = x + (tileWidth / 2 + vel) * math.cos(dir + piOverFour)
	local by = y + (tileHeight / 2 + vel) * math.sin(dir + piOverFour)
	local cx = x + (tileWidth / 2 + vel) * math.cos(dir - piOverFour)
	local cy = y + (tileHeight / 2 + vel) * math.sin(dir - piOverFour)
	
	
	if checkTileCollisionAt(ax, ay) then
		return true
	elseif checkTileCollisionAt(bx, by) and not checkTileCollisionAt(cx, cy) then
		return true
	elseif checkTileCollisionAt(cx, cy) and not checkTileCollisionAt(bx, by) then
		return true
	end
	
	return false
end