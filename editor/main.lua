local file

local map = {}
local border = {}
local first_pos

local SCALE = 3
local BOX_SIZE = 16
local HALF_SIZE

local tileset
local tiles = {}
local selected = 0
local mode = 'tile'

local camera = {}
local mouse = {x = love.mouse.getX, y = love.mouse.getY, bt = love.mouse.isDown}

function love.load()
  local ww, wh = love.window.getDesktopDimensions()
  love.window.updateMode(ww, wh)

  love.graphics.setPointSize(10)

  camera.x = ww/2
  camera.y = wh/2

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
  HALF_SIZE = BOX_SIZE/2
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

    if mode == 'tile' then
      map[rx ..','.. ry] = mouse.bt(1) and (selected + 1) or nil
    end
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

  for i, line in ipairs(mode == 'border' and border or {}) do
    love.graphics.line(line[1] + cx, line[2] + cy, line[3] + cx, line[4] + cy)
  end

  if mode == 'tile' then
    local rx = mouse.x() - (mouse.x() - cx) % BOX_SIZE
    local ry = mouse.y() - (mouse.y() - cy) % BOX_SIZE

    love.graphics.draw(tileset, tiles[selected + 1], rx, ry, 0, SCALE)
    love.graphics.rectangle('line', rx, ry, BOX_SIZE, BOX_SIZE)
  elseif mode == 'border' then
    local rx = mouse.x() - (mouse.x() - cx - HALF_SIZE) % BOX_SIZE + HALF_SIZE
    local ry = mouse.y() - (mouse.y() - cy - HALF_SIZE) % BOX_SIZE + HALF_SIZE

    love.graphics.points(rx, ry)
    if first_pos then
      local x, y = first_pos:match('(%S+),(%S+)')
      love.graphics.line(rx, ry, x + camera.x, y + camera.y)
    end
  end

  love.graphics.print(mode, 10, 10)
end

function love.wheelmoved(x, y)
  selected = (selected + y) % #tiles
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'return' then
    file = io.open(love.filesystem.getSource()..'map', 'w')

    for pos, tile in pairs(map) do
      local x, y = pos:match('(%S+),(%S+)')
      x, y = x/BOX_SIZE, y/BOX_SIZE
      file:write(string.format('tile: %s pos: %d,%d\n', tile, x, y))
    end

    for i, line in ipairs(border) do
      file:write(string.format('border: %d,%d,%d,%d\n', unpack(line)))
    end

    file:close()
  end

  if key == 'm' then
    local modes = {border = 'tile', tile = 'border'}

    mode = modes[mode]
  end
end

function love.mousepressed(mx, my, bt)
  if mode == 'border' then
    local rx = mx - math.floor(camera.x)
    local ry = my - math.floor(camera.y)
    rx = rx - (rx - HALF_SIZE) % BOX_SIZE + HALF_SIZE
    ry = ry - (ry - HALF_SIZE) % BOX_SIZE + HALF_SIZE

    first_pos = rx ..','.. ry
  end
end

function love.mousereleased(mx, my, bt)
  if mode == 'border' then
    local rx = mx - math.floor(camera.x)
    local ry = my - math.floor(camera.y)
    rx = rx - (rx - HALF_SIZE) % BOX_SIZE + HALF_SIZE
    ry = ry - (ry - HALF_SIZE) % BOX_SIZE + HALF_SIZE

    local x, y = first_pos:match('(%S+),(%S+)')
    x, y = tonumber(x), tonumber(y)

    first_pos = nil
    table.insert(border, {x, y, rx, ry})
  end
end
