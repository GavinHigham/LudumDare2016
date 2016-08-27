
Animation = {
	frame = 0
}

function Animation.new(frameTable)
	return {startedOn = Animation.frame, frames = frameTable, playedOnce = false}
end

--dt is unused, for now.
function Animation.update(dt)
	Animation.frame = Animation.frame + 1
end

function Animation.draw(animation, x, y, r, sx, sy, ox, oy, kx, ky)
	frameNum = Animation.frame - animation.startedOn
	if frameNum >= #(animation.frames) then
		animation.playedOnce = true
		frameNum = frameNum % #(animation.frames)
	end
	love.graphics.draw(animation.frames[frameNum + 1], x, y, r, sx, sy, ox, oy, kx, ky)
end

function Animation.restart(animation)
	animation.startedOn = Animation.frame
	animation.playedOnce = false
end