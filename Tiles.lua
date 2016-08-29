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
	if not coordInBounds(x, y) then
		return false
	end
	local tile = getTileAt(x, y)
	if (tile == nil) then
		return false
	end
	return tile.up
end

function tileInBounds(row, col)
	if (row > 0 and col > 0 and row <= gridSize and col <= gridSize) then
		return true
	end
	return false
end

function coordInBounds(x, y)
	if (x >= tileWidth and y >= tileHeight and x <= tileWidth * (gridSize + 1) and y <= tileHeight * (gridSize + 1)) then
		return true
	else
		return false
	end
end