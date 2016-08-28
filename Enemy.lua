--[[

	Ancient Technology Ludumn Dare Game Jam 2016
	By: Gavin Higham, Josh Maurer, and Tai Enrico

]]

currentState = "Seek"
enemyIsStunned = false
enemyStunDuration = 30
nextState = "Seek"

function enemyUpdate()
	transitionFunction()
	enemyAction()
	currentState = nextState
end

function enemyAction()
	if (currentState == "Seek") then
		enemyPositionUpdate()
	else if (currentState == "Attack") then 
		enemyDoAttack()
	else if (currentState == "Stunned") then
		enemyIsStunned = true
	else if (currentState == "Death") then
		enemyIsDead()
	else
		currentState == "Seek"
	end
end

function transitionFunction()
	if (currentState == "Seek") then
		nextState = checkPreSeek()
	else if (currentState == "Attack") then 
		nextState = "Seek"
	else if (currentState == "Stunned") then
		if (enemyStunDuration >0) then 
			enemyStunDuration = enemyStunDuration -1;
		else
			enemyStunDuration = 30
			nextState = "Seek"
		end
	else
		currentState == "Seek"
	end
end