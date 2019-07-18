local file

local map = {}

local SCALE = 3
local BOX_SIZE = 16

local tileset
local tiles = {}
local selected = 0

local camera = {x = 0, y = 0}
local mouse = {x = love.mouse.getX, y = love.mouse.getY, bt = {}}

local rx, ry

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
  rx = mouse.x() - mouse.x() % BOX_SIZE
  ry = mouse.y() - mouse.y() % BOX_SIZE

  if (mouse.bt[1] and 1 or 0) + (mouse.bt[2] and 1 or 0) == 1 then
    local cx = rx / BOX_SIZE
    local cy = ry / BOX_SIZE

    if mouse.bt[1] then
      map[cx..','..cy] = selected + 1
    else
      map[cx..','..cy] = nil
    end
  end
end

function love.draw()

  for k, tile in pairs(map) do
    local x, y = k:match('(%S+),(%S+)')
    x, y = x * BOX_SIZE, y * BOX_SIZE
    love.graphics.draw(tileset, tiles[tile], x, y, 0, SCALE)
  end

  love.graphics.draw(tileset, tiles[selected + 1], rx, ry, 0, SCALE)
  love.graphics.rectangle('line', rx, ry, BOX_SIZE, BOX_SIZE)
end

function love.mousepressed(x, y, button, isTouch)
  mouse.bt[button] = true
end

function love.mousereleased(x, y, button, isTouch)
  mouse.bt[button] = nil
end

function love.wheelmoved(x, y)
  selected = (selected + y) % #tiles
end
