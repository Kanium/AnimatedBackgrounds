--local glyphTable = {" ",".",":",";","i","c","1","o","ø","d","&","@"}
local glyphTable = {" ","·",":","°","•","?","¿","º","¢","ý","£","¥"}

function resizedImageData(img, width, height)
  local prevCanvas = love.graphics.getCanvas()
  local canvas = love.graphics.newCanvas(numCols, numRows)
  love.graphics.setCanvas(canvas)
  love.graphics.draw(img, 0, 0, 0, width / img:getWidth(), height / img:getHeight())
  love.graphics.setCanvas(prevCanvas)
  local result = canvas:newImageData()
  return result
end

function rgbToChar(r, g, b, a)
  local grey = (0.2126 * r + 0.7152 * g + 0.0722 * b) * a
  grey = math.min(math.max(grey, 0.0), 0.99999)
  local numGlyphs = #glyphTable
  -- Round to nearest including 0 and N-1
  -- Note that the end only have 0.5 weight, and the middle glyphs have 1.
  local glyph = math.floor(grey * (numGlyphs - 1) + 0.5)
  return glyphTable[glyph+1]
end

function asciify(img, numCols, numRows, array)
  local smallImage = resizedImageData(img, numCols, numRows)
  local outputLines = {}
  -- Construct output characters, pixel positions start at 0
  for i=0,numCols-1 do
    for j=0,numRows-1 do
      local r, g, b, a = smallImage:getPixel(i, j)
      --line[c+1] = rgbToChar(r, g, b, a)
	  local charData = rgbToChar(r, g, b, a)
	  array[i+1][j+1] = {charData,r,g,b}
    end
    --table.insert(outputLines, table.concat(line, ""))
  end
  return array
end