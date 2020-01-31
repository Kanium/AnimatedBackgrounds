function love.load()
	love.window.setTitle("Koffee and Kanium")
	love.window.setMode(1280, 720, {resizable=true, vsync=false, minwidth=400, minheight=300})
	love.graphics.setBackgroundColor( 135/255, 65/255, 22/255, 1 )
	logo = love.graphics.newImage("koffee_and_Kanium.png")
	screenWidth = 1280
	screenHeight = 720
	scale = 1
	--Particle System
	local bubble = love.graphics.newImage('coffeebubble.png')
 
	psystem = love.graphics.newParticleSystem(bubble, 200)
	psystem:setEmissionArea('uniform', screenWidth/2, 0 ,0, false)
	--psystem:setEmissionArea('borderrectangle', (screenWidth-10)/2, (screenHeight-10)/2 ,0, false)
	
	psystem:setParticleLifetime(8, 15) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(0.8)
	--psystem:setEmissionRate(20)
	psystem:setSizeVariation(1)
	psystem:setSizes(0.5*scale,scale)
	psystem:setLinearAcceleration(-3, -7, 3, -7) -- Random movement in all directions.
	--psystem:setLinearAcceleration(-1, -1, 1, 1)
	
	psystem:setColors(1,1,1,0, 1,1,1,1, 1,1,1,1, 1,1,1,0) -- Fade to transparency.
	
	--Particle System
	local mist = love.graphics.newImage('mist_streak.png')
 
	mistsystem = love.graphics.newParticleSystem(mist, 100)
	mistsystem:setEmissionArea('uniform', 20*scale, 5*scale ,0, false)
	mistsystem:setParticleLifetime(6, 7) -- Particles live at least 2s and at most 5s.
	mistsystem:setEmissionRate(0.4)
	mistsystem:setSizeVariation(1)
	mistsystem:setSizes(0.1,1,2)
	mistsystem:setLinearAcceleration(-0.5, -2, 0.5, -3) -- Random movement in all directions.
	mistsystem:setColors(1,1,1,0, 1, 1, 1, 0, 1, 1, 1, 0.6, 1, 1, 1, 0) -- Fade to transparency.
	
	--Particle System
	local godray = love.graphics.newImage('godray.png')
 
	gsystem = love.graphics.newParticleSystem(godray, 30)
	gsystem:setEmissionArea('uniform', screenWidth, 0 ,0, false)
	gsystem:setParticleLifetime(6, 7) -- Particles live at least 2s and at most 5s.
	gsystem:setEmissionRate(2)
	gsystem:setSizeVariation(1)
	gsystem:setSizes(1)
	gsystem:setLinearAcceleration(-1, 0, 1, 0) -- Random movement in all directions.
	gsystem:setColors(0,0,0,0, 1, 1, 1, 0.1, 1, 1, 1, 0) -- Fade to transparency.
end

function love.update(dt)
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	scale = screenHeight/720
	psystem:setEmissionArea('uniform', screenWidth/2, 0 ,0, false)
	--psystem:setEmissionArea('borderrectangle', (screenWidth-10)/2, (screenHeight-10)/2 ,0, false)
	
	psystem:setSizes(0.5*scale,scale)
	psystem:update(dt)
	gsystem:setEmissionArea('uniform', screenWidth/2, 0 ,0, false)
	gsystem:setSizes(scale)
	gsystem:update(dt)
	mistsystem:setEmissionArea('uniform', 20*scale, 0 ,0, false)
	mistsystem:setSizes(scale*1.2)
	mistsystem:update(dt)
end

function love.draw()
	love.graphics.draw(gsystem, love.graphics.getWidth() * 0.6, love.graphics.getHeight() * 0.5)
	love.graphics.draw(psystem, love.graphics.getWidth() * 0.6, love.graphics.getHeight())
	love.graphics.draw(logo,screenWidth/2 - (600*scale),screenHeight/2 -(201*scale),0,scale,scale )
	love.graphics.draw(mistsystem, screenWidth/2 +10*scale, screenHeight/2 -(125*scale))
end

