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
	dropNum = 10
	tick = 0
	spawnTick = 100
	spawnTickCounter = 0
	moveTick = 5
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
	removeDeadDrops()
end

Drop = {}
function Drop:new()
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

	-- Setup "class-object" as this.
	-- self is "Drop" here. Lowercase "drop" is the new object.
	setmetatable(drop, self)
	self.__index = self

	return drop
end

function Drop:move()
	if self.lifetime > 0 then
		--move droplets here
		if self.dir == 2 then
			print('Drop is going downwards...')
			self:moveDropDownwards()
		elseif self.dir == 1 then
			print('Drop is going left...')
			self:moveDropLeft()
		elseif self.dir == 3 then
			print('Drop is going right...')
			self:moveDropRight()
		end
		
		-- What do
		table.insert(self.trail,1,{self.x,self.y})
		-- Remove trail 
		self:decreaseLifetime()
	end
	self:decreaseDropTrailMaxIfDying()
	self:reduceTrailThatExceedsTrailMax()
	self:checkIfDropIsDead()
end

function Drop:moveDropDownwards()
--down
	if self.y+1 < screenHeight/10 then
		if map[self.x][self.y+1] < 1 then
			self.y = self.y + 1
		else
			if love.math.random(1,2) == 1 then
				self.dir = 1
			else
				self.dir = 3
			end
		end
	else
		self.lifetime = 0
	end
end

function Drop:moveDropLeft()
--left
	if self.x-1 > 0 then
		if map[self.x - 1][self.y] < 1 then
			self.x = self.x - 1
			if map[self.x][self.y + 1] < 1 then
			   self.dir = 2
			end
		else
			if map[self.x][self.y + 1] == 1 then
			   self.dir = 3
			end
		end
	else
		self.lifetime = 0
	end
end

function Drop:moveDropRight()
--right
	if self.x+1 < screenWidth/10 then
		if map[self.x + 1][self.y] < 1 then
			self.x = self.x + 1
			if map[self.x][self.y + 1] < 1 then
				self.dir = 2
			end
		else
			if map[self.x][self.y + 1] == 1 then
				self.dir = 1
			end
		end
	else
		self.lifetime = 0
	end
end

function Drop:decreaseLifetime()
	self.lifetime = self.lifetime - 1
end

function Drop:decreaseDropTrailMaxIfDying()
	if self.lifetime <= 0 then
		if #self.trail > 0 then
			self.trailMax = self.trailMax-1
		end
		self:checkIfDropIsDead(i)
	end
end

function Drop:reduceTrailThatExceedsTrailMax()
	while #self.trail > self.trailMax do
		print('Drop trail is bigger than trailMax! Removing trail from Drop, trail is: ',#self.trail)
		table.remove(self.trail,#self.trail)
	end
end

function Drop:checkIfDropIsDead()
	return #self.trail == 0 and self.lifetime <= 0
end

function moveDropAfterNumberOfTicks(i)
	if tick >= i then
		moveDrops()
		tick = 0
	end
	tick = tick + 1
end

function spawnDropAfterNumberOfTicks(i)
	if spawnTickCounter >= i then
		if #drops < dropNum then
			newDrop()
		end
		spawnTickCounter = 0
	end
	spawnTickCounter = spawnTickCounter + 1
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
	local drop = Drop:new()
	drops[1+#drops] = drop
end

function moveDrops()
	for i = 1, #drops do
		--print('=== Determining Drop condition ===')
		--print('Dead Drops: ', deadDrops)
		--print('Drop lifetime is: ', drops[i].lifetime)
		--print('Drop trail size is: ',#drops[i].trail)
		--print('Drop trailMax is: ', drops[i].trailMax)
		drops[i]:move()
	end
end


function reduceTrailThatExceedsTrailMax(i)
	while #drops[i].trail > drops[i].trailMax do
		print('Drop trail is bigger than trailMax! Removing trail from Drop, trail is: ',#drops[i].trail)
		table.remove(drops[i].trail,#drops[i].trail)
	end
end

function removeDeadDrops()
	-- Rather than worry about moving indices. Simply
	-- keep the alive ones
	local nextDrops = {}
	for i=1,#drops do
		if drops[i]:checkIfDropIsDead() then
			deadDrops = deadDrops + 1
			print('Successfully removed dead drop #: ', i)
		else
			table.insert(nextDrops, drops[i])
		end
	end
	drops = nextDrops
end
