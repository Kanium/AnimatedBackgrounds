local moonshine = require 'moonshine'

function love.load()
	love.window.setTitle("PixelFall")
	love.window.setMode(1280, 720, {resizable=true, vsync=false, minwidth=400, minheight=300})
	love.graphics.setBackgroundColor( 0, 0, 0, 1 )
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	scale = 1
	logo = love.image.newImageData("logo.png")
	map = {}
	for i = 0, logo:getWidth() do
		map[i] = {}
		for j = 0, logo:getHeight() do
			map[i][j] = 0
		end
	end
	for i = 0, logo:getWidth()-1 do
		for j = 0, logo:getHeight()-1 do
			r, g, b, a = logo:getPixel( i, j )
			if r + b + g < 3 then
				map[i][j] = 1
			else
				local lightlevel = love.math.random(2,5)/100
				map[i][j] = lightlevel
			end
		end
	end
	
	effect = moonshine(screenWidth, screenHeight, moonshine.effects.glow).chain(moonshine.effects.boxblur)
	effect.glow.strength = 10
	effect.glow.min_luma = 0.0001
	effect.boxblur.radius = {2,2}
	
	drops = {}
	deadDrops = 0
	dropNum = 1
	tick = 0
	spawnTick = 0
	moveTick = 10
	spawnTick = 200
end

function love.resize(w, h)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	effect.resize(screenWidth, screenHeight)
	scale = screenHeight/720
	drops = {}
	
end

function love.update()
	moveDropAfterNumberOfTicks(moveTick)
	spawnDropAfterNumberOfTicks(spawnTick)
end

function moveDropAfterNumberOfTicks(i)
	if tick >= i then
		moveDrops() 
		tick = 0
	end
	tick = tick + 1
end

function spawnDropAfterNumberOfTicks(i)
	if spawnTick >= i then
		if #drops < dropNum then
			newDrop()
		end
		spawnTick = 0
	end
	spawnTick = spawnTick + 1
end

function love.draw()
	effect.disable("glow")
	effect.draw(function()
		for i = 0, logo:getWidth() do
			for j = 0, logo:getHeight() do
				if map[i][j] == 1 then
					love.graphics.setColor(0.2,0.2,0.2,1)
					love.graphics.rectangle("fill",i*10,j*10,10,10)
				else
					love.graphics.setColor(map[i][j],map[i][j],map[i][j],1)
					love.graphics.rectangle("fill",i*10,j*10,10,10)
				end
			end
		end
	end)
	effect.enable("glow")
	effect.draw(function()
		for i = 1, #drops do
			love.graphics.setColor(drops[i].colorR,drops[i].colorG,drops[i].colorB,1)
			love.graphics.rectangle("fill", drops[i].x*10,drops[i].y*10,10,10)
			if #drops[i].trail > 0 then
				for j = 1,#drops[i].trail do
					love.graphics.setColor(drops[i].colorR,drops[i].colorG,drops[i].colorB,(drops[i].trailMax-j+1)/drops[i].trailMax)
					love.graphics.rectangle("fill", drops[i].trail[j][1]*10,drops[i].trail[j][2]*10,10,10)
				end
			end
		end
	end)
end

function newDrop()
	local drop = {}
	drop.x = love.math.random(0,screenWidth/10)
	drop.y = love.math.random(0,0)
	drop.colorR = 0
	drop.colorG = 0
	drop.colorB = 0
	while (drop.colorR + drop.colorB + drop.colorG < 1.8) and (drop.colorR < 1 and drop.colorB < 1 and drop.colorG < 1) or (drop.colorR + drop.colorB + drop.colorG > 2.2) do
		drop.colorR = 0--love.math.random(0,10)/10
		drop.colorG = love.math.random(30,40)/100
		drop.colorB = 1--love.math.random(0,10)/10
	end
	drop.dir = 2
	drop.trail = {}
	drop.trailMax = 20
	drop.lifetime = love.math.random(80,100)
	drops[1+#drops] = drop
end

function moveDrops()
	for i = 1, #drops do

		print('=== Determining Drop condition ===')
		print('Dead Drops: ', deadDrops)
		print('Drop lifetime is: ', drops[i].lifetime)
		print('Drop trail size is: ',#drops[i].trail)
		print('Drop trailMax is: ', drops[i].trailMax)

		if drops[i].lifetime > 0 then
			--move droplets here
			if drops[i].dir == 2 then
				print('Drop is going downwards...')
				local status, err = pcall(function () moveDropDownwards(i) end)
				--print('ERROR: Moving drop downwards - ', err)
			elseif drops[i].dir == 1 then
				print('Drop is going left...')
				local status, err = pcall(function () moveDropLeft(i) end)
				--print('ERROR: Moving drop left - ', err)
			elseif drops[i].dir == 3 then
				print('Drop is going right...')
				local status, err = pcall(function () moveDropRight(i) end)
				--print('ERROR: Moving drop right - ', err)
			end
			
			-- What do
			table.insert(drops[i].trail,1,{drops[i].x,drops[i].y})
			-- Remove trail 
			while #drops[i].trail > drops[i].trailMax do
				print('Drop trail is bigger than trailMax! Removing trail from Drop, trail is: ',#drops[i].trail)
				table.remove(drops[i].trail,#drops[i].trail)
		    end
			decreaseDropLifetime(i)

		end
		decreaseDropTrailMaxIfDying(i)
		checkIfDropIsDead(i)
		removeDeadDrop(i)
	end
end


function moveDropDownwards(i)
--down
	if drops[i].y+1 < screenHeight/10 then
		if map[drops[i].x][drops[i].y+1] < 1 then
			drops[i].y = drops[i].y + 1
		else
			if love.math.random(1,2) == 1 then
				drops[i].dir = 1
			else
				drops[i].dir = 3
			end
		end
	else
		drops[i].lifetime = 0
	end
end

function moveDropLeft(i)
--left
	if drops[i].x-1 > 0 then
    	if map[drops[i].x - 1][drops[i].y] < 1 then
      		drops[i].x = drops[i].x - 1
	    	if map[drops[i].x][drops[i].y + 1] < 1 then
		 	   drops[i].dir = 2
        	end
    	else
  			if map[drops[i].x][drops[i].y + 1] == 1 then
			   drops[i].dir = 3
			end
		end
	else
		drops[i].lifetime = 0
	end
end

function moveDropRight(i)
--right
	if drops[i].x+1 < screenWidth/10 then
		if map[drops[i].x + 1][drops[i].y] < 1 then
			drops[i].x = drops[i].x + 1
			if map[drops[i].x][drops[i].y + 1] < 1 then
				drops[i].dir = 2
			end
		else
			if map[drops[i].x][drops[i].y + 1] == 1 then
				drops[i].dir = 1
			end
		end
	else
		drops[i].lifetime = 0
	end
end

function decreaseDropLifetime(i)
	drops[i].lifetime = drops[i].lifetime - 1
end

function decreaseDropTrailMaxIfDying(i)

	if drops[i].lifetime <= 0 then
		if #drops[i].trail > 0 then
			drops[i].trailMax = drops[i].trailMax-1
		end
		checkIfDropIsDead(i)
	end
	--if drops[i].lifetime = 0 then
	--	if #drops[i].trail > 0 then
	--		print('Drop lifetime is 0 or below, decreasing trailMax')
	--		drops[i].trailMax = drops[i].trailMax-1
	--	end
	--end
end

function checkIfDropIsDead(i)
	if #drops[i].trail == 0 then
		print('Drop died X_X')
		deadDrops = deadDrops + 1
	end
end

function removeDeadDrop(i)
	print('Checking if drop is dead... ')
	while deadDrops > 0 do
		print(deadDrops, 'Dead drops detected...')
		for i = 1,#drops do
			print('Acting on dead drop #: ', i)
			if drops[i].lifetime <= 0 then
				table.remove(drops, i)
				deadDrops = deadDrops - 1
				print('Successfully removed dead drop #: ', i)
				break
			end
		end
	end
end