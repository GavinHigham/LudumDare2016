function love.conf(t)
	gridSize = 21
	tileWidth, tileHeight = 40, 30
	t.window.title = "Ancient Robot"
	t.window.fullscreen = false
	t.window.width = tileWidth * (gridSize + 2)
	t.window.height = tileHeight * (gridSize + 2)
end