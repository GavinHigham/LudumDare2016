tiles = nil

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

function clearTiles()
	for _, row in pairs(tiles) do
		for _, tile in pairs(row) do
			tile.up = false
		end
	end
end

function getTileAt(x, y)
	local col = math.floor(x / tileWidth)
	local row = math.floor(y / tileHeight)
	if col < 1 or row < 1 or col > gridSize or row > gridSize then
		return nil
	end
	return tiles[col][row]
end

function checkTileCollisionAt(x, y)
	local tile = getTileAt(x, y)
	return tile.up
end