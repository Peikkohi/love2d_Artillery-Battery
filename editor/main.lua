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
      local pos = x - cx ..','.. y - cy
      if map[pos] then
        love.graphics.draw(tileset, tiles[map[pos]], x, y, 0, SCALE)
      end

      if mode == 'border' and border[pos] then
        love.graphics.points(x, y)

        for pos, _ in pairs(border[pos]) do
          local _x, _y = pos:match('(%S+),(%S+)')
          love.graphics.line(x, y, _x + cx, _y + cy)
        end
      end
    end
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

    local _br = {}
    for pos, t in pairs(border) do
      for _pos, _ in pairs(t) do
        local x, y = pos:match('(%S+),(%S+)')
        local _x, _y = _pos:match('(%S+),(%S+)')

        if x > _x or (x == _x and y > _y) then
          _br[x ..','.. y ..','.. _x ..','.. _y] = true
        else
          _br[_x ..','.. _y ..','.. x ..','.. y] = true
        end
      end
    end

    for pos, _ in pairs(_br) do
      file:write(string.format('border: %s\n', pos))
    end

    file:close()
    return
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

    local _pos = rx ..','.. ry

    if bt == 1 then
      first_pos = _pos
    elseif border[_pos] then
      for pos, _ in pairs(border[_pos]) do
        border[pos][_pos] = nil
        if not next(border[pos]) then border[pos] = nil end
      end

      border[_pos] = nil
    end
  end
end

function love.mousereleased(mx, my, bt)
  if mode == 'border' and bt == 1 then
    local rx = mx - math.floor(camera.x)
    local ry = my - math.floor(camera.y)
    rx = rx - (rx - HALF_SIZE) % BOX_SIZE + HALF_SIZE
    ry = ry - (ry - HALF_SIZE) % BOX_SIZE + HALF_SIZE

    local _pos = rx ..','.. ry

    if not border[first_pos] then border[first_pos] = {} end
    if not border[_pos] then border[_pos] = {} end

    border[first_pos][_pos] = true
    border[_pos][first_pos] = true

    first_pos = nil
  end
end
