--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico

]]

Enemy = {}
Enemy.__index = Enemy

function Enemy.new(xi, yi)
	local en = {}
	setmetatable(en, enemy)
	en.x = xi
	en.y = yi
	en.currentState = "Seek"
	en.nextState = "Seek"
	en.isStunned = false
	en.isDead = false
	en.stunDur = 30
	return en
end

function Enemy:update()
	this:transition()
	this:action()
	this.currentState = this.nextState
end

function Enemy:action()
	if (this.currentState == "Seek") then
		this:updatePosition()
	elseif (this.currentState == "Attack") then 
		this:attack()
	elseif (this.currentState == "Stunned") then
		this.isStunned = true
	elseif (this.currentState == "Death") then
		this.isDead = true
	else
		this.currentState = "Seek"
	end
end

function Enemy:transition()
	if (this.currentState == "Seek") then
		this.nextState = this:checkPreSeek()
	elseif (this.currentState == "Attack") then 
		this.nextState = "Seek"
	elseif (this.currentState == "Stunned") then
		if (this.stunDur >0) then 
			this.stunDur = this.stunDur -1;
		else
			this.stunDur = 30
			this.nextState = "Seek"
		end
	else
		this.currentState = "Seek"
	end
end