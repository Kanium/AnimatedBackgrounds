local moonshine = require 'moonshine'
require "mic"
require "lua-caca"

function love.load()
	love.window.setMode(1280, 720, {resizable=true, vsync=false, minwidth=400, minheight=300})
	love.window.setTitle("ASCII-KANIUM")
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	
    imgSurprise = love.graphics.newImage("surprised.jpg")
	imgGreytest = love.graphics.newImage("greytest.png")
	imgKaniumA = love.graphics.newImage("kaniumAltered.png")
	imgKaniumN = love.graphics.newImage("kaniumNormal.png")
	imgKaniumN2 = love.graphics.newImage("kaniumNormal2.png")
	
    imgWidth = screenWidth/11
    imgHeight = screenHeight/11
	
	alteredLogo = {}
	for i = 1,imgWidth do
		alteredLogo[i] = {}
		for j = 1,imgHeight do
			alteredLogo[i][j] = {}
		end
	end
	
	alteredPic = asciify(imgKaniumA, imgWidth, imgHeight, alteredLogo)
	
	normalLogo = {}
	for i = 1,imgWidth do
		normalLogo[i] = {}
		for j = 1,imgHeight do
			normalLogo[i][j] = {}
		end
	end
	
	normalPic = asciify(imgKaniumN, imgWidth, imgHeight, normalLogo)
	
	--Shaders
	effect = moonshine(1280, 720, moonshine.effects.glow).chain(moonshine.effects.chromasep)
	effect.glow.strength = 20
	effect.glow.min_luma = 0.00001
	effect.chromasep.radius = 3
	effect.chromasep.angle = 0.5
	
	minRad = 3
	maxRad = 5
	
	minAngle = 1
	maxAngle = 10
	
	chromaRad = 0
	chromaAngle = 0
	glowStrength = 20
	
	
	--GlobalVariables
	effectTick = 0
	shiftTick = 0
	
	shifted = 0
	shiftTime = love.math.random(1,1)
	nextShift = love.math.random(1,60)
end

function love.update(dt)
	if effectTick >= 10 then
		effectShift()
		effectTick = effectTick - 10
	end
	effectTick = effectTick + 1
	
	if shiftTick >= 5 then
		if shifted == 1 then
			shiftTime = shiftTime - 1
		end
		if nextShift <= 0 and shifted == 0 then
			shifted = 1
		end
		if shiftTime <= 0 then
			shifted = 0
			shiftTime = love.math.random(1,1)
			nextShift = love.math.random(1,60)
		end
		if nextShift > 0 then
			nextShift = nextShift - 1
		end
		shiftTick = shiftTick - 5
	end
	shiftTick = shiftTick + 1
end

function effectShift()
	chromaRad = chromaRad + love.math.random(-10,10)/10
	if chromaRad < minRad then
		chromaRad = minRad
	end
	if chromaRad > maxRad then
		chromaRad = maxRad
	end
	
	chromaAngle = chromaAngle + love.math.random(-10,10)/10
	if chromaAngle < minAngle then
		chromaAngle = minAngle
	end
	if chromaAngle > maxAngle then
		chromaAngle = maxAngle
	end
	
	effect.parameters = {
		chromasep = {radius = chromaRad},
		chromasep = {angle = chromaAngle},
	}
	
end
 
function love.draw()
	love.graphics.setColor(1,1,1,1)
	if recording == 1 then
		getSample()
	end
	effect.draw(function()
		if shifted == 1 then
			for i = 0,imgWidth-1 do
				for j = 0,imgHeight-1 do
					if alteredPic[i+1][j+1][1] == " " or alteredPic[i+1][j+1][1] == "·" or alteredPic[i+1][j+1][1] == ":" then
						local shade = love.math.random(0,5)/10
						love.graphics.setColor(shade,shade,shade,1)
						love.graphics.print(rgbToChar(shade,shade,shade,1),i*11,j*11)
					else
						love.graphics.setColor(alteredPic[i+1][j+1][2]*2,alteredPic[i+1][j+1][3]*0.5,alteredPic[i+1][j+1][4]*0.5,1)
						love.graphics.print(alteredPic[i+1][j+1][1],i*11,j*11)
					end
				end
			end
		else
			for i = 0,imgWidth-1 do
				for j = 0,imgHeight-1 do
					if normalPic[i+1][j+1][1] == " " or normalPic[i+1][j+1][1] == "·" or normalPic[i+1][j+1][1] == ":" then
						local shade = love.math.random(0,5)/10
						love.graphics.setColor(shade,shade,shade,1)
						love.graphics.print(rgbToChar(shade,shade,shade,1),i*11,j*11)
					else
						love.graphics.setColor(normalPic[i+1][j+1][2],normalPic[i+1][j+1][3],normalPic[i+1][j+1][4],(volume/(noisecap-noisegate))+0.2)
						love.graphics.print(normalPic[i+1][j+1][1],i*11,j*11)
					end
				end
			end
		end
	end)
	drawMicControls()
end

function love.keypressed(key)
	micControls(key)
end