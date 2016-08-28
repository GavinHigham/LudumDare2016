maxEngergy = 50
robot = {x = 400, y = 300, vel = 1, sprite = nil, energy = maxEnergy, range = 5}
laserIsOn = false

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