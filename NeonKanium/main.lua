local moonshine = require 'moonshine'

function love.load()
	love.window.setTitle("Neon Kanium")
	love.window.setMode(1280, 720, {resizable=true, vsync=false, minwidth=400, minheight=300})
	love.graphics.setBackgroundColor( 0, 0, 0, 1 )
	logo = love.graphics.newImage("logo.png")
	effect = moonshine(1280, 720, moonshine.effects.glow).chain(moonshine.effects.boxblur)
	effect.glow.strength = 10
	effect.glow.min_luma = 0.0001
	effect.boxblur.radius = {3,3}
	blits = {}
	deadBlits = 0
	screenWidth = 1280
	screenHeight = 720
	tick = 0
	moveAmount = 3
	turnChance = 99
	blitNum = 8
	logoStrength = 0
	logoState = "waxing"
end

function love.update(dt)
	if tick >= 10 then
		if #blits < blitNum then
			newBlit()
		end
		moveBlits()
		logoPulse()
		tick = tick - 10
	end
	tick = tick + 1
end

function love.resize(w, h)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	effect.resize(screenWidth, screenHeight)
	scale = screenHeight/720
end

function moveBlits()
	for i = 1,#blits do
		if blits[i].lifetime > 0 then
			if blits[i].dir == 1 then
				blits[i].y = blits[i].y - moveAmount
			elseif blits[i].dir == 2 then
				blits[i].x = blits[i].x + moveAmount
			elseif blits[i].dir == 3 then
				blits[i].y = blits[i].y + moveAmount
			elseif blits[i].dir == 4 then
				blits[i].x = blits[i].x - moveAmount
			end
			if blits[i].x > screenWidth then
				blits[i].x = 0
			elseif blits[i].x < 0 then
				blits[i].x = screenWidth
			end
			if blits[i].y > screenHeight then
				blits[i].y = 0
			elseif blits[i].y < 0 then
				blits[i].y = screenHeight
			end
			table.insert(blits[i].trail,1,{blits[i].x,blits[i].y})
		end
		while #blits[i].trail > blits[i].trailMax do
			table.remove(blits[i].trail,#blits[i].trail)
		end
		if love.math.random(1,100) >= turnChance then
			if love.math.random(0,1) > 0 then
				blits[i].dir = blits[i].dir + 1
			else
				blits[i].dir = blits[i].dir - 1
			end
			if blits[i].dir > 4 then
				blits[i].dir = 1
			elseif blits[i].dir < 1 then
				blits[i].dir = 4
			end
		end
		blits[i].lifetime = blits[i].lifetime - 1
		if blits[i].lifetime <= 0 then
			if #blits[i].trail > 0 then
				blits[i].trailMax = blits[i].trailMax-1
			end
			if #blits[i].trail == 0 then
				deadBlits = deadBlits + 1
			end
		end
	end
	while deadBlits > 0 do
		for i = 1,#blits do
			if blits[i].lifetime <= 0 and #blits[i].trail == 0 then
				table.remove(blits,i)
				deadBlits = deadBlits - 1
				break
			end
		end
	end
end

function logoPulse()
	if logoState == "waning" then
		logoStrength = logoStrength - love.math.random(0.5,1)/100
		if logoStrength <= 0.1 then
			logoStrength = 0.1
			logoState = "waxing"
		end
	else
		logoStrength = logoStrength + love.math.random(0.5,1)/100
		if logoStrength >= 0.8 then
			logoStrength = 0.8
			logoState = "waning"
		end
	end
end

function love.draw()
    effect.draw(function()
		for i = 1,#blits do
			love.graphics.setColor(blits[i].colorR,blits[i].colorG,blits[i].colorB,1)
			love.graphics.circle("fill", blits[i].x,blits[i].y,4)
			if #blits[i].trail > 0 then
				for j = 1,#blits[i].trail do
					love.graphics.setColor(blits[i].colorR,blits[i].colorG,blits[i].colorB,(blits[i].trailMax-j+1)/blits[i].trailMax)
					love.graphics.circle("fill", blits[i].trail[j][1],blits[i].trail[j][2],4)
				end
			end
			love.graphics.setColor(0,0,0,1)
			love.graphics.circle("fill",screenWidth/2,screenHeight/2-30,220)
			love.graphics.setColor(0,0.5,1,logoStrength)
			love.graphics.draw(logo,screenWidth/2-(629/2)-15,-15,0,1.05,1.05)
		end
    end)
	love.graphics.draw(logo,screenWidth/2-(629/2),0)
end

function newBlit()
	local blit = {}
	blit.x = love.math.random(0,screenWidth)
	blit.y = love.math.random(0,screenHeight)
	blit.colorR = 0
	blit.colorG = 0
	blit.colorB = 0
	while (blit.colorR + blit.colorB + blit.colorG < 1.8) and (blit.colorR < 1 and blit.colorB < 1 and blit.colorG < 1) or (blit.colorR + blit.colorB + blit.colorG > 2.2) do
		blit.colorR = 0--love.math.random(0,10)/10
		blit.colorG = love.math.random(30,40)/100
		blit.colorB = 1--love.math.random(0,10)/10
	end
	blit.dir = love.math.random(1,4)
	blit.trail = {}
	blit.trailMax = love.math.random(200/moveAmount,500/moveAmount)
	blit.lifetime = love.math.random(600/moveAmount,1500/moveAmount)
	blits[1+#blits] = blit
end