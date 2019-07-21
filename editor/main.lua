local file

local map = {}

local SCALE = 3
local BOX_SIZE = 16

local tileset
local tiles = {}
local selected = 0

local camera = {x = 0, y = 0}
local mouse = {x = love.mouse.getX, y = love.mouse.getY, bt = love.mouse.isDown}

function love.load()
  local ww, wh = love.window.getDesktopDimensions()
  love.window.updateMode(ww, wh)

  tileset = love.graphics.newImage('assets/tileset.png')
  tileset:setFilter('nearest')

  local width, height = tileset:getDimensions()
  for x = 1, width/BOX_SIZE do
    for y = 1, height/BOX_SIZE do
      table.insert(tiles, love.graphics.newQuad(BOX_SIZE * (x - 1),
      BOX_SIZE * (y - 1), BOX_SIZE, BOX_SIZE, width, height))
    end
  end

  BOX_SIZE = BOX_SIZE * SCALE
end

function love.update(dt)
  local up = love.keyboard.isDown('w') and 1 or 0
  local dn = love.keyboard.isDown('s') and 1 or 0
  local rt = love.keyboard.isDown('d') and 1 or 0
  local lt = love.keyboard.isDown('a') and 1 or 0

  camera.x = camera.x + (lt - rt) * dt * 100
  camera.y = camera.y + (up - dn) * dt * 100

  if (mouse.bt(1) and 1 or 0) + (mouse.bt(2) and 1 or 0) == 1 then
    local rx = mouse.x() - math.floor(camera.x)
    local ry = mouse.y() - math.floor(camera.y)
    rx = rx - rx % BOX_SIZE
    ry = ry - ry % BOX_SIZE

    map[rx ..','.. ry] = mouse.bt(1) and (selected + 1) or nil
  end
end

function love.draw()

  local cx = math.floor(camera.x)
  local cy = math.floor(camera.y)
  local ww, wh = love.graphics.getDimensions()

  for x = cx % BOX_SIZE - BOX_SIZE, ww, BOX_SIZE do
    for y = cy % BOX_SIZE - BOX_SIZE, wh, BOX_SIZE do
      local tile = map[x - cx ..','.. y - cy]
      if tile then love.graphics.draw(tileset, tiles[tile], x, y, 0, SCALE) end
    end
  end

  local rx = mouse.x() - (mouse.x() - cx) % BOX_SIZE
  local ry = mouse.y() - (mouse.y() - cy) % BOX_SIZE

  love.graphics.draw(tileset, tiles[selected + 1], rx, ry, 0, SCALE)
  love.graphics.rectangle('line', rx, ry, BOX_SIZE, BOX_SIZE)
end

function love.wheelmoved(x, y)
  selected = (selected + y) % #tiles
end
