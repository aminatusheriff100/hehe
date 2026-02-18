

if debugX then
	warn('Initialising VeloxLabs')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url) -- game:HttpGet(url)
		-- If the request fails the content can be empty, even if fetchSuccess is true
		if not fetchSuccess or #fetchResult == 0 then
			if #fetchResult == 0 then
				fetchResult = "Empty response" -- Set the error message
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult -- Fetched content
		local execSuccess, execResult = pcall(function()
			return loadstring(content)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn(`Request for {url} timed out after {timeout} seconds`)
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	-- Wait for completion or timeout
	while not requestCompleted do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn(`Failed to process {url}: {result}`)
	end
	return if success then result else nil
end

local requestsDisabled = true --getgenv and getgenv().DISABLE_NIGHTUI_REQUESTS
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local NightUIFolder = "NightUI"
local ConfigurationFolder = NightUIFolder.."/Configurations"
local ConfigurationExtension = ".ngui"
local settingsTable = {
	General = {
		-- if needs be in order just make getSetting(name)
		nightuiOpen = {Type = 'bind', Value = 'K', Name = 'VeloxLabs Keybind'},
		-- buildwarnings
		-- nightuiprompts

	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file, and are cleared if the user changes the setting in the UI
local overriddenSettings: { [string]: any } = {} -- For example, overriddenSettings["System.nightuiOpen"] = "J"
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[`{category}.{name}`] ~= nil then
		return overriddenSettings[`{category}.{name}`]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')
local TweenService = getService('TweenService')

-- Environment Check
local useStudio = RunService:IsStudio() or false
local AnimationLib = {}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
AnimationLib.Presets = {
	HoverIn = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	HoverOut = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Press = TweenInfo.new(0.08, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Release = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
	ToggleSlide = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
	ToggleColor = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	DropdownExpand = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	DropdownCollapse = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
	DropdownFade = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	DropdownOption = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TabSlide = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TabHighlight = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	TabContent = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	PanelOpen = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	PanelClose = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
	ThemeChange = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
	Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	NotifyIn = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
	NotifyOut = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
	SliderDrag = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	SliderSnap = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
}
AnimationLib.Scale = {
	Normal = 1,
	HoverEnlarge = 1.015,  -- Subtle
	PressShrink = 0.985,   -- Subtle
	PopIn = 1.03,
	Bounce = 1.05,
}

-- Stagger delays for lists
AnimationLib.Stagger = {
	Fast = 0.02,
	Normal = 0.035,
	Slow = 0.05,
}

-- Elastic bounce animation
function AnimationLib.ElasticBounce(element, intensity)
	if not element then return end
	intensity = intensity or 1.15
	
	local originalSize = element.Size
	TweenService:Create(element, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(originalSize.X.Scale * intensity, originalSize.X.Offset, originalSize.Y.Scale * intensity, originalSize.Y.Offset)
	}):Play()
	
	task.delay(0.15, function()
		TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
	end)
end

-- Glow pulse effect
function AnimationLib.GlowPulse(element, glowColor, duration)
	if not element then return end
	duration = duration or 0.5
	glowColor = glowColor or Color3.fromRGB(140, 100, 255)
	
	local stroke = element:FindFirstChild("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Parent = element
	end
	
	local originalColor = stroke.Color
	local originalTransparency = stroke.Transparency
	
	TweenService:Create(stroke, TweenInfo.new(duration / 2, Enum.EasingStyle.Sine), {
		Color = glowColor,
		Transparency = 0,
		Thickness = 3
	}):Play()
	
	task.delay(duration / 2, function()
		TweenService:Create(stroke, TweenInfo.new(duration / 2, Enum.EasingStyle.Sine), {
			Color = originalColor,
			Transparency = originalTransparency,
			Thickness = 2
		}):Play()
	end)
end

-- Shake effect for errors/attention
function AnimationLib.Shake(element, intensity, duration)
	if not element then return end
	intensity = intensity or 5
	duration = duration or 0.3
	
	local originalPos = element.Position
	local shakeCount = 6
	local shakeTime = duration / shakeCount
	
	for i = 1, shakeCount do
		local offset = (i % 2 == 0) and intensity or -intensity
		offset = offset * (1 - i / shakeCount)  -- Dampen over time
		
		task.delay(shakeTime * (i - 1), function()
			TweenService:Create(element, TweenInfo.new(shakeTime, Enum.EasingStyle.Sine), {
				Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offset, originalPos.Y.Scale, originalPos.Y.Offset)
			}):Play()
		end)
	end
	
	task.delay(duration, function()
		TweenService:Create(element, TweenInfo.new(0.1), {Position = originalPos}):Play()
	end)
end

-- Fade in with scale
function AnimationLib.FadeScaleIn(element, delay)
	if not element then return end
	delay = delay or 0
	
	local originalSize = element.Size
	element.Size = UDim2.new(originalSize.X.Scale * 0.8, originalSize.X.Offset * 0.8, originalSize.Y.Scale * 0.8, originalSize.Y.Offset * 0.8)
	element.BackgroundTransparency = 1
	
	task.delay(delay, function()
		TweenService:Create(element, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize,
			BackgroundTransparency = 0
		}):Play()
	end)
end

-- Rotate spin effect
function AnimationLib.SpinIn(element, delay)
	if not element then return end
	delay = delay or 0
	
	element.Rotation = -180
	element.BackgroundTransparency = 1
	
	task.delay(delay, function()
		TweenService:Create(element, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Rotation = 0,
			BackgroundTransparency = 0
		}):Play()
	end)
end

-- Typewriter text effect
function AnimationLib.TypewriterText(textLabel, text, speed)
	if not textLabel then return end
	speed = speed or 0.03
	
	textLabel.Text = ""
	for i = 1, #text do
		task.delay(speed * i, function()
			textLabel.Text = string.sub(text, 1, i)
		end)
	end
end

-- Rainbow color cycle
function AnimationLib.RainbowCycle(element, property, duration)
	if not element then return end
	duration = duration or 3
	property = property or "BackgroundColor3"
	
	local colors = {
		Color3.fromRGB(255, 100, 100),
		Color3.fromRGB(255, 200, 100),
		Color3.fromRGB(100, 255, 100),
		Color3.fromRGB(100, 200, 255),
		Color3.fromRGB(200, 100, 255),
	}
	
	local colorTime = duration / #colors
	for i, color in ipairs(colors) do
		task.delay(colorTime * (i - 1), function()
			TweenService:Create(element, TweenInfo.new(colorTime, Enum.EasingStyle.Sine), {
				[property] = color
			}):Play()
		end)
	end
end

-- Apply hover effect to a button/frame
function AnimationLib.ApplyHoverEffect(element, hoverColor, normalColor)
	if not element then return end
	
	local originalSize = element.Size
	local isHovering = false
	
	element.MouseEnter:Connect(function()
		isHovering = true
		TweenService:Create(element, AnimationLib.Presets.HoverIn, {
			BackgroundColor3 = hoverColor or element.BackgroundColor3,
			Size = UDim2.new(
				originalSize.X.Scale * AnimationLib.Scale.HoverEnlarge,
				originalSize.X.Offset,
				originalSize.Y.Scale * AnimationLib.Scale.HoverEnlarge,
				originalSize.Y.Offset
			)
		}):Play()
	end)
	
	element.MouseLeave:Connect(function()
		isHovering = false
		TweenService:Create(element, AnimationLib.Presets.HoverOut, {
			BackgroundColor3 = normalColor or element.BackgroundColor3,
			Size = originalSize
		}):Play()
	end)
	
	return element
end
function AnimationLib.ApplyPressEffect(element)
	if not element or not element:FindFirstChild("Interact") then return end
	
	local interact = element.Interact
	local originalSize = element.Size
	
	interact.MouseButton1Down:Connect(function()
		TweenService:Create(element, AnimationLib.Presets.Press, {
			Size = UDim2.new(
				originalSize.X.Scale * AnimationLib.Scale.PressShrink,
				originalSize.X.Offset,
				originalSize.Y.Scale,
				originalSize.Y.Offset * AnimationLib.Scale.PressShrink
			)
		}):Play()
	end)
	
	interact.MouseButton1Up:Connect(function()
		TweenService:Create(element, AnimationLib.Presets.Release, {
			Size = originalSize
		}):Play()
	end)
	
	return element
end

-- Animate element entrance with pop effect
function AnimationLib.PopIn(element, delay)
	if not element then return end
	delay = delay or 0
	
	local originalSize = element.Size
	element.Size = UDim2.new(0, 0, 0, 0)
	element.BackgroundTransparency = 1
	
	task.delay(delay, function()
		TweenService:Create(element, AnimationLib.Presets.PanelOpen, {
			Size = originalSize,
			BackgroundTransparency = 0
		}):Play()
	end)
end

-- Animate element entrance with slide effect
function AnimationLib.SlideIn(element, direction, delay)
	if not element then return end
	delay = delay or 0
	direction = direction or "left"
	
	local originalPos = element.Position
	local startPos
	
	if direction == "left" then
		startPos = UDim2.new(originalPos.X.Scale - 0.1, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
	elseif direction == "right" then
		startPos = UDim2.new(originalPos.X.Scale + 0.1, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
	elseif direction == "up" then
		startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale - 0.1, originalPos.Y.Offset)
	else
		startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale + 0.1, originalPos.Y.Offset)
	end
	
	element.Position = startPos
	element.BackgroundTransparency = 1
	
	task.delay(delay, function()
		TweenService:Create(element, AnimationLib.Presets.Spring, {
			Position = originalPos,
			BackgroundTransparency = 0
		}):Play()
	end)
end

-- Ripple effect for buttons (optional, modern touch)
function AnimationLib.CreateRipple(element, position)
	if not element then return end
	
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.BackgroundColor3 = Color3.new(1, 1, 1)
	ripple.BackgroundTransparency = 0.7
	ripple.BorderSizePixel = 0
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Position = UDim2.new(0, position.X - element.AbsolutePosition.X, 0, position.Y - element.AbsolutePosition.Y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.ZIndex = element.ZIndex + 1
	ripple.Parent = element
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple
	
	local maxSize = math.max(element.AbsoluteSize.X, element.AbsoluteSize.Y) * 2
	
	TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1
	}):Play()
	
	task.delay(0.4, function()
		ripple:Destroy()
	end)
end

-- ðŸ”¥ ANIMATED BACKGROUND EFFECTS ðŸ”¥

-- Create floating particles background
function AnimationLib.CreateParticleBackground(parent, color, count)
	if not parent then return end
	count = count or 15
	color = color or Color3.fromRGB(100, 80, 200)
	
	local particleContainer = Instance.new("Frame")
	particleContainer.Name = "ParticleBackground"
	particleContainer.Size = UDim2.new(1, 0, 1, 0)
	particleContainer.BackgroundTransparency = 1
	particleContainer.ClipsDescendants = true
	particleContainer.ZIndex = 0
	particleContainer.Parent = parent
	
	for i = 1, count do
		local particle = Instance.new("Frame")
		particle.Name = "Particle"..i
		particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
		particle.Position = UDim2.new(math.random() * 0.9, 0, math.random() * 0.9, 0)
		particle.BackgroundColor3 = color
		particle.BackgroundTransparency = math.random(70, 90) / 100
		particle.BorderSizePixel = 0
		particle.ZIndex = 0
		particle.Parent = particleContainer
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = particle
		
		-- Animate each particle
		task.spawn(function()
			while particle.Parent do
				local targetX = math.random() * 0.9
				local targetY = math.random() * 0.9
				local duration = math.random(8, 15)
				
				TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.new(targetX, 0, targetY, 0),
					BackgroundTransparency = math.random(60, 90) / 100
				}):Play()
				
				task.wait(duration)
			end
		end)
	end
	
	return particleContainer
end

-- Create gradient wave background
function AnimationLib.CreateWaveBackground(parent, color1, color2)
	if not parent then return end
	color1 = color1 or Color3.fromRGB(20, 15, 40)
	color2 = color2 or Color3.fromRGB(40, 30, 80)
	
	local waveFrame = Instance.new("Frame")
	waveFrame.Name = "WaveBackground"
	waveFrame.Size = UDim2.new(1, 0, 1, 0)
	waveFrame.BackgroundColor3 = color1
	waveFrame.BorderSizePixel = 0
	waveFrame.ZIndex = 0
	waveFrame.Parent = parent
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(0.5, color2),
		ColorSequenceKeypoint.new(1, color1)
	})
	gradient.Rotation = 45
	gradient.Parent = waveFrame
	
	-- Animate gradient rotation
	task.spawn(function()
		while waveFrame.Parent do
			TweenService:Create(gradient, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Rotation = 135
			}):Play()
			task.wait(8)
			TweenService:Create(gradient, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Rotation = 45
			}):Play()
			task.wait(8)
		end
	end)
	
	return waveFrame
end

-- Create pulsing glow effect
function AnimationLib.CreatePulseGlow(element, color, intensity)
	if not element then return end
	color = color or Color3.fromRGB(140, 100, 255)
	intensity = intensity or 0.3
	
	local glow = Instance.new("Frame")
	glow.Name = "PulseGlow"
	glow.Size = UDim2.new(1, 20, 1, 20)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundColor3 = color
	glow.BackgroundTransparency = 0.9
	glow.BorderSizePixel = 0
	glow.ZIndex = element.ZIndex - 1
	glow.Parent = element.Parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = glow
	
	-- Pulse animation
	task.spawn(function()
		while glow.Parent do
			TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1, 30, 1, 30),
				BackgroundTransparency = 0.95
			}):Play()
			task.wait(1.5)
			TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1, 20, 1, 20),
				BackgroundTransparency = 0.85
			}):Play()
			task.wait(1.5)
		end
	end)
	
	return glow
end

-- Create shimmer/shine effect across element
function AnimationLib.CreateShimmer(element)
	if not element then return end
	
	local shimmer = Instance.new("Frame")
	shimmer.Name = "Shimmer"
	shimmer.Size = UDim2.new(0.3, 0, 1, 0)
	shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
	shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
	shimmer.BackgroundTransparency = 0.9
	shimmer.BorderSizePixel = 0
	shimmer.ZIndex = element.ZIndex + 1
	shimmer.Parent = element
	
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	gradient.Rotation = 15
	gradient.Parent = shimmer
	
	-- Shimmer animation loop
	task.spawn(function()
		while shimmer.Parent do
			shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
			TweenService:Create(shimmer, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(1, 0, 0, 0)
			}):Play()
			task.wait(5)
		end
	end)
	
	return shimmer
end

-- Staggered entrance animation for multiple elements
function AnimationLib.StaggeredEntrance(elements, direction, baseDelay)
	direction = direction or "up"
	baseDelay = baseDelay or 0.05
	
	for i, element in ipairs(elements) do
		if element and element:IsA("GuiObject") then
			local originalPos = element.Position
			local originalTransparency = element.BackgroundTransparency
			
			-- Set initial state
			element.BackgroundTransparency = 1
			if direction == "up" then
				element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale + 0.05, originalPos.Y.Offset)
			elseif direction == "down" then
				element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale - 0.05, originalPos.Y.Offset)
			elseif direction == "left" then
				element.Position = UDim2.new(originalPos.X.Scale + 0.05, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
			else
				element.Position = UDim2.new(originalPos.X.Scale - 0.05, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
			end
			
			-- Animate with stagger
			task.delay(i * baseDelay, function()
				TweenService:Create(element, AnimationLib.Presets.Spring, {
					Position = originalPos,
					BackgroundTransparency = originalTransparency
				}):Play()
			end)
		end
	end
end

-- Scale bounce animation
function AnimationLib.ScaleBounce(element, scale)
	if not element then return end
	scale = scale or 1.1
	
	local originalSize = element.Size
	
	TweenService:Create(element, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(
			originalSize.X.Scale * scale, 
			originalSize.X.Offset, 
			originalSize.Y.Scale * scale, 
			originalSize.Y.Offset
		)
	}):Play()
	
	task.delay(0.15, function()
		TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
	end)
end

-- Shake animation for errors/attention
function AnimationLib.Shake(element, intensity)
	if not element then return end
	intensity = intensity or 5
	
	local originalPos = element.Position
	
	for i = 1, 4 do
		local offset = (i % 2 == 0) and intensity or -intensity
		TweenService:Create(element, TweenInfo.new(0.05), {
			Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offset, originalPos.Y.Scale, originalPos.Y.Offset)
		}):Play()
		task.wait(0.05)
	end
	
	TweenService:Create(element, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
		Position = originalPos
	}):Play()
end

-- Typewriter text animation
function AnimationLib.TypewriterText(textLabel, text, speed)
	if not textLabel then return end
	speed = speed or 0.03
	
	textLabel.Text = ""
	for i = 1, #text do
		textLabel.Text = string.sub(text, 1, i)
		task.wait(speed)
	end
end

-- Color pulse animation
function AnimationLib.ColorPulse(element, pulseColor, duration)
	if not element then return end
	duration = duration or 0.5
	
	local originalColor = element.BackgroundColor3
	
	TweenService:Create(element, TweenInfo.new(duration / 2, Enum.EasingStyle.Quad), {
		BackgroundColor3 = pulseColor
	}):Play()
	
	task.delay(duration / 2, function()
		TweenService:Create(element, TweenInfo.new(duration / 2, Enum.EasingStyle.Quad), {
			BackgroundColor3 = originalColor
		}):Play()
	end)
end

-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local ExecutorScanner = {}

-- Executor detection
function ExecutorScanner.GetExecutorName()
	local name = "Unknown"
	pcall(function()
		if getexecutorname then
			name = getexecutorname()
		elseif identifyexecutor then
			name = identifyexecutor()
		elseif KRNL_LOADED then
			name = "KRNL"
		elseif syn and syn.protect_gui then
			name = "Synapse X"
		elseif fluxus then
			name = "Fluxus"
		elseif SENTINEL_V2 then
			name = "Sentinel"
		elseif Solara then
			name = "Solara"
		elseif getgenv().Hydrogen then
			name = "Hydrogen"
		elseif getgenv().Delta then
			name = "Delta"
		end
	end)
	return name
end

-- API availability checks (safe - only checks existence, doesn't call)
ExecutorScanner.APIs = {
	-- Core APIs
	{ name = "getgenv", check = function() return getgenv ~= nil end, category = "Core", weight = 10 },
	{ name = "getrenv", check = function() return getrenv ~= nil end, category = "Core", weight = 8 },
	{ name = "getrawmetatable", check = function() return getrawmetatable ~= nil end, category = "Core", weight = 9 },
	{ name = "setrawmetatable", check = function() return setrawmetatable ~= nil end, category = "Core", weight = 8 },
	{ name = "hookmetamethod", check = function() return hookmetamethod ~= nil end, category = "Core", weight = 7 },
	{ name = "hookfunction", check = function() return hookfunction ~= nil or replaceclosure ~= nil end, category = "Core", weight = 8 },
	
	-- UI Protection
	{ name = "protect_gui", check = function() return (syn and syn.protect_gui) or protect_gui ~= nil end, category = "UI", weight = 10 },
	{ name = "gethui", check = function() return gethui ~= nil end, category = "UI", weight = 9 },
	{ name = "iswindowactive", check = function() return iswindowactive ~= nil end, category = "UI", weight = 5 },
	
	-- File System
	{ name = "readfile", check = function() return readfile ~= nil end, category = "FileSystem", weight = 10 },
	{ name = "writefile", check = function() return writefile ~= nil end, category = "FileSystem", weight = 10 },
	{ name = "isfile", check = function() return isfile ~= nil end, category = "FileSystem", weight = 8 },
	{ name = "isfolder", check = function() return isfolder ~= nil end, category = "FileSystem", weight = 8 },
	{ name = "makefolder", check = function() return makefolder ~= nil end, category = "FileSystem", weight = 7 },
	{ name = "delfile", check = function() return delfile ~= nil end, category = "FileSystem", weight = 6 },
	{ name = "listfiles", check = function() return listfiles ~= nil end, category = "FileSystem", weight = 7 },
	
	-- HTTP
	{ name = "request", check = function() return request ~= nil or http_request ~= nil or (syn and syn.request) or (http and http.request) end, category = "HTTP", weight = 10 },
	{ name = "httpget", check = function() return game.HttpGet ~= nil or httpget ~= nil end, category = "HTTP", weight = 8 },
	{ name = "httppost", check = function() return httppost ~= nil end, category = "HTTP", weight = 6 },
	
	-- Script/Instance
	{ name = "getconnections", check = function() return getconnections ~= nil end, category = "Script", weight = 9 },
	{ name = "firesignal", check = function() return firesignal ~= nil or fireclick ~= nil end, category = "Script", weight = 8 },
	{ name = "fireclickdetector", check = function() return fireclickdetector ~= nil end, category = "Script", weight = 6 },
	{ name = "fireproximityprompt", check = function() return fireproximityprompt ~= nil end, category = "Script", weight = 6 },
	{ name = "getsenv", check = function() return getsenv ~= nil end, category = "Script", weight = 7 },
	{ name = "getscripts", check = function() return getscripts ~= nil end, category = "Script", weight = 6 },
	{ name = "getrunningscripts", check = function() return getrunningscripts ~= nil end, category = "Script", weight = 6 },
	
	-- Drawing
	{ name = "Drawing", check = function() return Drawing ~= nil and Drawing.new ~= nil end, category = "Drawing", weight = 8 },
	{ name = "cleardrawcache", check = function() return cleardrawcache ~= nil end, category = "Drawing", weight = 4 },
	
	-- Clipboard
	{ name = "setclipboard", check = function() return setclipboard ~= nil or toclipboard ~= nil end, category = "Misc", weight = 7 },
	
	-- Debug
	{ name = "debug.getinfo", check = function() return debug and debug.getinfo ~= nil end, category = "Debug", weight = 6 },
	{ name = "debug.getupvalue", check = function() return debug and debug.getupvalue ~= nil end, category = "Debug", weight = 7 },
	{ name = "debug.setupvalue", check = function() return debug and debug.setupvalue ~= nil end, category = "Debug", weight = 7 },
	{ name = "debug.getconstants", check = function() return debug and debug.getconstants ~= nil end, category = "Debug", weight = 6 },
	
	-- Crypto
	{ name = "crypt.encrypt", check = function() return crypt and crypt.encrypt ~= nil end, category = "Crypto", weight = 8 },
	{ name = "crypt.decrypt", check = function() return crypt and crypt.decrypt ~= nil end, category = "Crypto", weight = 8 },
	{ name = "crypt.base64encode", check = function() return crypt and crypt.base64encode ~= nil end, category = "Crypto", weight = 5 },
}

-- Scan all APIs and return results
function ExecutorScanner.ScanAPIs()
	local results = {
		available = {},
		unavailable = {},
		categories = {},
		totalWeight = 0,
		maxWeight = 0
	}
	
	for _, api in ipairs(ExecutorScanner.APIs) do
		results.maxWeight = results.maxWeight + api.weight
		
		local success, available = pcall(api.check)
		if success and available then
			table.insert(results.available, api)
			results.totalWeight = results.totalWeight + api.weight
			
			if not results.categories[api.category] then
				results.categories[api.category] = { available = 0, total = 0 }
			end
			results.categories[api.category].available = results.categories[api.category].available + 1
			results.categories[api.category].total = results.categories[api.category].total + 1
		else
			table.insert(results.unavailable, api)
			
			if not results.categories[api.category] then
				results.categories[api.category] = { available = 0, total = 0 }
			end
			results.categories[api.category].total = results.categories[api.category].total + 1
		end
	end
	
	return results
end

-- Calculate compatibility score
function ExecutorScanner.CalculateScore(scanResults)
	-- Prevent division by zero
	if not scanResults.maxWeight or scanResults.maxWeight == 0 then
		return { percentage = 0, rating = "Unknown", color = Color3.fromRGB(150, 150, 150), availableCount = 0, totalCount = 0 }
	end
	local percentage = (scanResults.totalWeight / scanResults.maxWeight) * 100
	
	local rating, color
	if percentage >= 90 then
		rating = "Full Support"
		color = Color3.fromRGB(50, 200, 100)
	elseif percentage >= 70 then
		rating = "Partial Support"
		color = Color3.fromRGB(200, 180, 50)
	elseif percentage >= 50 then
		rating = "Limited Support"
		color = Color3.fromRGB(200, 130, 50)
	else
		rating = "Unsafe / Unstable"
		color = Color3.fromRGB(200, 60, 60)
	end
	
	return {
		percentage = math.floor(percentage),
		rating = rating,
		color = color,
		availableCount = #scanResults.available,
		totalCount = #scanResults.available + #scanResults.unavailable
	}
end

-- Feature probability based on available APIs
ExecutorScanner.FeatureRequirements = {
	Notifications = { apis = {"gethui", "protect_gui"}, fallback = 95 },
	Animations = { apis = {}, fallback = 100 },  -- Pure Roblox, always works
	EncryptedConfigs = { apis = {"crypt.encrypt", "crypt.decrypt", "readfile", "writefile"}, fallback = 60 },
	DragAndDrop = { apis = {"gethui"}, fallback = 90 },
	ContextMenus = { apis = {"getconnections", "firesignal"}, fallback = 70 },
	LocalizationSystem = { apis = {"readfile", "httpget"}, fallback = 80 },
	FileConfigs = { apis = {"readfile", "writefile", "isfile", "isfolder", "makefolder"}, fallback = 0 },
	HTTPRequests = { apis = {"request", "httpget"}, fallback = 50 },
	UIProtection = { apis = {"protect_gui", "gethui"}, fallback = 60 },
	ScriptHooking = { apis = {"hookfunction", "hookmetamethod", "getconnections"}, fallback = 30 },
	Drawing = { apis = {"Drawing"}, fallback = 0 },
	Clipboard = { apis = {"setclipboard"}, fallback = 0 },
}

function ExecutorScanner.CalculateFeatureProbabilities(scanResults)
	local probabilities = {}
	local availableNames = {}
	
	-- Safe check for available APIs
	if scanResults and scanResults.available then
		for _, api in ipairs(scanResults.available) do
			availableNames[api.name] = true
		end
	end
	
	for feature, requirements in pairs(ExecutorScanner.FeatureRequirements) do
		local requiredCount = #requirements.apis
		local availableCount = 0
		
		for _, apiName in ipairs(requirements.apis) do
			if availableNames[apiName] then
				availableCount = availableCount + 1
			end
		end
		
		local probability
		if requiredCount == 0 then
			probability = requirements.fallback
		elseif availableCount == requiredCount then
			probability = 100
		elseif availableCount > 0 then
			probability = math.floor((availableCount / requiredCount) * 80) + 10
		else
			probability = requirements.fallback
		end
		
		local color
		if probability >= 90 then
			color = Color3.fromRGB(50, 200, 100)
		elseif probability >= 70 then
			color = Color3.fromRGB(200, 180, 50)
		elseif probability >= 50 then
			color = Color3.fromRGB(200, 130, 50)
		else
			color = Color3.fromRGB(200, 60, 60)
		end
		
		probabilities[feature] = {
			percentage = probability,
			color = color,
			available = availableCount,
			required = requiredCount
		}
	end
	
	return probabilities
end

-- Full scan and report
function ExecutorScanner.FullScan()
	local success, result = pcall(function()
		local executorName = ExecutorScanner.GetExecutorName() or "Unknown"
		local scanResults = ExecutorScanner.ScanAPIs() or { available = {}, unavailable = {}, categories = {}, totalWeight = 0, maxWeight = 1 }
		local score = ExecutorScanner.CalculateScore(scanResults)
		local features = ExecutorScanner.CalculateFeatureProbabilities(scanResults)
		
		return {
			executor = executorName,
			score = score,
			apis = scanResults,
			features = features,
			categories = scanResults.categories or {}
		}
	end)
	
	if success and result then
		return result
	end
	
	-- Return safe default on error
	return {
		executor = "Unknown",
		score = { percentage = 0, rating = "Error", color = Color3.fromRGB(200, 60, 60), availableCount = 0, totalCount = 0 },
		apis = { available = {}, unavailable = {} },
		features = {},
		categories = {}
	}
end

-- Cache the scan result
local _cachedScan = nil
function ExecutorScanner.GetCachedScan()
	if not _cachedScan then
		local success, result = pcall(ExecutorScanner.FullScan)
		if success and result then
			_cachedScan = result
		else
			-- Return safe default
			_cachedScan = {
				executor = "Unknown",
				score = { percentage = 0, rating = "Error", color = Color3.fromRGB(200, 60, 60), availableCount = 0, totalCount = 0 },
				apis = { available = {}, unavailable = {} },
				features = {},
				categories = {}
			}
		end
	end
	return _cachedScan
end

print('[VeloxLabs] Executor Scanner loaded')

-- Create UI popup for scanner results
function ExecutorScanner.ShowResultsPopup(parent)
	local scan = ExecutorScanner.GetCachedScan()
	
	-- Create popup container
	local popup = Instance.new("Frame")
	popup.Name = "ExecutorScanPopup"
	popup.Size = UDim2.new(0, 400, 0, 500)
	popup.Position = UDim2.new(0.5, 0, 0.5, 0)
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.BackgroundColor3 = SelectedTheme and SelectedTheme.Background or Color3.fromRGB(25, 25, 25)
	popup.BorderSizePixel = 0
	popup.ZIndex = 100
	popup.Parent = parent
	popup.ClipsDescendants = true
	
	-- Start invisible for animation
	popup.BackgroundTransparency = 1
	popup.Size = UDim2.new(0, 350, 0, 400)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = popup
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = scan.score.color
	stroke.Thickness = 2
	stroke.Transparency = 1
	stroke.Parent = popup
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = scan.score.color
	header.BackgroundTransparency = 0.8
	header.BorderSizePixel = 0
	header.Parent = popup
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -20, 0, 25)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "âš¡ " .. scan.executor .. " Compatibility"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTransparency = 1
	title.Parent = header
	
	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Name = "Score"
	scoreLabel.Size = UDim2.new(1, -20, 0, 20)
	scoreLabel.Position = UDim2.new(0, 10, 0, 35)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Text = scan.score.rating .. " â€¢ " .. scan.score.percentage .. "% (" .. scan.score.availableCount .. "/" .. scan.score.totalCount .. " APIs)"
	scoreLabel.TextColor3 = scan.score.color
	scoreLabel.TextSize = 13
	scoreLabel.Font = Enum.Font.GothamMedium
	scoreLabel.TextXAlignment = Enum.TextXAlignment.Left
	scoreLabel.TextTransparency = 1
	scoreLabel.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundColor3 = SelectedTheme.ToggleDisabled or Color3.fromRGB(200, 60, 60)
	closeBtn.BackgroundTransparency = 0.5
	closeBtn.Text = "âœ•"
	closeBtn.TextColor3 = SelectedTheme.TextColor
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = header
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	-- Content scroll
	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -20, 1, -75)
	content.Position = UDim2.new(0, 10, 0, 65)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 4
	content.ScrollBarImageColor3 = scan.score.color
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.Parent = popup
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.Parent = content
	
	-- Section: Feature Probabilities
	local featuresTitle = Instance.new("TextLabel")
	featuresTitle.Name = "FeaturesTitle"
	featuresTitle.Size = UDim2.new(1, 0, 0, 25)
	featuresTitle.BackgroundTransparency = 1
	featuresTitle.Text = "ðŸ“Š Feature Compatibility"
	featuresTitle.TextColor3 = SelectedTheme.TextColor
	featuresTitle.TextSize = 14
	featuresTitle.Font = Enum.Font.GothamBold
	featuresTitle.TextXAlignment = Enum.TextXAlignment.Left
	featuresTitle.LayoutOrder = 1
	featuresTitle.Parent = content
	
	local layoutOrder = 2
	for feature, data in pairs(scan.features) do
		local featureFrame = Instance.new("Frame")
		featureFrame.Name = feature
		featureFrame.Size = UDim2.new(1, 0, 0, 28)
		featureFrame.BackgroundColor3 = SelectedTheme and SelectedTheme.ElementBackground or Color3.fromRGB(35, 35, 35)
		featureFrame.BackgroundTransparency = 0.5
		featureFrame.BorderSizePixel = 0
		featureFrame.LayoutOrder = layoutOrder
		featureFrame.Parent = content
		
		local featureCorner = Instance.new("UICorner")
		featureCorner.CornerRadius = UDim.new(0, 6)
		featureCorner.Parent = featureFrame
		
		local featureName = Instance.new("TextLabel")
		featureName.Size = UDim2.new(0.6, 0, 1, 0)
		featureName.Position = UDim2.new(0, 10, 0, 0)
		featureName.BackgroundTransparency = 1
		featureName.Text = feature:gsub("(%u)", " %1"):gsub("^%s", "")  -- CamelCase to spaces
		featureName.TextColor3 = Color3.new(1, 1, 1)
		featureName.TextSize = 12
		featureName.Font = Enum.Font.Gotham
		featureName.TextXAlignment = Enum.TextXAlignment.Left
		featureName.Parent = featureFrame
		
		local featurePercent = Instance.new("TextLabel")
		featurePercent.Size = UDim2.new(0.35, 0, 1, 0)
		featurePercent.Position = UDim2.new(0.65, 0, 0, 0)
		featurePercent.BackgroundTransparency = 1
		featurePercent.Text = data.percentage .. "% supported"
		featurePercent.TextColor3 = data.color
		featurePercent.TextSize = 12
		featurePercent.Font = Enum.Font.GothamMedium
		featurePercent.TextXAlignment = Enum.TextXAlignment.Right
		featurePercent.Parent = featureFrame
		
		-- Progress bar
		local progressBg = Instance.new("Frame")
		progressBg.Size = UDim2.new(1, -20, 0, 3)
		progressBg.Position = UDim2.new(0, 10, 1, -5)
		progressBg.BackgroundColor3 = SelectedTheme.SliderBackground or SelectedTheme.ElementStroke
		progressBg.BorderSizePixel = 0
		progressBg.Parent = featureFrame
		
		local progressFill = Instance.new("Frame")
		progressFill.Size = UDim2.new(data.percentage / 100, 0, 1, 0)
		progressFill.BackgroundColor3 = data.color
		progressFill.BorderSizePixel = 0
		progressFill.Parent = progressBg
		
		local progressCorner = Instance.new("UICorner")
		progressCorner.CornerRadius = UDim.new(1, 0)
		progressCorner.Parent = progressBg
		
		local progressFillCorner = Instance.new("UICorner")
		progressFillCorner.CornerRadius = UDim.new(1, 0)
		progressFillCorner.Parent = progressFill
		
		layoutOrder = layoutOrder + 1
	end
	
	-- Section: API Categories
	local categoriesTitle = Instance.new("TextLabel")
	categoriesTitle.Name = "CategoriesTitle"
	categoriesTitle.Size = UDim2.new(1, 0, 0, 25)
	categoriesTitle.BackgroundTransparency = 1
	categoriesTitle.Text = "ðŸ”§ API Categories"
	categoriesTitle.TextColor3 = SelectedTheme.TextColor
	categoriesTitle.TextSize = 14
	categoriesTitle.Font = Enum.Font.GothamBold
	categoriesTitle.TextXAlignment = Enum.TextXAlignment.Left
	categoriesTitle.LayoutOrder = layoutOrder
	categoriesTitle.Parent = content
	layoutOrder = layoutOrder + 1
	
	for category, data in pairs(scan.categories) do
		local catFrame = Instance.new("Frame")
		catFrame.Name = category
		catFrame.Size = UDim2.new(1, 0, 0, 0)
		catFrame.AutomaticSize = Enum.AutomaticSize.Y
		catFrame.BackgroundTransparency = 1
		catFrame.LayoutOrder = layoutOrder
		catFrame.Parent = content
		
		-- Add layout for proper text alignment
		local catLayout = Instance.new("UIListLayout")
		catLayout.FillDirection = Enum.FillDirection.Horizontal
		catLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
		catLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		catLayout.Parent = catFrame
		
		local catName = Instance.new("TextLabel")
		catName.Size = UDim2.new(0.5, 0, 0, 22)
		catName.BackgroundTransparency = 1
		catName.Text = "  â€¢ " .. category
		catName.TextColor3 = SelectedTheme.TabTextColor or SelectedTheme.TextColor
		catName.TextSize = 11
		catName.Font = Enum.Font.Gotham
		catName.TextXAlignment = Enum.TextXAlignment.Left
		catName.Parent = catFrame
		
		local catPercent = data.available / data.total * 100
		local catColor = catPercent >= 80 and Color3.fromRGB(50, 200, 100) or catPercent >= 50 and Color3.fromRGB(200, 180, 50) or Color3.fromRGB(200, 60, 60)
		
		local catValue = Instance.new("TextLabel")
		catValue.Size = UDim2.new(0.5, 0, 0, 22)
		catValue.BackgroundTransparency = 1
		catValue.Text = data.available .. "/" .. data.total .. " available"
		catValue.TextColor3 = catColor
		catValue.TextSize = 11
		catValue.Font = Enum.Font.Gotham
		catValue.TextXAlignment = Enum.TextXAlignment.Right
		catValue.Parent = catFrame
		
		layoutOrder = layoutOrder + 1
	end
	
	-- Animate in
	TweenService:Create(popup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.05,
		Size = UDim2.new(0, 400, 0, 500)
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
	TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	TweenService:Create(scoreLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	
	-- Close button functionality
	closeBtn.MouseButton1Click:Connect(function()
		TweenService:Create(popup, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 350, 0, 400)
		}):Play()
		task.delay(0.3, function()
			popup:Destroy()
		end)
	end)
	
	return popup
end

-- Expose to NightUILibrary
local function GetExecutorScan()
	return ExecutorScanner.GetCachedScan()
end

local settingsCreated = false
local settingsInitialized = false -- Whether the UI elements in the settings page have been set to the proper values
local cachedSettings
local prompt = nil
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

-- Validate prompt loaded correctly
if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt = {
		create = function() end -- No-op fallback
	}
end



local function loadSettings()
	local file = nil

	local success, result =	pcall(function()
		task.spawn(function()
			if isfolder and isfolder(NightUIFolder) then
				if isfile and isfile(NightUIFolder..'/settings'..ConfigurationExtension) then
					file = readfile(NightUIFolder..'/settings'..ConfigurationExtension)
				end
			end

			-- for debug in studio
			if useStudio then
				file = [[
		{"General":{"nightuiOpen":{"Value":"K","Type":"bind","Name":"NightUI Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"NightUI Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
	]]
			end


			if file then
				local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
				if success then
					file = decodedFile
				else
					file = {}
				end
			else
				file = {}
			end


			if not settingsCreated then 
				cachedSettings = file
				return
			end

			if file ~= {} then
				for categoryName, settingCategory in pairs(settingsTable) do
					if file[categoryName] then
						for settingName, setting in pairs(settingCategory) do
							if file[categoryName][settingName] then
								setting.Value = file[categoryName][settingName].Value
								setting.Element:Set(getSetting(categoryName, settingName))
							end
						end
					end
				end
			end
			settingsInitialized = true
		end)
	end)

	if not success then 
		if writefile then
			warn('VeloxLabs had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local promptUser = 2

if promptUser == 1 and prompt and type(prompt.create) == "function" then
	prompt.create(
		'Be cautious when running scripts',
	    [[Please be careful when running scripts from unknown developers. This script has already been ran.

<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
		'Okay',
		'',
		function()

		end
	)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local NightUILibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),
			-- BackgroundImage removed - using animated effects instead
			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178),
			
			-- Semantic colors
			ErrorColor = Color3.fromRGB(200, 60, 60),
			SuccessColor = Color3.fromRGB(60, 200, 100),
			WarningColor = Color3.fromRGB(220, 180, 60),
			InfoColor = Color3.fromRGB(80, 150, 220),
			AccentColor = Color3.fromRGB(140, 100, 255)
		},

		-- OceanClassic removed - duplicate of Ocean theme below

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			-- BackgroundImage removed - using animated effects
			SpinnerAsset = "rbxassetid://11963373994",
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130),
			
			-- Semantic colors
			ErrorColor = Color3.fromRGB(200, 60, 60),
			SuccessColor = Color3.fromRGB(60, 200, 100),
			WarningColor = Color3.fromRGB(220, 180, 60),
			InfoColor = Color3.fromRGB(80, 150, 220),
			AccentColor = Color3.fromRGB(240, 130, 30)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),
			-- BackgroundImage removed - using animated effects
			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200), 
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140),
			
			-- Semantic colors
			ErrorColor = Color3.fromRGB(200, 60, 60),
			SuccessColor = Color3.fromRGB(60, 180, 100),
			WarningColor = Color3.fromRGB(200, 160, 40),
			InfoColor = Color3.fromRGB(60, 130, 200),
			AccentColor = Color3.fromRGB(0, 146, 214)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			-- BackgroundImage removed
			SpinnerAsset = "rbxassetid://11963373994",
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200),
			
			-- Semantic colors
			ErrorColor = Color3.fromRGB(200, 60, 60),
			SuccessColor = Color3.fromRGB(60, 200, 100),
			WarningColor = Color3.fromRGB(220, 180, 60),
			InfoColor = Color3.fromRGB(80, 150, 220),
			AccentColor = Color3.fromRGB(120, 60, 160)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235), 
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120),
			
			-- Semantic colors
			ErrorColor = Color3.fromRGB(200, 60, 60),
			SuccessColor = Color3.fromRGB(60, 180, 100),
			WarningColor = Color3.fromRGB(200, 160, 40),
			InfoColor = Color3.fromRGB(60, 130, 200),
			AccentColor = Color3.fromRGB(60, 130, 60)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240), 
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45), 
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), 
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60), 
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
		
		Midnight = {
			TextColor = Color3.fromRGB(230, 230, 255),
			Background = Color3.fromRGB(15, 12, 25),
			Topbar = Color3.fromRGB(20, 16, 35),
			Shadow = Color3.fromRGB(10, 8, 18),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(20, 16, 30),
			NotificationActionsBackground = Color3.fromRGB(35, 30, 55),

			TabBackground = Color3.fromRGB(35, 28, 55),
			TabStroke = Color3.fromRGB(60, 50, 90),
			TabBackgroundSelected = Color3.fromRGB(100, 70, 180),
			TabTextColor = Color3.fromRGB(180, 170, 220),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(25, 20, 40),
			ElementBackgroundHover = Color3.fromRGB(35, 28, 55),
			SecondaryElementBackground = Color3.fromRGB(20, 16, 35),
			ElementStroke = Color3.fromRGB(60, 50, 100),
			SecondaryElementStroke = Color3.fromRGB(50, 40, 80),

			SliderBackground = Color3.fromRGB(80, 50, 150),
			SliderProgress = Color3.fromRGB(130, 80, 220),
			SliderStroke = Color3.fromRGB(150, 100, 255),

			ToggleBackground = Color3.fromRGB(25, 20, 40),
			ToggleEnabled = Color3.fromRGB(130, 80, 220),
			ToggleDisabled = Color3.fromRGB(60, 50, 80),
			ToggleEnabledStroke = Color3.fromRGB(160, 100, 255),
			ToggleDisabledStroke = Color3.fromRGB(80, 70, 100),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 60, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(50, 40, 70),

			DropdownSelected = Color3.fromRGB(40, 32, 65),
			DropdownUnselected = Color3.fromRGB(25, 20, 40),

			InputBackground = Color3.fromRGB(25, 20, 40),
			InputStroke = Color3.fromRGB(70, 55, 110),
			PlaceholderColor = Color3.fromRGB(120, 110, 150)
		},

		Neon = {
			TextColor = Color3.fromRGB(0, 255, 200),
			Background = Color3.fromRGB(8, 8, 12),
			Topbar = Color3.fromRGB(12, 12, 18),
			Shadow = Color3.fromRGB(0, 0, 0),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(10, 10, 15),
			NotificationActionsBackground = Color3.fromRGB(0, 255, 200),

			TabBackground = Color3.fromRGB(15, 15, 22),
			TabStroke = Color3.fromRGB(0, 180, 140),
			TabBackgroundSelected = Color3.fromRGB(0, 255, 200),
			TabTextColor = Color3.fromRGB(0, 200, 160),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(12, 12, 18),
			ElementBackgroundHover = Color3.fromRGB(18, 18, 25),
			SecondaryElementBackground = Color3.fromRGB(10, 10, 15),
			ElementStroke = Color3.fromRGB(0, 150, 120),
			SecondaryElementStroke = Color3.fromRGB(0, 120, 100),

			SliderBackground = Color3.fromRGB(0, 100, 80),
			SliderProgress = Color3.fromRGB(0, 255, 200),
			SliderStroke = Color3.fromRGB(0, 255, 220),

			ToggleBackground = Color3.fromRGB(12, 12, 18),
			ToggleEnabled = Color3.fromRGB(0, 255, 200),
			ToggleDisabled = Color3.fromRGB(40, 40, 50),
			ToggleEnabledStroke = Color3.fromRGB(0, 255, 220),
			ToggleDisabledStroke = Color3.fromRGB(60, 60, 70),
			ToggleEnabledOuterStroke = Color3.fromRGB(0, 200, 160),
			ToggleDisabledOuterStroke = Color3.fromRGB(30, 30, 40),

			DropdownSelected = Color3.fromRGB(0, 80, 60),
			DropdownUnselected = Color3.fromRGB(12, 12, 18),

			InputBackground = Color3.fromRGB(12, 12, 18),
			InputStroke = Color3.fromRGB(0, 180, 140),
			PlaceholderColor = Color3.fromRGB(0, 150, 120)
		},

		Sunset = {
			TextColor = Color3.fromRGB(255, 240, 230),
			Background = Color3.fromRGB(30, 15, 25),
			Topbar = Color3.fromRGB(40, 20, 35),
			Shadow = Color3.fromRGB(20, 10, 18),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(35, 18, 30),
			NotificationActionsBackground = Color3.fromRGB(255, 120, 80),

			TabBackground = Color3.fromRGB(50, 25, 40),
			TabStroke = Color3.fromRGB(120, 50, 80),
			TabBackgroundSelected = Color3.fromRGB(255, 100, 80),
			TabTextColor = Color3.fromRGB(255, 180, 160),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(40, 20, 35),
			ElementBackgroundHover = Color3.fromRGB(55, 28, 45),
			SecondaryElementBackground = Color3.fromRGB(35, 18, 30),
			ElementStroke = Color3.fromRGB(150, 60, 90),
			SecondaryElementStroke = Color3.fromRGB(120, 50, 75),

			SliderBackground = Color3.fromRGB(200, 80, 60),
			SliderProgress = Color3.fromRGB(255, 120, 80),
			SliderStroke = Color3.fromRGB(255, 150, 100),

			ToggleBackground = Color3.fromRGB(40, 20, 35),
			ToggleEnabled = Color3.fromRGB(255, 100, 70),
			ToggleDisabled = Color3.fromRGB(80, 50, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 130, 90),
			ToggleDisabledStroke = Color3.fromRGB(100, 60, 70),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 80, 60),
			ToggleDisabledOuterStroke = Color3.fromRGB(60, 35, 45),

			DropdownSelected = Color3.fromRGB(60, 30, 45),
			DropdownUnselected = Color3.fromRGB(40, 20, 35),

			InputBackground = Color3.fromRGB(40, 20, 35),
			InputStroke = Color3.fromRGB(150, 70, 100),
			PlaceholderColor = Color3.fromRGB(180, 130, 140)
		},

		Cyberpunk = {
			TextColor = Color3.fromRGB(255, 255, 0),
			Background = Color3.fromRGB(10, 5, 15),
			Topbar = Color3.fromRGB(15, 8, 22),
			Shadow = Color3.fromRGB(5, 2, 8),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(12, 6, 18),
			NotificationActionsBackground = Color3.fromRGB(255, 0, 100),

			TabBackground = Color3.fromRGB(20, 10, 30),
			TabStroke = Color3.fromRGB(255, 0, 100),
			TabBackgroundSelected = Color3.fromRGB(255, 0, 100),
			TabTextColor = Color3.fromRGB(255, 200, 0),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(15, 8, 22),
			ElementBackgroundHover = Color3.fromRGB(25, 12, 35),
			SecondaryElementBackground = Color3.fromRGB(12, 6, 18),
			ElementStroke = Color3.fromRGB(255, 0, 100),
			SecondaryElementStroke = Color3.fromRGB(200, 0, 80),

			SliderBackground = Color3.fromRGB(150, 0, 60),
			SliderProgress = Color3.fromRGB(255, 0, 100),
			SliderStroke = Color3.fromRGB(255, 50, 130),

			ToggleBackground = Color3.fromRGB(15, 8, 22),
			ToggleEnabled = Color3.fromRGB(255, 0, 100),
			ToggleDisabled = Color3.fromRGB(50, 30, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 50, 130),
			ToggleDisabledStroke = Color3.fromRGB(80, 50, 90),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 0, 80),
			ToggleDisabledOuterStroke = Color3.fromRGB(40, 25, 50),

			DropdownSelected = Color3.fromRGB(30, 15, 45),
			DropdownUnselected = Color3.fromRGB(15, 8, 22),

			InputBackground = Color3.fromRGB(15, 8, 22),
			InputStroke = Color3.fromRGB(255, 0, 100),
			PlaceholderColor = Color3.fromRGB(200, 150, 0)
		},

		Ice = {
			TextColor = Color3.fromRGB(220, 240, 255),
			Background = Color3.fromRGB(15, 25, 35),
			Topbar = Color3.fromRGB(20, 35, 50),
			Shadow = Color3.fromRGB(10, 18, 28),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(18, 30, 42),
			NotificationActionsBackground = Color3.fromRGB(100, 180, 255),

			TabBackground = Color3.fromRGB(25, 45, 65),
			TabStroke = Color3.fromRGB(80, 150, 220),
			TabBackgroundSelected = Color3.fromRGB(80, 160, 255),
			TabTextColor = Color3.fromRGB(150, 200, 255),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(20, 38, 55),
			ElementBackgroundHover = Color3.fromRGB(28, 50, 72),
			SecondaryElementBackground = Color3.fromRGB(18, 32, 48),
			ElementStroke = Color3.fromRGB(70, 130, 200),
			SecondaryElementStroke = Color3.fromRGB(60, 110, 170),

			SliderBackground = Color3.fromRGB(50, 120, 200),
			SliderProgress = Color3.fromRGB(80, 170, 255),
			SliderStroke = Color3.fromRGB(100, 190, 255),

			ToggleBackground = Color3.fromRGB(20, 38, 55),
			ToggleEnabled = Color3.fromRGB(80, 170, 255),
			ToggleDisabled = Color3.fromRGB(50, 70, 90),
			ToggleEnabledStroke = Color3.fromRGB(100, 190, 255),
			ToggleDisabledStroke = Color3.fromRGB(70, 90, 110),
			ToggleEnabledOuterStroke = Color3.fromRGB(60, 140, 220),
			ToggleDisabledOuterStroke = Color3.fromRGB(40, 55, 70),

			DropdownSelected = Color3.fromRGB(30, 55, 80),
			DropdownUnselected = Color3.fromRGB(20, 38, 55),

			InputBackground = Color3.fromRGB(20, 38, 55),
			InputStroke = Color3.fromRGB(80, 150, 220),
			PlaceholderColor = Color3.fromRGB(120, 160, 200)
		},

		Blood = {
			TextColor = Color3.fromRGB(255, 220, 220),
			Background = Color3.fromRGB(18, 8, 10),
			Topbar = Color3.fromRGB(25, 12, 15),
			Shadow = Color3.fromRGB(10, 5, 6),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(22, 10, 12),
			NotificationActionsBackground = Color3.fromRGB(180, 30, 50),

			TabBackground = Color3.fromRGB(35, 15, 20),
			TabStroke = Color3.fromRGB(150, 40, 60),
			TabBackgroundSelected = Color3.fromRGB(180, 30, 50),
			TabTextColor = Color3.fromRGB(255, 150, 150),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(28, 12, 16),
			ElementBackgroundHover = Color3.fromRGB(40, 18, 24),
			SecondaryElementBackground = Color3.fromRGB(22, 10, 13),
			ElementStroke = Color3.fromRGB(140, 50, 70),
			SecondaryElementStroke = Color3.fromRGB(110, 40, 55),

			SliderBackground = Color3.fromRGB(120, 20, 40),
			SliderProgress = Color3.fromRGB(200, 40, 60),
			SliderStroke = Color3.fromRGB(220, 60, 80),

			ToggleBackground = Color3.fromRGB(28, 12, 16),
			ToggleEnabled = Color3.fromRGB(200, 40, 60),
			ToggleDisabled = Color3.fromRGB(60, 35, 40),
			ToggleEnabledStroke = Color3.fromRGB(220, 60, 80),
			ToggleDisabledStroke = Color3.fromRGB(80, 50, 55),
			ToggleEnabledOuterStroke = Color3.fromRGB(160, 30, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 25, 30),

			DropdownSelected = Color3.fromRGB(45, 20, 28),
			DropdownUnselected = Color3.fromRGB(28, 12, 16),

			InputBackground = Color3.fromRGB(28, 12, 16),
			InputStroke = Color3.fromRGB(150, 50, 70),
			PlaceholderColor = Color3.fromRGB(180, 120, 130)
		},

		Emerald = {
			TextColor = Color3.fromRGB(220, 255, 230),
			Background = Color3.fromRGB(8, 20, 15),
			Topbar = Color3.fromRGB(12, 28, 22),
			Shadow = Color3.fromRGB(5, 12, 10),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(10, 25, 18),
			NotificationActionsBackground = Color3.fromRGB(40, 200, 120),

			TabBackground = Color3.fromRGB(15, 40, 30),
			TabStroke = Color3.fromRGB(50, 150, 100),
			TabBackgroundSelected = Color3.fromRGB(40, 180, 110),
			TabTextColor = Color3.fromRGB(150, 230, 180),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(12, 32, 24),
			ElementBackgroundHover = Color3.fromRGB(18, 45, 35),
			SecondaryElementBackground = Color3.fromRGB(10, 26, 20),
			ElementStroke = Color3.fromRGB(50, 140, 95),
			SecondaryElementStroke = Color3.fromRGB(40, 110, 75),

			SliderBackground = Color3.fromRGB(30, 120, 80),
			SliderProgress = Color3.fromRGB(50, 200, 130),
			SliderStroke = Color3.fromRGB(60, 220, 150),

			ToggleBackground = Color3.fromRGB(12, 32, 24),
			ToggleEnabled = Color3.fromRGB(50, 200, 130),
			ToggleDisabled = Color3.fromRGB(35, 60, 48),
			ToggleEnabledStroke = Color3.fromRGB(60, 220, 150),
			ToggleDisabledStroke = Color3.fromRGB(50, 80, 65),
			ToggleEnabledOuterStroke = Color3.fromRGB(40, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(25, 45, 35),

			DropdownSelected = Color3.fromRGB(20, 50, 38),
			DropdownUnselected = Color3.fromRGB(12, 32, 24),

			InputBackground = Color3.fromRGB(12, 32, 24),
			InputStroke = Color3.fromRGB(50, 150, 100),
			PlaceholderColor = Color3.fromRGB(100, 180, 140)
		},

		Rose = {
			TextColor = Color3.fromRGB(255, 230, 240),
			Background = Color3.fromRGB(25, 15, 22),
			Topbar = Color3.fromRGB(35, 20, 30),
			Shadow = Color3.fromRGB(15, 10, 14),


			SpinnerAsset = "rbxassetid://11963373994",

			NotificationBackground = Color3.fromRGB(30, 18, 26),
			NotificationActionsBackground = Color3.fromRGB(255, 120, 170),

			TabBackground = Color3.fromRGB(50, 30, 42),
			TabStroke = Color3.fromRGB(200, 100, 140),
			TabBackgroundSelected = Color3.fromRGB(255, 100, 150),
			TabTextColor = Color3.fromRGB(255, 180, 210),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(38, 22, 32),
			ElementBackgroundHover = Color3.fromRGB(52, 32, 44),
			SecondaryElementBackground = Color3.fromRGB(32, 18, 27),
			ElementStroke = Color3.fromRGB(180, 90, 130),
			SecondaryElementStroke = Color3.fromRGB(150, 75, 110),

			SliderBackground = Color3.fromRGB(180, 70, 110),
			SliderProgress = Color3.fromRGB(255, 100, 150),
			SliderStroke = Color3.fromRGB(255, 130, 175),

			ToggleBackground = Color3.fromRGB(38, 22, 32),
			ToggleEnabled = Color3.fromRGB(255, 100, 150),
			ToggleDisabled = Color3.fromRGB(70, 50, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 130, 175),
			ToggleDisabledStroke = Color3.fromRGB(90, 65, 78),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 80, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 38, 48),

			DropdownSelected = Color3.fromRGB(55, 35, 48),
			DropdownUnselected = Color3.fromRGB(38, 22, 32),

			InputBackground = Color3.fromRGB(38, 22, 32),
			InputStroke = Color3.fromRGB(200, 100, 145),
			PlaceholderColor = Color3.fromRGB(200, 150, 175)
		},
		
		-- ðŸ”¥ NIGHTTESTER - Premium Purple Theme ðŸ”¥
		NightTester = {
			TextColor = Color3.fromRGB(240, 235, 255),
			Background = Color3.fromRGB(12, 10, 22),
			Topbar = Color3.fromRGB(18, 15, 32),
			Shadow = Color3.fromRGB(8, 6, 15),


			SpinnerAsset = "rbxassetid://11963373994",
			
			NotificationBackground = Color3.fromRGB(22, 18, 40),
			NotificationActionsBackground = Color3.fromRGB(160, 100, 255),
			
			TabBackground = Color3.fromRGB(35, 28, 65),
			TabStroke = Color3.fromRGB(120, 80, 200),
			TabBackgroundSelected = Color3.fromRGB(140, 90, 255),
			TabTextColor = Color3.fromRGB(180, 160, 220),
			SelectedTabTextColor = Color3.fromRGB(220, 180, 255),
			
			ElementBackground = Color3.fromRGB(22, 20, 42),
			ElementBackgroundHover = Color3.fromRGB(40, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(18, 15, 35),
			ElementStroke = Color3.fromRGB(100, 70, 160),
			SecondaryElementStroke = Color3.fromRGB(70, 55, 120),
			
			SliderBackground = Color3.fromRGB(50, 35, 100),
			SliderProgress = Color3.fromRGB(160, 100, 255),
			SliderStroke = Color3.fromRGB(200, 150, 255),
			
			ToggleBackground = Color3.fromRGB(22, 20, 38),
			ToggleEnabled = Color3.fromRGB(160, 100, 255),
			ToggleDisabled = Color3.fromRGB(60, 55, 90),
			ToggleEnabledStroke = Color3.fromRGB(200, 160, 255),
			ToggleDisabledStroke = Color3.fromRGB(80, 75, 110),
			ToggleEnabledOuterStroke = Color3.fromRGB(140, 100, 220),
			ToggleDisabledOuterStroke = Color3.fromRGB(50, 45, 75),
			
			DropdownSelected = Color3.fromRGB(45, 38, 75),
			DropdownUnselected = Color3.fromRGB(25, 22, 48),
			
			InputBackground = Color3.fromRGB(22, 20, 42),
			InputStroke = Color3.fromRGB(100, 70, 160),
			PlaceholderColor = Color3.fromRGB(130, 120, 170)
		},
		
		-- ðŸ”¥ OCEAN - Deep Blue Theme ðŸ”¥
		Ocean = {
			TextColor = Color3.fromRGB(220, 240, 255),
			Background = Color3.fromRGB(8, 15, 25),
			Topbar = Color3.fromRGB(12, 22, 38),
			Shadow = Color3.fromRGB(5, 10, 18),
			
			NotificationBackground = Color3.fromRGB(15, 28, 45),
			NotificationActionsBackground = Color3.fromRGB(50, 150, 255),
			
			TabBackground = Color3.fromRGB(20, 40, 65),
			TabStroke = Color3.fromRGB(50, 120, 180),
			TabBackgroundSelected = Color3.fromRGB(40, 130, 200),
			TabTextColor = Color3.fromRGB(150, 190, 220),
			SelectedTabTextColor = Color3.fromRGB(200, 230, 255),
			
			ElementBackground = Color3.fromRGB(15, 30, 50),
			ElementBackgroundHover = Color3.fromRGB(25, 50, 80),
			SecondaryElementBackground = Color3.fromRGB(12, 25, 42),
			ElementStroke = Color3.fromRGB(50, 100, 160),
			SecondaryElementStroke = Color3.fromRGB(40, 80, 130),
			
			SliderBackground = Color3.fromRGB(25, 60, 100),
			SliderProgress = Color3.fromRGB(50, 150, 255),
			SliderStroke = Color3.fromRGB(100, 180, 255),
			
			ToggleBackground = Color3.fromRGB(15, 30, 50),
			ToggleEnabled = Color3.fromRGB(50, 150, 255),
			ToggleDisabled = Color3.fromRGB(40, 60, 85),
			ToggleEnabledStroke = Color3.fromRGB(100, 180, 255),
			ToggleDisabledStroke = Color3.fromRGB(60, 90, 120),
			ToggleEnabledOuterStroke = Color3.fromRGB(40, 120, 200),
			ToggleDisabledOuterStroke = Color3.fromRGB(30, 50, 75),
			
			DropdownSelected = Color3.fromRGB(30, 55, 85),
			DropdownUnselected = Color3.fromRGB(18, 35, 55),
			
			InputBackground = Color3.fromRGB(15, 30, 50),
			InputStroke = Color3.fromRGB(50, 100, 160),
			PlaceholderColor = Color3.fromRGB(100, 140, 180)
		},
		
		-- ðŸ”¥ FOREST - Green Nature Theme ðŸ”¥
		Forest = {
			TextColor = Color3.fromRGB(220, 255, 230),
			Background = Color3.fromRGB(10, 18, 12),
			Topbar = Color3.fromRGB(15, 28, 18),
			Shadow = Color3.fromRGB(6, 12, 8),


			SpinnerAsset = "rbxassetid://11963373994",
			
			NotificationBackground = Color3.fromRGB(18, 35, 22),
			NotificationActionsBackground = Color3.fromRGB(80, 200, 120),
			
			TabBackground = Color3.fromRGB(25, 50, 32),
			TabStroke = Color3.fromRGB(60, 140, 80),
			TabBackgroundSelected = Color3.fromRGB(60, 180, 100),
			TabTextColor = Color3.fromRGB(160, 210, 175),
			SelectedTabTextColor = Color3.fromRGB(200, 255, 220),
			
			ElementBackground = Color3.fromRGB(18, 38, 24),
			ElementBackgroundHover = Color3.fromRGB(30, 60, 40),
			SecondaryElementBackground = Color3.fromRGB(14, 30, 18),
			ElementStroke = Color3.fromRGB(60, 130, 80),
			SecondaryElementStroke = Color3.fromRGB(45, 100, 60),
			
			SliderBackground = Color3.fromRGB(30, 70, 45),
			SliderProgress = Color3.fromRGB(80, 200, 120),
			SliderStroke = Color3.fromRGB(120, 220, 150),
			
			ToggleBackground = Color3.fromRGB(18, 38, 24),
			ToggleEnabled = Color3.fromRGB(80, 200, 120),
			ToggleDisabled = Color3.fromRGB(45, 70, 52),
			ToggleEnabledStroke = Color3.fromRGB(120, 230, 160),
			ToggleDisabledStroke = Color3.fromRGB(65, 95, 72),
			ToggleEnabledOuterStroke = Color3.fromRGB(60, 160, 95),
			ToggleDisabledOuterStroke = Color3.fromRGB(35, 55, 40),
			
			DropdownSelected = Color3.fromRGB(35, 65, 42),
			DropdownUnselected = Color3.fromRGB(22, 42, 28),
			
			InputBackground = Color3.fromRGB(18, 38, 24),
			InputStroke = Color3.fromRGB(60, 130, 80),
			PlaceholderColor = Color3.fromRGB(110, 160, 125)
		},
		
		-- ðŸ”¥ GOLD - Luxury Gold Theme ðŸ”¥
		Gold = {
			TextColor = Color3.fromRGB(255, 245, 220),
			Background = Color3.fromRGB(18, 14, 8),
			Topbar = Color3.fromRGB(28, 22, 12),
			Shadow = Color3.fromRGB(12, 9, 5),


			SpinnerAsset = "rbxassetid://11963373994",
			
			NotificationBackground = Color3.fromRGB(32, 26, 15),
			NotificationActionsBackground = Color3.fromRGB(220, 180, 80),
			
			TabBackground = Color3.fromRGB(45, 38, 22),
			TabStroke = Color3.fromRGB(180, 150, 60),
			TabBackgroundSelected = Color3.fromRGB(200, 170, 80),
			TabTextColor = Color3.fromRGB(200, 180, 140),
			SelectedTabTextColor = Color3.fromRGB(255, 235, 180),
			
			ElementBackground = Color3.fromRGB(35, 28, 16),
			ElementBackgroundHover = Color3.fromRGB(50, 42, 25),
			SecondaryElementBackground = Color3.fromRGB(28, 22, 12),
			ElementStroke = Color3.fromRGB(160, 130, 60),
			SecondaryElementStroke = Color3.fromRGB(120, 100, 50),
			
			SliderBackground = Color3.fromRGB(60, 50, 28),
			SliderProgress = Color3.fromRGB(220, 180, 80),
			SliderStroke = Color3.fromRGB(255, 220, 120),
			
			ToggleBackground = Color3.fromRGB(35, 28, 16),
			ToggleEnabled = Color3.fromRGB(220, 180, 80),
			ToggleDisabled = Color3.fromRGB(70, 60, 40),
			ToggleEnabledStroke = Color3.fromRGB(255, 220, 120),
			ToggleDisabledStroke = Color3.fromRGB(100, 85, 55),
			ToggleEnabledOuterStroke = Color3.fromRGB(180, 150, 70),
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 45, 28),
			
			DropdownSelected = Color3.fromRGB(55, 45, 28),
			DropdownUnselected = Color3.fromRGB(38, 30, 18),
			
			InputBackground = Color3.fromRGB(35, 28, 16),
			InputStroke = Color3.fromRGB(160, 130, 60),
			PlaceholderColor = Color3.fromRGB(150, 130, 100)
		},
		
		-- ðŸ”¥ CHERRY - Red/Pink Theme ðŸ”¥
		Cherry = {
			TextColor = Color3.fromRGB(255, 235, 240),
			Background = Color3.fromRGB(20, 10, 15),
			Topbar = Color3.fromRGB(32, 15, 22),
			Shadow = Color3.fromRGB(14, 7, 10),


			SpinnerAsset = "rbxassetid://11963373994",
			
			NotificationBackground = Color3.fromRGB(38, 18, 28),
			NotificationActionsBackground = Color3.fromRGB(255, 80, 130),
			
			TabBackground = Color3.fromRGB(55, 28, 40),
			TabStroke = Color3.fromRGB(180, 70, 110),
			TabBackgroundSelected = Color3.fromRGB(220, 80, 130),
			TabTextColor = Color3.fromRGB(220, 170, 190),
			SelectedTabTextColor = Color3.fromRGB(255, 220, 235),
			
			ElementBackground = Color3.fromRGB(40, 20, 30),
			ElementBackgroundHover = Color3.fromRGB(60, 32, 45),
			SecondaryElementBackground = Color3.fromRGB(32, 16, 24),
			ElementStroke = Color3.fromRGB(160, 70, 105),
			SecondaryElementStroke = Color3.fromRGB(120, 55, 80),
			
			SliderBackground = Color3.fromRGB(70, 35, 50),
			SliderProgress = Color3.fromRGB(255, 80, 130),
			SliderStroke = Color3.fromRGB(255, 130, 170),
			
			ToggleBackground = Color3.fromRGB(40, 20, 30),
			ToggleEnabled = Color3.fromRGB(255, 80, 130),
			ToggleDisabled = Color3.fromRGB(75, 50, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 130, 170),
			ToggleDisabledStroke = Color3.fromRGB(100, 70, 82),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 65, 105),
			ToggleDisabledOuterStroke = Color3.fromRGB(60, 38, 48),
			
			DropdownSelected = Color3.fromRGB(60, 32, 45),
			DropdownUnselected = Color3.fromRGB(42, 22, 32),
			
			InputBackground = Color3.fromRGB(40, 20, 30),
			InputStroke = Color3.fromRGB(160, 70, 105),
			PlaceholderColor = Color3.fromRGB(180, 140, 160)
		},
		
		-- ðŸ”¥ PIKACHU - Electric Yellow Theme with Background (DARK TEXT) ðŸ”¥
		Pikachu = {
			TextColor = Color3.fromRGB(50, 35, 10),  -- VERY dark brown for max readability
			Background = Color3.fromRGB(255, 245, 180),  -- Warm yellow
			Topbar = Color3.fromRGB(255, 200, 40),  -- Electric yellow
			Shadow = Color3.fromRGB(180, 130, 20),

  -- Very subtle
			SpinnerAsset = "rbxassetid://11963373994",  -- Arc spinner
			
			NotificationBackground = Color3.fromRGB(255, 248, 200),
			NotificationActionsBackground = Color3.fromRGB(255, 160, 0),
			
			TabBackground = Color3.fromRGB(255, 230, 130),
			TabStroke = Color3.fromRGB(220, 160, 20),
			TabBackgroundSelected = Color3.fromRGB(255, 160, 0),  -- Orange selected
			TabTextColor = Color3.fromRGB(70, 50, 10),  -- DARK brown text
			SelectedTabTextColor = Color3.fromRGB(40, 25, 5),  -- Very dark when selected
			
			ElementBackground = Color3.fromRGB(255, 240, 160),
			ElementBackgroundHover = Color3.fromRGB(255, 225, 120),
			SecondaryElementBackground = Color3.fromRGB(255, 245, 180),
			ElementStroke = Color3.fromRGB(230, 180, 60),
			SecondaryElementStroke = Color3.fromRGB(210, 160, 50),
			
			SliderBackground = Color3.fromRGB(255, 210, 80),
			SliderProgress = Color3.fromRGB(255, 160, 0),
			SliderStroke = Color3.fromRGB(255, 180, 30),
			
			ToggleBackground = Color3.fromRGB(255, 235, 140),
			ToggleEnabled = Color3.fromRGB(255, 160, 0),
			ToggleDisabled = Color3.fromRGB(220, 200, 140),
			ToggleEnabledStroke = Color3.fromRGB(255, 180, 30),
			ToggleDisabledStroke = Color3.fromRGB(190, 170, 110),
			ToggleEnabledOuterStroke = Color3.fromRGB(230, 150, 0),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 160, 100),
			
			DropdownSelected = Color3.fromRGB(255, 220, 100),
			DropdownUnselected = Color3.fromRGB(255, 240, 160),
			
			InputBackground = Color3.fromRGB(255, 245, 180),
			InputStroke = Color3.fromRGB(230, 180, 60),
			PlaceholderColor = Color3.fromRGB(140, 110, 50)
		},
		
		-- ðŸ”¥ SAKURA - Anime Pink Theme with Background (DARK TEXT FOR READABILITY) ðŸ”¥
		Sakura = {
			TextColor = Color3.fromRGB(80, 20, 50),  -- VERY dark maroon for max readability
			Background = Color3.fromRGB(255, 240, 248),  -- Soft pink
			Topbar = Color3.fromRGB(255, 130, 175),  -- Vibrant pink
			Shadow = Color3.fromRGB(180, 100, 130),

  -- Very subtle
			SpinnerAsset = "rbxassetid://11963373994",  -- Arc spinner
			
			NotificationBackground = Color3.fromRGB(255, 230, 242),
			NotificationActionsBackground = Color3.fromRGB(255, 80, 140),
			
			TabBackground = Color3.fromRGB(255, 200, 220),
			TabStroke = Color3.fromRGB(255, 100, 160),
			TabBackgroundSelected = Color3.fromRGB(255, 80, 140),  -- Hot pink selected
			TabTextColor = Color3.fromRGB(100, 40, 65),  -- DARK text on tabs
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
			
			ElementBackground = Color3.fromRGB(255, 235, 245),
			ElementBackgroundHover = Color3.fromRGB(255, 210, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 242, 250),
			ElementStroke = Color3.fromRGB(255, 120, 170),
			SecondaryElementStroke = Color3.fromRGB(255, 150, 190),
			
			SliderBackground = Color3.fromRGB(255, 180, 210),
			SliderProgress = Color3.fromRGB(255, 60, 130),
			SliderStroke = Color3.fromRGB(255, 100, 160),
			
			ToggleBackground = Color3.fromRGB(255, 230, 242),
			ToggleEnabled = Color3.fromRGB(255, 60, 130),
			ToggleDisabled = Color3.fromRGB(230, 200, 215),
			ToggleEnabledStroke = Color3.fromRGB(255, 100, 160),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 195),
			ToggleEnabledOuterStroke = Color3.fromRGB(255, 40, 110),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 182),
			
			DropdownSelected = Color3.fromRGB(255, 190, 220),
			DropdownUnselected = Color3.fromRGB(255, 235, 245),
			
			InputBackground = Color3.fromRGB(255, 242, 250),
			InputStroke = Color3.fromRGB(255, 120, 170),
			PlaceholderColor = Color3.fromRGB(140, 80, 110)
		},
		
		-- ðŸ”¥ GALAXY - Space Purple Theme with Background ðŸ”¥
		Galaxy = {
			TextColor = Color3.fromRGB(230, 220, 255),
			Background = Color3.fromRGB(15, 10, 35),
			Topbar = Color3.fromRGB(25, 15, 55),
			Shadow = Color3.fromRGB(10, 5, 25),


			SpinnerAsset = "rbxassetid://11963373994",  -- Arc spinner
			
			NotificationBackground = Color3.fromRGB(30, 20, 60),
			NotificationActionsBackground = Color3.fromRGB(150, 80, 255),
			
			TabBackground = Color3.fromRGB(40, 25, 80),
			TabStroke = Color3.fromRGB(100, 60, 180),
			TabBackgroundSelected = Color3.fromRGB(130, 70, 220),
			TabTextColor = Color3.fromRGB(180, 160, 230),
			SelectedTabTextColor = Color3.fromRGB(255, 230, 255),
			
			ElementBackground = Color3.fromRGB(30, 20, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 90),
			SecondaryElementBackground = Color3.fromRGB(25, 15, 50),
			ElementStroke = Color3.fromRGB(100, 60, 180),
			SecondaryElementStroke = Color3.fromRGB(80, 50, 150),
			
			SliderBackground = Color3.fromRGB(60, 35, 120),
			SliderProgress = Color3.fromRGB(150, 80, 255),
			SliderStroke = Color3.fromRGB(180, 120, 255),
			
			ToggleBackground = Color3.fromRGB(30, 20, 60),
			ToggleEnabled = Color3.fromRGB(150, 80, 255),
			ToggleDisabled = Color3.fromRGB(60, 50, 90),
			ToggleEnabledStroke = Color3.fromRGB(180, 120, 255),
			ToggleDisabledStroke = Color3.fromRGB(80, 70, 110),
			ToggleEnabledOuterStroke = Color3.fromRGB(130, 70, 220),
			ToggleDisabledOuterStroke = Color3.fromRGB(50, 40, 75),
			
			DropdownSelected = Color3.fromRGB(50, 35, 90),
			DropdownUnselected = Color3.fromRGB(30, 20, 60),
			
			InputBackground = Color3.fromRGB(30, 20, 60),
			InputStroke = Color3.fromRGB(100, 60, 180),
			PlaceholderColor = Color3.fromRGB(140, 120, 180)
		},
		
		-- ðŸ”¥ DRAGON - Fire Red Theme with Background ðŸ”¥
		Dragon = {
			TextColor = Color3.fromRGB(255, 240, 220),
			Background = Color3.fromRGB(30, 10, 10),
			Topbar = Color3.fromRGB(50, 15, 15),
			Shadow = Color3.fromRGB(20, 5, 5),


			SpinnerAsset = "rbxassetid://11963373994",  -- Arc spinner
			
			NotificationBackground = Color3.fromRGB(50, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(255, 80, 50),
			
			TabBackground = Color3.fromRGB(70, 25, 25),
			TabStroke = Color3.fromRGB(200, 60, 40),
			TabBackgroundSelected = Color3.fromRGB(255, 80, 50),
			TabTextColor = Color3.fromRGB(255, 200, 180),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 230),
			
			ElementBackground = Color3.fromRGB(50, 20, 20),
			ElementBackgroundHover = Color3.fromRGB(80, 35, 30),
			SecondaryElementBackground = Color3.fromRGB(40, 15, 15),
			ElementStroke = Color3.fromRGB(200, 60, 40),
			SecondaryElementStroke = Color3.fromRGB(150, 50, 35),
			
			SliderBackground = Color3.fromRGB(100, 35, 30),
			SliderProgress = Color3.fromRGB(255, 100, 50),
			SliderStroke = Color3.fromRGB(255, 150, 80),
			
			ToggleBackground = Color3.fromRGB(50, 20, 20),
			ToggleEnabled = Color3.fromRGB(255, 80, 50),
			ToggleDisabled = Color3.fromRGB(80, 60, 55),
			ToggleEnabledStroke = Color3.fromRGB(255, 130, 80),
			ToggleDisabledStroke = Color3.fromRGB(100, 80, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 70, 45),
			ToggleDisabledOuterStroke = Color3.fromRGB(70, 50, 45),
			
			DropdownSelected = Color3.fromRGB(80, 35, 30),
			DropdownUnselected = Color3.fromRGB(50, 20, 20),
			
			InputBackground = Color3.fromRGB(50, 20, 20),
			InputStroke = Color3.fromRGB(200, 60, 40),
			PlaceholderColor = Color3.fromRGB(200, 150, 140)
		},
		
		-- ðŸ”¥ AQUA - Ocean Blue Theme with Background ðŸ”¥
		Aqua = {
			TextColor = Color3.fromRGB(220, 250, 255),
			Background = Color3.fromRGB(10, 30, 50),
			Topbar = Color3.fromRGB(15, 45, 70),
			Shadow = Color3.fromRGB(5, 20, 35),


			SpinnerAsset = "rbxassetid://11963373994",  -- Arc spinner
			
			NotificationBackground = Color3.fromRGB(20, 50, 80),
			NotificationActionsBackground = Color3.fromRGB(50, 180, 255),
			
			TabBackground = Color3.fromRGB(25, 60, 95),
			TabStroke = Color3.fromRGB(60, 160, 220),
			TabBackgroundSelected = Color3.fromRGB(50, 180, 255),
			TabTextColor = Color3.fromRGB(180, 220, 240),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
			
			ElementBackground = Color3.fromRGB(20, 50, 80),
			ElementBackgroundHover = Color3.fromRGB(35, 75, 110),
			SecondaryElementBackground = Color3.fromRGB(15, 40, 65),
			ElementStroke = Color3.fromRGB(60, 160, 220),
			SecondaryElementStroke = Color3.fromRGB(50, 130, 180),
			
			SliderBackground = Color3.fromRGB(35, 80, 120),
			SliderProgress = Color3.fromRGB(50, 180, 255),
			SliderStroke = Color3.fromRGB(100, 200, 255),
			
			ToggleBackground = Color3.fromRGB(20, 50, 80),
			ToggleEnabled = Color3.fromRGB(50, 180, 255),
			ToggleDisabled = Color3.fromRGB(50, 80, 100),
			ToggleEnabledStroke = Color3.fromRGB(100, 200, 255),
			ToggleDisabledStroke = Color3.fromRGB(70, 100, 120),
			ToggleEnabledOuterStroke = Color3.fromRGB(40, 150, 220),
			ToggleDisabledOuterStroke = Color3.fromRGB(40, 65, 85),
			
			DropdownSelected = Color3.fromRGB(35, 75, 110),
			DropdownUnselected = Color3.fromRGB(20, 50, 80),
			
			InputBackground = Color3.fromRGB(20, 50, 80),
			InputStroke = Color3.fromRGB(60, 160, 220),
			PlaceholderColor = Color3.fromRGB(130, 180, 200)
		},
	}
}


-- Services
local UserInputService = getService("UserInputService")
-- TweenService already defined above with AnimationLib
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Interface Management

local NightUI = useStudio and script.Parent:FindFirstChild('NightUI') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local nightuiDestroyed = false -- True when NightUILibrary:Destroy() is called

repeat
	if NightUI:FindFirstChild('Build') and NightUI.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('VeloxLabs | Build Mismatch')
		print('NightUI may encounter issues as you are running an incompatible interface version ('.. ((NightUI:FindFirstChild('Build') and NightUI.Build.Value) or 'No Build') ..').\n\nThis version of NightUI is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	toDestroy, NightUI = NightUI, useStudio and script.Parent:FindFirstChild('NightUI') or game:GetObjects("rbxassetid://10804731440")[1]
	-- if toDestroy and not useStudio then toDestroy:Destroy() end -- allow multiple windows

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

NightUI.Enabled = false
NightUI.Name = "VeloxLabs-"..tostring(math.random(100000,999999))

if gethui then
	NightUI.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(NightUI)
	NightUI.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	NightUI.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	NightUI.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == NightUI.Name and Interface ~= NightUI then
			Interface.Enabled = Interface.Enabled
			Interface.Name = Interface.Name
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == NightUI.Name and Interface ~= NightUI then
			Interface.Enabled = Interface.Enabled
			Interface.Name = Interface.Name
		end
	end
end


local minSize = Vector2.new(1024, 768)
local useMobileSizing

if NightUI.AbsoluteSize.X < minSize.X and NightUI.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

if UserInputService.TouchEnabled then
	useMobilePrompt = true
end
--[[
local Main = NightUI.Main
local MPrompt = NightUI:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = NightUI:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil
]]
--[[
	if Main then
		Main.AnchorPoint = Vector2.new(0.5, 0.5)
		Main.Position = UDim2.new(0.5, 0, 0.5, 0)
		Main.Size = UDim2.new(0, 800, 0, 600)
		Main.ClipsDescendants = true
		Main.BackgroundTransparency = 0
	end

	if Topbar then
		Topbar.BackgroundTransparency = 0
		Topbar.Size = UDim2.new(1, -30, 0, 40)
		Topbar.Position = UDim2.new(0, 15, 0, 10)
	end
	--[[
	if TabList then
		TabList.Position = UDim2.new(0, 15, 0, 60)
		TabList.Size = UDim2.new(0, 160, 1, -80)
	end

	if Elements then
		Elements.Position = UDim2.new(0, 190, 0, 60)
		Elements.Size = UDim2.new(1, -205, 1, -80)
	end
end
	--]]
--[[
	if LoadingFrame then
		LoadingFrame.BackgroundTransparency = 0
		LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 18)

		local spinner = LoadingFrame:FindFirstChild("Spinner") or Instance.new("Frame")
		spinner.Name = "Spinner"
		spinner.Parent = LoadingFrame
		spinner.AnchorPoint = Vector2.new(0.5, 0.5)
		spinner.Position = UDim2.new(0.5, 0, 0.7, 0)
		spinner.Size = UDim2.new(0, 80, 0, 80)
		spinner.BackgroundTransparency = 1

		local img = spinner:FindFirstChild("Img") or Instance.new("ImageLabel")
		img.Name = "Img"
		img.Parent = spinner
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.new(0.5, 0, 0.5, 0)
		img.Size = UDim2.new(1, 0, 1, 0)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://507376371"
		img.ImageColor3 = Color3.fromRGB(0, 255, 200)
		img.ImageTransparency = 0
		local flameBar = LoadingFrame:FindFirstChild("FlameBar") or Instance.new("Frame")
		flameBar.Name = "FlameBar"
		flameBar.Parent = LoadingFrame
		flameBar.AnchorPoint = Vector2.new(0.5, 0.5)
		flameBar.Position = UDim2.new(0.5, 0, 0.85, 0)
		flameBar.Size = UDim2.new(0, 320, 0, 18)
		flameBar.BackgroundColor3 = Color3.fromRGB(8, 14, 26)
		flameBar.BorderSizePixel = 0
		local flameCorner = flameBar:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		flameCorner.CornerRadius = UDim.new(0, 9)
		flameCorner.Parent = flameBar

		local inner = flameBar:FindFirstChild("Inner") or Instance.new("Frame")
		inner.Name = "Inner"
		inner.Parent = flameBar
		inner.AnchorPoint = Vector2.new(0, 0.5)
		inner.Position = UDim2.new(0, 0, 0.5, 0)
		inner.Size = UDim2.new(0, 0, 1, -4)
		inner.BackgroundColor3 = Color3.fromRGB(0, 255, 180)
		inner.BorderSizePixel = 0
		local innerCorner = inner:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		innerCorner.CornerRadius = UDim.new(0, 7)
		innerCorner.Parent = inner
		local gradient = inner:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 140)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 220)),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 120, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 0)),
		})
		gradient.Parent = inner

		task.spawn(function()
			local TweenService = game:GetService("TweenService")
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local grow = TweenService:Create(inner, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 1, -4)
				})
				grow:Play()
				grow.Completed:Wait()
				local shrink = TweenService:Create(inner, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 1, -4)
				})
				shrink:Play()
				shrink.Completed:Wait()
			end
		end)

		task.spawn(function()
			local ts = game:GetService("TweenService")
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local t = ts:Create(img, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = (img.Rotation + 180) % 360})
				t:Play()
				t.Completed:Wait()
			end
		end)
	end
end
]]

-- Old auto-hide task commented out
--[[
	if LoadingFrame and LoadingFrame.Visible then LoadingFrame.Visible = false end
end)
]]

-- Thanks to Latte Softworks for the Lucide integration for Roblox
-- Icons loaded from local file (icons.luau)
local Icons = nil
pcall(function()
	if useStudio then
		Icons = require(script.Parent.icons)
	else
		-- Load from local icons file (same folder as library)
		local iconsUrl = 'https://akrivaslegends.vip/icons.luau'
		local success, result = pcall(function()
			return loadWithTimeout(iconsUrl)
		end)
		if success and result then
			Icons = result
			print('[VeloxLabs] Icons loaded successfully')
		else
			warn('[VeloxLabs] Could not load icons file')
		end
	end
end)
-- Variables

local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
-- local Notifications = NightUI.Notifications

local SelectedTheme = NightUILibrary.Theme.Default

-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- Theme transition duration
local THEME_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local THEME_TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Element type mapping for smart theming
local ElementThemeMap = {
	-- Main containers
	Main = function(element, theme) return {BackgroundColor3 = theme.Background} end,
	Topbar = function(element, theme) return {BackgroundColor3 = theme.Topbar} end,
	CornerRepair = function(element, theme) return {BackgroundColor3 = theme.Topbar} end,
	Shadow = function(element, theme) return nil end, -- Handle separately
	Divider = function(element, theme) return {BackgroundColor3 = theme.ElementStroke} end,
	
	-- Tab elements
	TabList = function(element, theme) return {BackgroundColor3 = theme.Background} end,
	TabContainer = function(element, theme) return {BackgroundColor3 = theme.Background} end,
	AvatarRow = function(element, theme) return nil end, -- Transparent
	
	-- Content elements
	Elements = function(element, theme) return {BackgroundColor3 = theme.Background} end,
	
	-- Section elements
	SectionTitle = function(element, theme) return nil end, -- Text handled separately
	SectionSpacing = function(element, theme) return nil end,
	
	-- Input elements (preserve 0.3 transparency)
	Input = function(element, theme) return {BackgroundColor3 = theme.InputBackground or theme.ElementBackground, BackgroundTransparency = 0.3} end,
	InputFrame = function(element, theme) return {BackgroundColor3 = theme.InputBackground or theme.SecondaryElementBackground} end,
	
	-- Dropdown elements (preserve 0.3 transparency)
	Dropdown = function(element, theme) return {BackgroundColor3 = theme.ElementBackground, BackgroundTransparency = 0.3} end,
	List = function(element, theme) return {BackgroundColor3 = theme.Background} end,
	
	-- Toggle elements (preserve 0.3 transparency)
	Toggle = function(element, theme) return {BackgroundColor3 = theme.ToggleBackground or theme.ElementBackground, BackgroundTransparency = 0.3} end,
	Indicator = function(element, theme) return nil end, -- State-dependent, handled separately
	
	-- Slider elements (preserve 0.3 transparency)
	Slider = function(element, theme) return {BackgroundColor3 = theme.ElementBackground, BackgroundTransparency = 0.3} end,
	Progress = function(element, theme) return {BackgroundColor3 = theme.SliderProgress or theme.ToggleEnabled} end,
	Knob = function(element, theme) return {BackgroundColor3 = theme.ToggleEnabled} end,
	
	-- Button elements (preserve 0.3 transparency)
	Button = function(element, theme) return {BackgroundColor3 = theme.ElementBackground, BackgroundTransparency = 0.3} end,
	
	-- Keybind elements (preserve 0.3 transparency)
	Keybind = function(element, theme) return {BackgroundColor3 = theme.ElementBackground, BackgroundTransparency = 0.3} end,
	KeybindContainer = function(element, theme) return {BackgroundColor3 = theme.InputBackground or theme.SecondaryElementBackground} end,
	
	-- Paragraph elements (preserve 0.3 transparency)
	Paragraph = function(element, theme) return {BackgroundColor3 = theme.ElementBackground, BackgroundTransparency = 0.3} end,
	
	-- Accent bars
	AccentBar = function(element, theme) return {BackgroundColor3 = theme.ToggleEnabled} end,
	
	-- Search elements
	SearchContainer = function(element, theme) return {BackgroundColor3 = theme.ElementBackground} end,
	
	-- Joke container
	JokeContainer = function(element, theme) return {BackgroundColor3 = theme.ElementBackground} end,
	
	-- Credits container
	CreditsContainer = function(element, theme) return {BackgroundColor3 = theme.ElementBackground} end,
	
	-- Notification elements
	Notification = function(element, theme) return {BackgroundColor3 = theme.NotificationBackground or theme.ElementBackground} end,
}

-- ðŸ”¥ THEME COLOR HELPER - Ensures all themes have required colors with fallbacks ðŸ”¥
local function GetThemeColor(theme, colorName)
	if theme[colorName] then
		return theme[colorName]
	end
	
	-- Fallback colors for semantic properties
	local fallbacks = {
		ErrorColor = Color3.fromRGB(200, 60, 60),
		SuccessColor = Color3.fromRGB(60, 200, 100),
		WarningColor = Color3.fromRGB(220, 180, 60),
		InfoColor = Color3.fromRGB(80, 150, 220),
		AccentColor = theme.ToggleEnabled or theme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255),
		PlaceholderColor = Color3.fromRGB(150, 150, 150),
	}
	
	return fallbacks[colorName]
end

-- ðŸ”¥ RECURSIVE APPLY THEME - Updates ALL nested UI elements with smooth animations ðŸ”¥
local function ApplyThemeToElement(element, theme, animated, currentTabPage)
	if not element or not theme then return end
	
	local tweenInfo = animated and THEME_TWEEN_INFO or TweenInfo.new(0)
	
	pcall(function()
		-- Handle different element types
		local elementName = element.Name
		local elementClass = element.ClassName
		
		-- === FRAMES ===
		if elementClass == "Frame" then
			-- Skip certain elements
			if elementName == "Placeholder" or elementName == "Template" then return end
			
			-- Check for specific element mappings
			local mapper = ElementThemeMap[elementName]
			if mapper then
				local props = mapper(element, theme)
				if props and animated then
					TweenService:Create(element, tweenInfo, props):Play()
				elseif props then
					for prop, val in pairs(props) do
						element[prop] = val
					end
				end
			else
				-- Generic frame - check if it's an element container
				if element.BackgroundTransparency < 1 then
					-- Check parent context for proper coloring
					local parentName = element.Parent and element.Parent.Name or ""
					
					if parentName == "TabList" or parentName == "TabContainer" then
						-- Tab button - check if selected
						local isSelected = currentTabPage and element.Name == currentTabPage.Name
						local bgColor = isSelected and theme.TabBackgroundSelected or theme.TabBackground
						if animated then
							TweenService:Create(element, tweenInfo, {BackgroundColor3 = bgColor}):Play()
						else
							element.BackgroundColor3 = bgColor
						end
					elseif elementName ~= "SectionTitle" and elementName ~= "SectionSpacing" and elementName ~= "Divider" then
						-- Regular element
						if animated then
							TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.ElementBackground}):Play()
						else
							element.BackgroundColor3 = theme.ElementBackground
						end
					end
				end
			end
		
		-- === SCROLLING FRAMES ===
		elseif elementClass == "ScrollingFrame" then
			if element.BackgroundTransparency < 1 then
				if animated then
					TweenService:Create(element, tweenInfo, {
						BackgroundColor3 = theme.Background,
						ScrollBarImageColor3 = theme.SliderProgress
					}):Play()
				else
					element.BackgroundColor3 = theme.Background
					element.ScrollBarImageColor3 = theme.SliderProgress
				end
			end
		
		-- === TEXT LABELS ===
		elseif elementClass == "TextLabel" then
			local parentName = element.Parent and element.Parent.Name or ""
			local grandParentName = element.Parent and element.Parent.Parent and element.Parent.Parent.Name or ""
			
			-- Determine text color based on context
			local textColor = theme.TextColor
			
			-- Tab text
			if parentName == "TabList" or parentName == "TabContainer" or grandParentName == "TabList" or grandParentName == "TabContainer" then
				local tabButton = element.Parent
				if tabButton and tabButton:IsA("Frame") then
					local isSelected = currentTabPage and tabButton.Name == currentTabPage.Name
					textColor = isSelected and theme.SelectedTabTextColor or theme.TabTextColor
				end
			-- Section title
			elseif parentName == "SectionTitle" or elementName == "SectionTitle" then
				textColor = theme.TextColor
			-- Username label
			elseif elementName == "Username" then
				textColor = theme.TextColor
			end
			
			if animated then
				TweenService:Create(element, tweenInfo, {TextColor3 = textColor}):Play()
			else
				element.TextColor3 = textColor
			end
		
		-- === TEXT BUTTONS ===
		elseif elementClass == "TextButton" then
			if animated then
				TweenService:Create(element, tweenInfo, {TextColor3 = theme.TextColor}):Play()
			else
				element.TextColor3 = theme.TextColor
			end
			
			-- Handle button background if visible
			if element.BackgroundTransparency < 1 then
				if animated then
					TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.ElementBackground}):Play()
				else
					element.BackgroundColor3 = theme.ElementBackground
				end
			end
		
		-- === TEXT BOXES ===
		elseif elementClass == "TextBox" then
			if animated then
				TweenService:Create(element, tweenInfo, {
					TextColor3 = theme.TextColor,
					PlaceholderColor3 = theme.PlaceholderColor
				}):Play()
			else
				element.TextColor3 = theme.TextColor
				element.PlaceholderColor3 = theme.PlaceholderColor
			end
			
			if element.BackgroundTransparency < 1 then
				if animated then
					TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.InputBackground}):Play()
				else
					element.BackgroundColor3 = theme.InputBackground
				end
			end
		
		-- === IMAGE LABELS ===
		elseif elementClass == "ImageLabel" then
			local parentName = element.Parent and element.Parent.Name or ""
			
			-- Icons should match text color
			if elementName == "Image" or elementName == "Icon" then
				local grandParentName = element.Parent and element.Parent.Parent and element.Parent.Parent.Name or ""
				
				-- Tab icons
				if parentName == "TabList" or parentName == "TabContainer" or grandParentName == "TabList" or grandParentName == "TabContainer" then
					local tabButton = element.Parent
					if tabButton and tabButton:IsA("Frame") then
						local isSelected = currentTabPage and tabButton.Name == currentTabPage.Name
						local iconColor = isSelected and theme.SelectedTabTextColor or theme.TabTextColor
						if animated then
							TweenService:Create(element, tweenInfo, {ImageColor3 = iconColor}):Play()
						else
							element.ImageColor3 = iconColor
						end
					end
				else
					-- Regular icons
					if animated then
						TweenService:Create(element, tweenInfo, {ImageColor3 = theme.TextColor}):Play()
					else
						element.ImageColor3 = theme.TextColor
					end
				end
			-- Shadow images
			elseif elementName == "Shadow" or parentName == "Shadow" then
				if animated then
					TweenService:Create(element, tweenInfo, {ImageColor3 = theme.Shadow}):Play()
				else
					element.ImageColor3 = theme.Shadow
				end
			end
		
		-- === IMAGE BUTTONS ===
		elseif elementClass == "ImageButton" then
			if animated then
				TweenService:Create(element, tweenInfo, {ImageColor3 = theme.TextColor}):Play()
			else
				element.ImageColor3 = theme.TextColor
			end
		
		-- === UI STROKES ===
		elseif elementClass == "UIStroke" then
			local parentName = element.Parent and element.Parent.Name or ""
			local grandParentName = element.Parent and element.Parent.Parent and element.Parent.Parent.Name or ""
			
			local strokeColor = theme.ElementStroke
			
			-- Tab strokes
			if grandParentName == "TabList" or grandParentName == "TabContainer" then
				strokeColor = theme.TabStroke
			-- Input strokes
			elseif parentName:match("Input") then
				strokeColor = theme.InputStroke or theme.ElementStroke
			elseif elementName == "NeonStroke" then
				strokeColor = theme.ToggleEnabled or theme.TabBackgroundSelected
			-- Knob stroke
			elseif parentName == "Knob" then
				strokeColor = theme.TextColor
			-- JokeContainer stroke
			elseif parentName == "JokeContainer" then
				strokeColor = theme.ToggleEnabledStroke or theme.ToggleEnabled
			-- CreditsContainer stroke
			elseif parentName == "CreditsContainer" then
				strokeColor = theme.ToggleEnabledStroke or theme.ToggleEnabled
			end
			
			if animated then
				TweenService:Create(element, tweenInfo, {Color = strokeColor}):Play()
			else
				element.Color = strokeColor
			end
		
		-- === UI GRADIENTS ===
		elseif elementClass == "UIGradient" then
			local parentName = element.Parent and element.Parent.Name or ""
			
			-- Update gradient colors based on parent
			if parentName == "JokeContainer" or parentName == "CreditsContainer" or parentName == "Paragraph" then
				local accentColor = theme.TabBackgroundSelected or theme.ToggleEnabled
				local bgColor = theme.ElementBackground
				element.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, accentColor),
					ColorSequenceKeypoint.new(0.5, bgColor),
					ColorSequenceKeypoint.new(1, accentColor)
				})
			elseif parentName == "SectionLine" then
				local accent = theme.TabBackgroundSelected or theme.ToggleEnabled
				element.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),
					ColorSequenceKeypoint.new(0.3, accent),
					ColorSequenceKeypoint.new(0.7, accent),
					ColorSequenceKeypoint.new(1, Color3.new(0.3, 0.3, 0.3))
				})
			end
		end
	end)
	
	-- Recursively apply to children
	for _, child in ipairs(element:GetChildren()) do
		ApplyThemeToElement(child, theme, animated, currentTabPage)
	end
end

local function ChangeTheme(Theme, NightUIInstance, animated)
	if animated == nil then animated = true end
	
	if typeof(Theme) == 'string' then
		if NightUILibrary.Theme[Theme] then
			SelectedTheme = NightUILibrary.Theme[Theme]
		else
			SelectedTheme = NightUILibrary.Theme.Default
		end
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end
	
	if not NightUIInstance then return end
	
	local Main = NightUIInstance:FindFirstChild('Main')
	if not Main then return end
	
	-- Get current tab page for proper tab coloring
	local Elements = Main:FindFirstChild('Elements')
	local currentTabPage = Elements and Elements:FindFirstChild('UIPageLayout') and Elements.UIPageLayout.CurrentPage
	
	-- ðŸ”¥ APPLY THEME RECURSIVELY TO ALL ELEMENTS ðŸ”¥
	ApplyThemeToElement(NightUIInstance, SelectedTheme, animated, currentTabPage)
	
	-- ðŸ”¥ SPECIAL HANDLING FOR SPECIFIC ELEMENTS ðŸ”¥
	local tweenInfo = animated and THEME_TWEEN_INFO or TweenInfo.new(0)
	
	-- Main background
	pcall(function()
		if animated then
			TweenService:Create(Main, tweenInfo, {BackgroundColor3 = SelectedTheme.Background}):Play()
		else
			Main.BackgroundColor3 = SelectedTheme.Background
		end
	end)
	
	-- Topbar
	pcall(function()
		local Topbar = Main:FindFirstChild('Topbar')
		if Topbar then
			if animated then
				TweenService:Create(Topbar, tweenInfo, {BackgroundColor3 = SelectedTheme.Topbar}):Play()
			else
				Topbar.BackgroundColor3 = SelectedTheme.Topbar
			end
			
			-- Title text
			if Topbar:FindFirstChild('Title') then
				if animated then
					TweenService:Create(Topbar.Title, tweenInfo, {TextColor3 = SelectedTheme.TextColor}):Play()
				else
					Topbar.Title.TextColor3 = SelectedTheme.TextColor
				end
			end
			
			-- Corner repair
			if Topbar:FindFirstChild('CornerRepair') then
				if animated then
					TweenService:Create(Topbar.CornerRepair, tweenInfo, {BackgroundColor3 = SelectedTheme.Topbar}):Play()
				else
					Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
				end
			end
			
			-- Divider
			if Topbar:FindFirstChild('Divider') then
				if animated then
					TweenService:Create(Topbar.Divider, tweenInfo, {BackgroundColor3 = SelectedTheme.ElementStroke}):Play()
				else
					Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
				end
			end
		end
	end)
	
	-- TabList background
	pcall(function()
		local TabList = Main:FindFirstChild('TabList')
		if TabList then
			if animated then
				TweenService:Create(TabList, tweenInfo, {BackgroundColor3 = SelectedTheme.Background}):Play()
			else
				TabList.BackgroundColor3 = SelectedTheme.Background
			end
			
			-- Update all tab buttons
			local tabContainer = TabList:FindFirstChild('TabContainer') or TabList
			for _, tabBtn in ipairs(tabContainer:GetChildren()) do
				if tabBtn:IsA('Frame') and tabBtn.Name ~= 'Template' and tabBtn.Name ~= 'Placeholder' and tabBtn.Name ~= 'AvatarRow' then
					local isSelected = currentTabPage and tabBtn.Name == currentTabPage.Name
					local bgColor = isSelected and SelectedTheme.TabBackgroundSelected or SelectedTheme.TabBackground
					local textColor = isSelected and SelectedTheme.SelectedTabTextColor or SelectedTheme.TabTextColor
					local bgTransparency = isSelected and 0 or 0.7
					
					if animated then
						TweenService:Create(tabBtn, tweenInfo, {BackgroundColor3 = bgColor, BackgroundTransparency = bgTransparency}):Play()
					else
						tabBtn.BackgroundColor3 = bgColor
						tabBtn.BackgroundTransparency = bgTransparency
					end
					
					if tabBtn:FindFirstChild('Title') then
						if animated then
							TweenService:Create(tabBtn.Title, tweenInfo, {TextColor3 = textColor}):Play()
						else
							tabBtn.Title.TextColor3 = textColor
						end
					end
					
					if tabBtn:FindFirstChild('Image') then
						if animated then
							TweenService:Create(tabBtn.Image, tweenInfo, {ImageColor3 = textColor}):Play()
						else
							tabBtn.Image.ImageColor3 = textColor
						end
					end
					
					if tabBtn:FindFirstChild('UIStroke') then
						if animated then
							TweenService:Create(tabBtn.UIStroke, tweenInfo, {Color = SelectedTheme.TabStroke}):Play()
						else
							tabBtn.UIStroke.Color = SelectedTheme.TabStroke
						end
					end
				end
			end
			
			-- Avatar stroke
			local avatarRow = TabList:FindFirstChild('AvatarRow')
			if avatarRow then
				local avatar = avatarRow:FindFirstChild('Avatar')
				if avatar then
					local avatarStroke = avatar:FindFirstChildOfClass('UIStroke')
					if avatarStroke and animated then
						TweenService:Create(avatarStroke, tweenInfo, {Color = SelectedTheme.TabBackgroundSelected}):Play()
					elseif avatarStroke then
						avatarStroke.Color = SelectedTheme.TabBackgroundSelected
					end
				end
				local neonContainer = avatarRow:FindFirstChild('NeonRingContainer')
				if neonContainer then
					local neonRing = neonContainer:FindFirstChild('NeonRing')
					if neonRing then
						local neonStroke = neonRing:FindFirstChild('NeonStroke')
						if neonStroke then
							neonStroke.Color = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected
						end
					end
				end
				
				-- Username
				local username = avatarRow:FindFirstChild('Username')
				if username and animated then
					TweenService:Create(username, tweenInfo, {TextColor3 = SelectedTheme.TextColor}):Play()
				elseif username then
					username.TextColor3 = SelectedTheme.TextColor
				end
			end
		end
	end)
	
	-- Elements container
	pcall(function()
		if Elements then
			if animated then
				TweenService:Create(Elements, tweenInfo, {BackgroundColor3 = SelectedTheme.Background}):Play()
			else
				Elements.BackgroundColor3 = SelectedTheme.Background
			end
		end
	end)
	
	-- ðŸ”¥ UPDATE ANIMATED BACKGROUNDS ðŸ”¥
	pcall(function()
		local animBg = Main:FindFirstChild("AnimatedBackgrounds")
		if animBg then
			local particleContainer = animBg:FindFirstChild("ParticleBackground")
			if particleContainer then
				local newColor = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
				for _, particle in ipairs(particleContainer:GetChildren()) do
					if particle:IsA("Frame") and particle.Name:match("^Particle") then
						if animated then
							TweenService:Create(particle, tweenInfo, {BackgroundColor3 = newColor}):Play()
						else
							particle.BackgroundColor3 = newColor
						end
					end
				end
			end
			
			local gradientOverlay = animBg:FindFirstChild("GradientOverlay")
			if gradientOverlay then
				local accentColor = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected
				if animated then
					TweenService:Create(gradientOverlay, tweenInfo, {BackgroundColor3 = accentColor}):Play()
				else
					gradientOverlay.BackgroundColor3 = accentColor
				end
			end
		end
	end)
	
	-- ðŸ”¥ UPDATE SEARCH CONTAINER ðŸ”¥
	pcall(function()
		local Topbar = Main:FindFirstChild('Topbar')
		if Topbar then
			local searchContainer = Topbar:FindFirstChild('SearchContainer')
			if searchContainer then
				if animated then
					TweenService:Create(searchContainer, tweenInfo, {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				else
					searchContainer.BackgroundColor3 = SelectedTheme.ElementBackground
				end
				
				local searchStroke = searchContainer:FindFirstChildOfClass('UIStroke')
				if searchStroke and animated then
					TweenService:Create(searchStroke, tweenInfo, {Color = SelectedTheme.ElementStroke}):Play()
				elseif searchStroke then
					searchStroke.Color = SelectedTheme.ElementStroke
				end
			end
		end
	end)
	
	print('[VeloxLabs] Theme applied successfully!')
end

-- ðŸ”¥ EXPOSE THEME FUNCTIONS TO LIBRARY ðŸ”¥
-- NOTE: Main NightUILibrary:ChangeTheme is defined later in the file (around line 10076)
-- This section only exposes helper functions

NightUILibrary.GetCurrentTheme = function()
	return SelectedTheme
end

NightUILibrary.GetThemeNames = function()
	local names = {}
	for name, _ in pairs(NightUILibrary.Theme) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

-- ðŸŽ¨ ADD CUSTOM THEME - Register a new theme
-- Usage: NightUI:AddTheme("MyTheme", {Background = Color3.fromRGB(...), ...})
function NightUILibrary:AddTheme(themeName, themeData)
	if type(themeName) ~= "string" or type(themeData) ~= "table" then
		warn("[VeloxLabs] AddTheme requires a string name and table of theme colors")
		return false
	end
	
	-- Merge with Default theme to fill in any missing values
	local newTheme = {}
	for key, value in pairs(NightUILibrary.Theme.Default) do
		newTheme[key] = themeData[key] or value
	end
	
	-- Add any extra properties from the custom theme
	for key, value in pairs(themeData) do
		newTheme[key] = value
	end
	
	NightUILibrary.Theme[themeName] = newTheme
	print("[VeloxLabs] Custom theme registered:", themeName)
	return true
end

local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error(`Lucide Icons: Failed to find icon by the name of "{name}"`, 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end
-- Converts ID to asset URI. Returns rbxassetid://0 if ID is not a number
local function getAssetUri(id: any): string
	local assetUri = "rbxassetid://0" -- Default to empty image
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn('VeloxLabs | Cannot use Lucide icons as icons library is not loaded')
	else
		warn('VeloxLabs | The icon argument must either be an icon ID (number) or a Lucide icon name (string)')
	end
	return assetUri
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true

			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false

			connectFunctions()

			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
				TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end


local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed

	if not success then warn('VeloxLabs had an issue decoding the configuration file, please try delete the file and reopen VeloxLabs.') return end

	-- Iterate through current UI elements' flags
	for FlagName, Flag in pairs(NightUILibrary.Flags) do
		local FlagValue = Data[FlagName]

		if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
			task.spawn(function()
				if Flag.Type == "ColorPicker" then
					changed = true
					Flag:Set(UnpackColor(FlagValue))
				else
					if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then 
						changed = true
						Flag:Set(FlagValue) 	
					end
				end
			end)
		else
			warn("VeloxLabs | Unable to find '"..FlagName.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
			--NightUILibrary:Notify({Title = "NightUI Flags", Content = "NightUI was unable to find '"..FlagName.. "' in the save file. Check sirius.menu/discord for help.", Image = 3944688398})
		end
	end

	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	if debugX then
		print('Saving')
	end

	local Data = {}
	for i, v in pairs(NightUILibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			if typeof(v.CurrentValue) == 'boolean' then
				if v.CurrentValue == false then
					Data[i] = false
				else
					Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
				end
			else
				Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
			end
		end
	end

	if useStudio then
		if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = script.Parent
		ScreenGui.Name = 'configuration'

		local TextBox = Instance.new("TextBox")
		TextBox.Parent = ScreenGui
		TextBox.Size = UDim2.new(0, 800, 0, 50)
		TextBox.AnchorPoint = Vector2.new(0.5, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0, 30)
		TextBox.Text = HttpService:JSONEncode(Data)
		TextBox.ClearTextOnFocus = false
	end

	if debugX then
		warn(HttpService:JSONEncode(Data))
	end

	if writefile then
		writefile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
	end
end

-- ðŸ”¥ SCREEN NOTIFICATION - BOTTOM RIGHT CORNER ðŸ”¥
function NightUILibrary:ScreenNotify(data)
	task.spawn(function()
		local success, err = pcall(function()
		-- Create notification container if it doesn't exist
		local parent = (gethui and gethui()) or CoreGui
		local screenNotifs = parent:FindFirstChild("VeloxLabs_ScreenNotifications")
		
		if not screenNotifs then
			screenNotifs = Instance.new("ScreenGui")
			screenNotifs.Name = "VeloxLabs_ScreenNotifications"
			screenNotifs.ResetOnSpawn = false
			screenNotifs.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenNotifs.Parent = parent
			
			local container = Instance.new("Frame")
			container.Name = "Container"
			container.Parent = screenNotifs
			container.AnchorPoint = Vector2.new(1, 1)
			container.Position = UDim2.new(1, -20, 1, -20)
			container.Size = UDim2.new(0, 320, 0, 400)
			container.BackgroundTransparency = 1
			
			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Vertical
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			layout.Padding = UDim.new(0, 8)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = container
		end
		
		local container = screenNotifs.Container
		local themeBackground = (SelectedTheme and SelectedTheme.NotificationBackground) or Color3.fromRGB(20, 18, 35)
		local themeStroke = (SelectedTheme and SelectedTheme.ElementStroke) or Color3.fromRGB(100, 80, 180)
		local themeText = (SelectedTheme and SelectedTheme.TextColor) or Color3.fromRGB(240, 240, 240)
		
		local notif = Instance.new("Frame")
		notif.Name = data.Title or "Notification"
		notif.Parent = container
		notif.Size = UDim2.new(1, 0, 0, 70)
		notif.BackgroundColor3 = themeBackground
		notif.BackgroundTransparency = 0.1
		notif.BorderSizePixel = 0
		notif.LayoutOrder = tick()
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = notif
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = themeStroke
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.Parent = notif
		
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Parent = notif
		title.Position = UDim2.new(0, 12, 0, 8)
		title.Size = UDim2.new(1, -24, 0, 20)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.Text = data.Title or "Notification"
		title.TextColor3 = themeText
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		
		local content = Instance.new("TextLabel")
		content.Name = "Content"
		content.Parent = notif
		content.Position = UDim2.new(0, 12, 0, 30)
		content.Size = UDim2.new(1, -24, 0, 35)
		content.BackgroundTransparency = 1
		content.Font = Enum.Font.Gotham
		content.Text = data.Content or ""
		content.TextColor3 = themeText
		content.TextSize = 12
		content.TextWrapped = true
		content.TextXAlignment = Enum.TextXAlignment.Left
		content.TextYAlignment = Enum.TextYAlignment.Top
		notif.Position = UDim2.new(1, 80, 0, 0)
		notif.BackgroundTransparency = 1
		stroke.Transparency = 1
		title.TextTransparency = 1
		content.TextTransparency = 1
		
		-- Slide in with spring effect
		TweenService:Create(notif, AnimationLib.Presets.NotifyIn, {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.05
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(stroke, AnimationLib.Presets.Smooth, {Transparency = 0.3}):Play()
			TweenService:Create(title, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
			TweenService:Create(content, AnimationLib.Presets.Smooth, {TextTransparency = 0.15}):Play()
		end)
		
		-- Auto dismiss
		local duration = data.Duration or 5
		task.wait(duration)
		
		-- ðŸ”¥ SMOOTH SLIDE-OUT ANIMATION
		TweenService:Create(notif, AnimationLib.Presets.NotifyOut, {
			Position = UDim2.new(1, 80, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(stroke, AnimationLib.Presets.NotifyOut, {Transparency = 1}):Play()
		TweenService:Create(title, AnimationLib.Presets.NotifyOut, {TextTransparency = 1}):Play()
		TweenService:Create(content, AnimationLib.Presets.NotifyOut, {TextTransparency = 1}):Play()
		
		task.wait(0.3)
		notif:Destroy()
		end) -- end pcall
		
		if not success then
			warn("[VeloxLabs] ScreenNotify error: " .. tostring(err))
		end
	end)
end

-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local NotificationQueue = {
	queue = {},
	isProcessing = false,
	maxVisible = 3,
	currentVisible = 0
}

-- Notification types with icons and colors
NotificationQueue.Types = {
	info = { icon = "â„¹ï¸", color = Color3.fromRGB(80, 150, 220) },
	success = { icon = "âœ…", color = Color3.fromRGB(80, 200, 120) },
	warning = { icon = "âš ï¸", color = Color3.fromRGB(220, 180, 60) },
	error = { icon = "âŒ", color = Color3.fromRGB(220, 80, 80) },
	default = { icon = "ðŸ””", color = Color3.fromRGB(140, 100, 255) }
}

function NotificationQueue:Add(data)
	table.insert(self.queue, data)
	self:ProcessQueue()
end

function NotificationQueue:ProcessQueue()
	if self.isProcessing or #self.queue == 0 then return end
	if self.currentVisible >= self.maxVisible then return end
	
	self.isProcessing = true
	local data = table.remove(self.queue, 1)
	self.currentVisible = self.currentVisible + 1
	
	-- Show notification
	task.spawn(function()
		NightUILibrary:ShowNotification(data)
		self.currentVisible = self.currentVisible - 1
		self.isProcessing = false
		self:ProcessQueue()
	end)
end

-- Toast notification (slide from bottom)
function NightUILibrary:Toast(message, duration, notifType)
	notifType = notifType or "default"
	local typeData = NotificationQueue.Types[notifType] or NotificationQueue.Types.default
	
	NotificationQueue:Add({
		Title = typeData.icon .. " " .. (notifType:gsub("^%l", string.upper)),
		Content = message,
		Duration = duration or 3,
		Type = notifType,
		Style = "toast"
	})
end

-- Quick notifications
function NightUILibrary:Success(message, duration)
	self:Toast(message, duration, "success")
end

function NightUILibrary:Warning(message, duration)
	self:Toast(message, duration, "warning")
end

function NightUILibrary:Error(message, duration)
	self:Toast(message, duration, "error")
end

function NightUILibrary:Info(message, duration)
	self:Toast(message, duration, "info")
end

-- Internal show notification (called by queue)
function NightUILibrary:ShowNotification(data)
	-- Use existing Notify logic
	self:Notify(data)
end

-- ðŸ·ï¸ WATERMARK - Small, non-intrusive credit display
-- Usage: NightUI:SetWatermark({Enabled = true, Text = "Powered by NightUI", Position = "BottomRight"})
function NightUILibrary:SetWatermark(options)
	options = options or {}
	
	local parent = (gethui and gethui()) or CoreGui
	local existingWatermark = parent:FindFirstChild("NightUI_Watermark")
	
	-- Remove existing watermark if disabled
	if not options.Enabled then
		if existingWatermark then existingWatermark:Destroy() end
		return
	end
	
	-- Create or update watermark
	local watermarkGui = existingWatermark or Instance.new("ScreenGui")
	watermarkGui.Name = "NightUI_Watermark"
	watermarkGui.ResetOnSpawn = false
	watermarkGui.IgnoreGuiInset = true
	watermarkGui.DisplayOrder = 999
	watermarkGui.Parent = parent
	
	local watermarkLabel = watermarkGui:FindFirstChild("Label") or Instance.new("TextLabel")
	watermarkLabel.Name = "Label"
	watermarkLabel.Parent = watermarkGui
	watermarkLabel.Text = options.Text or "NightUI"
	watermarkLabel.Font = Enum.Font.GothamMedium
	watermarkLabel.TextSize = 12
	watermarkLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	watermarkLabel.TextTransparency = 0.5
	watermarkLabel.BackgroundTransparency = 1
	watermarkLabel.Size = UDim2.new(0, 150, 0, 20)
	
	-- Position based on option
	local pos = options.Position or "BottomRight"
	if pos == "TopLeft" then
		watermarkLabel.AnchorPoint = Vector2.new(0, 0)
		watermarkLabel.Position = UDim2.new(0, 10, 0, 10)
		watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
	elseif pos == "TopRight" then
		watermarkLabel.AnchorPoint = Vector2.new(1, 0)
		watermarkLabel.Position = UDim2.new(1, -10, 0, 10)
		watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
	elseif pos == "BottomLeft" then
		watermarkLabel.AnchorPoint = Vector2.new(0, 1)
		watermarkLabel.Position = UDim2.new(0, 10, 1, -10)
		watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
	else -- BottomRight (default)
		watermarkLabel.AnchorPoint = Vector2.new(1, 1)
		watermarkLabel.Position = UDim2.new(1, -10, 1, -10)
		watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
	end
end

-- Remove watermark
function NightUILibrary:RemoveWatermark()
	local parent = (gethui and gethui()) or CoreGui
	local watermark = parent:FindFirstChild("NightUI_Watermark")
	if watermark then watermark:Destroy() end
end

function NightUILibrary:Notify(data) -- action e.g open messages
	-- Always use ScreenNotify for reliability - it creates its own container
	task.spawn(function()
		local success, err = pcall(function()
			NightUILibrary:ScreenNotify(data)
		end)
		
		if not success then
			warn("[VeloxLabs] Notification error: " .. tostring(err))
			-- Ultimate fallback - just print
			print("[VeloxLabs Notification] " .. (data.Title or "Notice") .. ": " .. (data.Content or ""))
		end
	end)
end

-- Legacy Notify function that tries to use in-window notifications
function NightUILibrary:NotifyInWindow(data)
	task.spawn(function()
		local Notifications = nil
		local guiParent = (gethui and gethui()) or CoreGui
		
		for _, gui in ipairs(guiParent:GetChildren()) do
			if gui.Name and gui.Name:match("VeloxLabs") and gui:FindFirstChild('Notifications') then
				Notifications = gui.Notifications
				break
			end
		end
		
		if not Notifications or not Notifications:FindFirstChild('Template') then
			-- Fallback to screen notification
			NightUILibrary:ScreenNotify(data)
			return
		end

		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		-- Set Data
		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			if typeof(data.Image) == 'string' and Icons then
				local asset = getIcon(data.Image)

				newNotification.Icon.Image = 'rbxassetid://'..asset.id
				newNotification.Icon.ImageRectOffset = asset.imageRectOffset
				newNotification.Icon.ImageRectSize = asset.imageRectSize
			else
				newNotification.Icon.Image = getAssetUri(data.Image)
			end
		else
			newNotification.Icon.Image = "rbxassetid://" .. 0
		end

		-- Set initial transparency values

		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.Background
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Size = UDim2.new(1, 0, 0, 800)
		newNotification.Icon.ImageTransparency = 1
		newNotification.Icon.BackgroundTransparency = 1

		task.wait()

		newNotification.Visible = true

		if data.Actions then
			warn('VeloxLabs | Not seeing your actions in notifications?')
			print("Notification Actions are being sunset for now. - VeloxLabs")
		end

		-- Calculate textbounds and set initial values
		local bounds = {newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y}
		newNotification.Size = UDim2.new(1, -60, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)

		newNotification.Icon.Size = UDim2.new(0, 32, 0, 32)
		newNotification.Icon.Position = UDim2.new(0, 20, 0.5, 0)

		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, math.max(bounds[1] + bounds[2] + 31, 60))}):Play()

		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

		task.wait(0.05)

		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()

		task.wait(0.05)
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()

		local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
		task.wait(data.Duration or waitDuration)

		newNotification.Icon.Visible = false
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()

		task.wait(1)

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)}):Play()

		newNotification.Visible = false
		newNotification:Destroy()
	end)
end
-- These placeholder functions will be overwritten with window-specific versions
local openSearch = function() end
local closeSearch = function() end

local function Hide(notify: boolean?)
	if MPrompt then
		MPrompt.Title.TextColor3 = SelectedTheme and SelectedTheme.TextColor or Color3.fromRGB(255, 255, 255)
		MPrompt.Position = UDim2.new(0.5, 0, 0, -50)
		MPrompt.Size = UDim2.new(0, 40, 0, 10)
		MPrompt.BackgroundTransparency = 1
		MPrompt.Title.TextTransparency = 1
		MPrompt.Visible = true
	end

	task.spawn(closeSearch)

	Debounce = true
	if not Main then 
		Debounce = false
		return 
	end
	
	if notify then
		if useMobilePrompt then 
			NightUILibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping 'Show'.", Duration = 7, Image = 4400697855})
		else
			NightUILibrary:Notify({Title = "VeloxLabs Hidden", Content = `Press {getSetting("General", "nightuiOpen")} to show the interface again.`, Duration = 7, Image = 4400697855})
		end
	end

	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 0)}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 45)}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	if Main.Topbar:FindFirstChild('Title') then
		TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	end
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

	if useMobilePrompt and MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3}):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
	end

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			TweenService:Create(TopbarButton, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		end
	end

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	dragInteract.Visible = false

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
						else
							TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = false
							end
						end
					end
				end
			end
		end
	end

	task.wait(0.5)
	Main.Visible = false
	Debounce = false
end
local function Maximise()
	Debounce = true
	Topbar.ChangeSize.Image = "rbxassetid://"..10137941941

	-- Smooth window expand
	TweenService:Create(Topbar.UIStroke, AnimationLib.Presets.PanelOpen, {Transparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, AnimationLib.Presets.PanelOpen, {ImageTransparency = 0.6}):Play()
	TweenService:Create(Topbar.CornerRepair, AnimationLib.Presets.PanelOpen, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Topbar.Divider, AnimationLib.Presets.PanelOpen, {BackgroundTransparency = 0}):Play()
	TweenService:Create(dragBarCosmetic, AnimationLib.Presets.Spring, {BackgroundTransparency = 0.7}):Play()
	TweenService:Create(Main, AnimationLib.Presets.PanelOpen, {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Topbar, AnimationLib.Presets.PanelOpen, {Size = UDim2.new(0, 500, 0, 45)}):Play()
	
	TabList.Visible = true
	task.wait(0.15)
	Elements.Visible = true

	-- Staggered element fade-in
	local elementIndex = 0
	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						elementIndex = elementIndex + 1
						task.delay(elementIndex * AnimationLib.Stagger.Fast, function()
							if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
								TweenService:Create(element.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0.4}):Play()
							elseif element.Name == 'Divider' then
								TweenService:Create(element.Divider, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0.85}):Play()
							else
								TweenService:Create(element, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0.3}):Play()
								if element:FindFirstChild("UIStroke") then
									TweenService:Create(element.UIStroke, AnimationLib.Presets.Smooth, {Transparency = 0}):Play()
								end
								if element:FindFirstChild("Title") then
									TweenService:Create(element.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
								end
							end
							for _, child in ipairs(element:GetChildren()) do
								if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
									child.Visible = true
								end
							end
						end)
					end
				end
			end
		end
	end

	task.wait(0.1)

	-- Staggered tab fade-in
	local tabIndex = 0
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabIndex = tabIndex + 1
			task.delay(tabIndex * AnimationLib.Stagger.Normal, function()
				if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
					TweenService:Create(tabbtn, AnimationLib.Presets.TabSlide, {BackgroundTransparency = 0}):Play()
					TweenService:Create(tabbtn.Image, AnimationLib.Presets.TabSlide, {ImageTransparency = 0}):Play()
					TweenService:Create(tabbtn.Title, AnimationLib.Presets.TabSlide, {TextTransparency = 0}):Play()
					TweenService:Create(tabbtn.UIStroke, AnimationLib.Presets.TabSlide, {Transparency = 1}):Play()
				else
					TweenService:Create(tabbtn, AnimationLib.Presets.TabSlide, {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(tabbtn.Image, AnimationLib.Presets.TabSlide, {ImageTransparency = 0.2}):Play()
					TweenService:Create(tabbtn.Title, AnimationLib.Presets.TabSlide, {TextTransparency = 0.2}):Play()
					TweenService:Create(tabbtn.UIStroke, AnimationLib.Presets.TabSlide, {Transparency = 0.5}):Play()
				end
			end)
		end
	end

	task.wait(0.4)
	Debounce = false
end
local function Unhide()
	Debounce = true
	if not Main then 
		Debounce = false
		return 
	end
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Visible = true
	
	-- Smooth window appear
	TweenService:Create(Main, AnimationLib.Presets.PanelOpen, {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Main.Topbar, AnimationLib.Presets.PanelOpen, {Size = UDim2.new(0, 500, 0, 45)}):Play()
	TweenService:Create(Main.Shadow.Image, AnimationLib.Presets.Smooth, {ImageTransparency = 0.6}):Play()
	TweenService:Create(Main, AnimationLib.Presets.PanelOpen, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar, AnimationLib.Presets.PanelOpen, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.Divider, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0}):Play()
	
	if Main.Topbar:FindFirstChild('Title') then
		TweenService:Create(Main.Topbar.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
	end

	if MPrompt then
		TweenService:Create(MPrompt, AnimationLib.Presets.PanelClose, {Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}):Play()
		TweenService:Create(MPrompt.Title, AnimationLib.Presets.PanelClose, {TextTransparency = 1}):Play()
		task.spawn(function()
			task.wait(0.4)
			MPrompt.Visible = false
		end)
	end

	if Minimised then
		task.spawn(Maximise)
	end

	dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset)
	dragInteract.Visible = true

	-- Staggered topbar button fade-in
	local btnIndex = 0
	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			btnIndex = btnIndex + 1
			task.delay(btnIndex * 0.05, function()
				if TopbarButton.Name == 'Icon' then
					TweenService:Create(TopbarButton, AnimationLib.Presets.Smooth, {ImageTransparency = 0}):Play()
				else
					TweenService:Create(TopbarButton, AnimationLib.Presets.Smooth, {ImageTransparency = 0.8}):Play()
				end
			end)
		end
	end

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0.4}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0.85}):Play()
						else
							-- ðŸ”¥ FIX: Use 0.3 transparency for elements, not 0!
							TweenService:Create(element, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0.3}):Play()
							if element:FindFirstChild("UIStroke") then
								TweenService:Create(element.UIStroke, AnimationLib.Presets.Smooth, {Transparency = 0}):Play()
							end
							if element:FindFirstChild("Title") then
								TweenService:Create(element.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
							end
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = true
							end
						end
					end
				end
			end
		end
	end

	TweenService:Create(dragBarCosmetic, AnimationLib.Presets.Spring, {BackgroundTransparency = 0.5}):Play()

	task.wait(0.4)
	Minimised = false
	Debounce = false
end
local function Minimise()
	Debounce = true
	Topbar.ChangeSize.Image = "rbxassetid://"..11036884234
	Topbar.UIStroke.Color = SelectedTheme.ElementStroke

	task.spawn(closeSearch)

	-- Fade out tabs with stagger
	local tabIndex = 0
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabIndex = tabIndex + 1
			task.delay(tabIndex * 0.02, function()
				TweenService:Create(tabbtn, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
				TweenService:Create(tabbtn.Image, AnimationLib.Presets.PanelClose, {ImageTransparency = 1}):Play()
				TweenService:Create(tabbtn.Title, AnimationLib.Presets.PanelClose, {TextTransparency = 1}):Play()
				TweenService:Create(tabbtn.UIStroke, AnimationLib.Presets.PanelClose, {Transparency = 1}):Play()
			end)
		end
	end

	-- Fade out elements
	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, AnimationLib.Presets.PanelClose, {TextTransparency = 1}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
						else
							TweenService:Create(element, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
							if element:FindFirstChild("UIStroke") then
								TweenService:Create(element.UIStroke, AnimationLib.Presets.PanelClose, {Transparency = 1}):Play()
							end
							if element:FindFirstChild("Title") then
								TweenService:Create(element.Title, AnimationLib.Presets.PanelClose, {TextTransparency = 1}):Play()
							end
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = false
							end
						end
					end
				end
			end
		end
	end

	-- Smooth window collapse
	TweenService:Create(dragBarCosmetic, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, AnimationLib.Presets.Smooth, {Transparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, AnimationLib.Presets.PanelClose, {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.CornerRepair, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.Divider, AnimationLib.Presets.PanelClose, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main, AnimationLib.Presets.PanelClose, {Size = UDim2.new(0, 495, 0, 45)}):Play()
	TweenService:Create(Topbar, AnimationLib.Presets.PanelClose, {Size = UDim2.new(0, 495, 0, 45)}):Play()

	task.wait(0.25)
	Elements.Visible = false
	TabList.Visible = false
	task.wait(0.1)
	Debounce = false
end

local function saveSettings() -- Save settings to config file
	local encoded
	local success, err = pcall(function()
		encoded = HttpService:JSONEncode(settingsTable)
	end)

	if success then
		if useStudio then
			if script.Parent['get.val'] then
				script.Parent['get.val'].Value = encoded
			end
		end
		if writefile then
			writefile(NightUIFolder..'/settings'..ConfigurationExtension, encoded)
		end
	end
end

local function updateSetting(category: string, setting: string, value: any)
	if not settingsInitialized then
		return
	end
	settingsTable[category][setting].Value = value
	overriddenSettings[`{category}.{setting}`] = nil -- If user changes an overriden setting, remove the override
	saveSettings()
end
local function createSettings(window, windowTopbar, windowTabList, windowElements)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
		if windowTopbar and windowTopbar:FindFirstChild('Settings') then 
			windowTopbar.Settings.Visible = false 
		end
		if windowTopbar and windowTopbar:FindFirstChild('Search') then
			windowTopbar.Search.Position = UDim2.new(1, -75, 0.5, 0)
		end
		warn('Can\'t create settings as no file-saving functionality is available.')
		return
	end

	local newTab = window:CreateTab('VeloxLabs Settings', 0, true)
	if windowTabList and windowTabList:FindFirstChild('VeloxLabs Settings') then
		windowTabList['VeloxLabs Settings'].LayoutOrder = 1000
	end

	if windowElements and windowElements:FindFirstChild('VeloxLabs Settings') then
		windowElements['VeloxLabs Settings'].LayoutOrder = 1000
	end

	-- Create sections and elements
	for categoryName, settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)

		for settingName, setting in pairs(settingCategory) do
			if setting.Type == 'input' then
				setting.Element = newTab:CreateInput({
					Name = setting.Name,
					CurrentValue = setting.Value,
					PlaceholderText = setting.Placeholder,
					Ext = true,
					RemoveTextAfterFocusLost = setting.ClearOnFocus,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'toggle' then
				setting.Element = newTab:CreateToggle({
					Name = setting.Name,
					CurrentValue = setting.Value,
					Ext = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'bind' then
				setting.Element = newTab:CreateKeybind({
					Name = setting.Name,
					CurrentKeybind = setting.Value,
					HoldToInteract = false,
					Ext = true,
					CallOnChange = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			end
		end
	end

	settingsCreated = true
	loadSettings()
	saveSettings()
end



function NightUILibrary:CreateWindow(Settings)
	print('[VeloxLabs] Creating window...')
	local parent = gethui and gethui() or CoreGui
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA('ScreenGui') and child.Name and child.Name:match("^VeloxLabs%-") then
			-- Check if this is an old window (not currently being created)
			if child:FindFirstChild('Main') and Settings.Name then
				local topbar = child.Main:FindFirstChild('Topbar')
				if topbar and topbar:FindFirstChild('Title') and topbar.Title.Text == Settings.Name then
					print('[VeloxLabs] Destroying old window with same name:', Settings.Name)
					child:Destroy()
				end
			end
		end
	end
	
	-- Reset the cached flag to allow loading animations again
	local toDestroy, NightUI
	local buildAttempts = 0
	repeat
		if useStudio then
			NightUI = script.Parent:FindFirstChild('NightUI')
		else
			NightUI = game:GetObjects("rbxassetid://10804731440")[1]
		end
		buildAttempts = buildAttempts + 1
	until NightUI or buildAttempts >= 2
	
	if not NightUI then
		warn('Failed to create window instance')
		return
	end
	
	NightUI.Enabled = false
	NightUI.Name = "VeloxLabs-"..tostring(math.random(100000,999999))
	NightUI.IgnoreGuiInset = true
	NightUI.ResetOnSpawn = false
	NightUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	if gethui then
		NightUI.Parent = gethui()
	elseif syn and syn.protect_gui then 
		syn.protect_gui(NightUI)
		NightUI.Parent = CoreGui
	elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
		NightUI.Parent = CoreGui:FindFirstChild("RobloxGui")
	elseif not useStudio then
		NightUI.Parent = CoreGui
	end
	
	-- ðŸ”¥ SET THEME EARLY - Before loading screen to prevent flashbang
	if Settings.Theme then
		if typeof(Settings.Theme) == 'string' and NightUILibrary.Theme[Settings.Theme] then
			SelectedTheme = NightUILibrary.Theme[Settings.Theme]
			print('[VeloxLabs] Theme set early:', Settings.Theme)
		end
	end
	
	-- Get window-specific references
	local Main = NightUI.Main
	local MPrompt = NightUI:FindFirstChild('Prompt')
	local Topbar = Main.Topbar
	local Elements = Main.Elements
	local LoadingFrame = Main.LoadingFrame
	local TabList = Main.TabList
	local dragBar = NightUI:FindFirstChild('Drag')
	local dragInteract = dragBar and dragBar.Interact or nil
	local dragBarCosmetic = dragBar and dragBar.Drag or nil
	
	-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
	-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
	
	-- Hide/Remove NightUI Logo in LoadingFrame
	if LoadingFrame then
		local logo = LoadingFrame:FindFirstChild('Logo')
		if logo then logo.Visible = false; logo:Destroy() end
		local nightuiLogo = LoadingFrame:FindFirstChild('NightUILogo')
		if nightuiLogo then nightuiLogo.Visible = false; nightuiLogo:Destroy() end
	end
	
	-- Remove ANY visible demo tabs/elements from TabList
	if TabList then
		for _, child in ipairs(TabList:GetChildren()) do
			if child.Name ~= 'Template' and child:IsA('GuiObject') then
				print('[VeloxLabs] Destroying demo tab:', child.Name)
				child:Destroy()
			end
		end
	end
	
	-- Remove ANY visible demo pages from Elements
	if Elements then
		for _, child in ipairs(Elements:GetChildren()) do
			if child.Name ~= 'Template' and child:IsA('ScrollingFrame') then
				print('[VeloxLabs] Destroying demo page:', child.Name)
				child:Destroy()
			end
		end
	end
	
	print('[VeloxLabs] Demo cleanup complete!')
	
	-- Modern layout with auto-positioning for multiple windows - NO OVERLAP
	if Main then
		Main.AnchorPoint = Vector2.new(0.5, 0.5)
		local windowCount = 0
		local parent = gethui and gethui() or CoreGui
		for _, child in ipairs(parent:GetChildren()) do
			if child.Name and child.Name:match("^VeloxLabs%-") and child ~= NightUI then
				windowCount = windowCount + 1
			end
		end
		
		-- ðŸ”¥ OFFSET WINDOWS - Cascade style (each window slightly offset)
		local offsetX = (windowCount % 3) * 50  -- Horizontal offset: 0, 50, 100, then repeat
		local offsetY = (windowCount % 3) * 40  -- Vertical offset: 0, 40, 80, then repeat
		Main.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
		
		print("[VeloxLabs] Window #"..tostring(windowCount + 1).." positioned with offset:", offsetX, offsetY)
		
		-- Better sizing: BIGGER window for better visibility
		Main.Size = UDim2.new(0, 800, 0, 600)  -- Larger to prevent cutoff
		Main.ClipsDescendants = true
		Main.Visible = true
		Main.BackgroundTransparency = 0
		Main.BorderSizePixel = 0
		Main.ZIndex = 1
		if Main:FindFirstChild('Shadow') then
			Main.Shadow.Visible = false
		end
		
		-- Add rounded corners if not present
		if not Main:FindFirstChildOfClass('UICorner') then
			local corner = Instance.new('UICorner')
			corner.CornerRadius = UDim.new(0, 10)
			corner.Parent = Main
		end
		
		-- ðŸ”¥ ANIMATED BACKGROUND EFFECTS ðŸ”¥
		-- Create a container for animated backgrounds (above any background image)
		local animBgContainer = Instance.new("Frame")
		animBgContainer.Name = "AnimatedBackgrounds"
		animBgContainer.Size = UDim2.new(1, 0, 1, 0)
		animBgContainer.Position = UDim2.new(0, 0, 0, 0)
		animBgContainer.BackgroundTransparency = 1
		animBgContainer.ClipsDescendants = true
		animBgContainer.ZIndex = 1  -- Above background image
		animBgContainer.Parent = Main
		
		local animCorner = Instance.new("UICorner")
		animCorner.CornerRadius = UDim.new(0, 10)
		animCorner.Parent = animBgContainer
		
		-- Add floating particles for premium look
		local particleColor = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled or Color3.fromRGB(100, 80, 200)
		local particles = AnimationLib.CreateParticleBackground(animBgContainer, particleColor, 15)
		if particles then
			particles.ZIndex = 1
		end
		
		-- Add subtle animated gradient overlay
		local accentColor = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)
		local gradientOverlay = Instance.new("Frame")
		gradientOverlay.Name = "GradientOverlay"
		gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
		gradientOverlay.BackgroundColor3 = accentColor
		gradientOverlay.BackgroundTransparency = 0.95
		gradientOverlay.BorderSizePixel = 0
		gradientOverlay.ZIndex = 0
		gradientOverlay.Parent = animBgContainer
		
		local overlayCorner = Instance.new("UICorner")
		overlayCorner.CornerRadius = UDim.new(0, 10)
		overlayCorner.Parent = gradientOverlay
		
		local overlayGradient = Instance.new("UIGradient")
		overlayGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accentColor),
			ColorSequenceKeypoint.new(0.5, SelectedTheme.Background or Color3.fromRGB(20, 15, 40)),
			ColorSequenceKeypoint.new(1, accentColor)
		})
		overlayGradient.Rotation = 45
		overlayGradient.Parent = gradientOverlay
		
		-- Animate gradient rotation
		task.spawn(function()
			while gradientOverlay.Parent do
				TweenService:Create(overlayGradient, TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Rotation = 135
				}):Play()
				task.wait(10)
				TweenService:Create(overlayGradient, TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Rotation = 45
				}):Play()
				task.wait(10)
				if not gradientOverlay.Parent then break end
			end
		end)
		
		print('[VeloxLabs] Animated backgrounds created!')
	end
	
	if Topbar then
		Topbar.BackgroundTransparency = 0
		Topbar.Size = UDim2.new(1, 0, 0, 45)  -- Slightly smaller topbar
		Topbar.Position = UDim2.new(0, 0, 0, 0)
		Topbar.BorderSizePixel = 0
		Topbar.Visible = true
		Topbar.ZIndex = 2
		-- Hide ALL topbar buttons for clean look
		if Topbar:FindFirstChild('Hide') then
			Topbar.Hide.Visible = false
		end
		if Topbar:FindFirstChild('Search') then
			Topbar.Search.Visible = false
		end
		if Topbar:FindFirstChild('Settings') then
			Topbar.Settings.Visible = false
		end
		if Topbar:FindFirstChild('ChangeSize') then
			Topbar.ChangeSize.Visible = false
		end
		if Topbar:FindFirstChild('Title') then
			-- Remove ALL children that might affect layout
			for _, child in ipairs(Topbar.Title:GetChildren()) do
				child:Destroy()
			end
			-- Center in the topbar using pixel offset from center
			Topbar.Title.AnchorPoint = Vector2.new(0.5, 0.5)
			Topbar.Title.Position = UDim2.new(0.5, 0, 0.5, 0)
			Topbar.Title.Size = UDim2.new(1, -100, 0, 20)  -- Full width minus side padding
			Topbar.Title.TextXAlignment = Enum.TextXAlignment.Center
			Topbar.Title.Font = Enum.Font.GothamMedium
			Topbar.Title.TextSize = 13
			Topbar.Title.TextTransparency = 0  -- Ensure visible
			Topbar.Title.TextScaled = false
			Topbar.Title.TextWrapped = false
			Topbar.Title.ZIndex = 10
		end
		
		-- Add subtle shadow to topbar
		if Topbar:FindFirstChild('Divider') then
			Topbar.Divider.BackgroundTransparency = 0.5
			Topbar.Divider.Size = UDim2.new(1, 0, 0, 1)
			Topbar.Divider.Position = UDim2.new(0, 0, 1, -1)
		end
	end
	if TabList then
		TabList.Visible = true
		TabList.AnchorPoint = Vector2.new(0, 0)
		TabList.Position = UDim2.new(0, 0, 0, 45)  -- Under topbar
		TabList.Size = UDim2.new(0, 200, 1, -45)
		TabList.BackgroundTransparency = 0
		TabList.BackgroundColor3 = SelectedTheme.Background
		TabList.BorderSizePixel = 0
		TabList.ClipsDescendants = true
		TabList.AutomaticSize = Enum.AutomaticSize.None
		
		-- ScrollingFrame settings if applicable
		if TabList:IsA("ScrollingFrame") then
			TabList.ScrollBarThickness = 2
			TabList.ScrollBarImageColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(100, 80, 180)
			TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
			TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
		end
		
		-- Remove old layout if exists
		for _, child in ipairs(TabList:GetChildren()) do
			if child:IsA('UIListLayout') or child:IsA('UIPadding') then
				child:Destroy()
			end
		end
		local avatarContainer = Instance.new("Frame")
		avatarContainer.Name = "AvatarRow"
		avatarContainer.Parent = TabList
		avatarContainer.AnchorPoint = Vector2.new(0.5, 0)
		avatarContainer.Position = UDim2.new(0.5, 0, 0, 5)  -- Fixed at top
		avatarContainer.Size = UDim2.new(1, -10, 0, 115)
		avatarContainer.ZIndex = 15  -- Above everything
		
		-- ðŸ”¥ TAB CONTAINER - Holds tabs with flexible layout ðŸ”¥
		local tabContainer = Instance.new("Frame")
		tabContainer.Name = "TabContainer"
		tabContainer.Parent = TabList
		tabContainer.AnchorPoint = Vector2.new(0, 0)
		tabContainer.Position = UDim2.new(0, 0, 0, 125)  -- Below avatar
		tabContainer.Size = UDim2.new(1, 0, 1, -130)  -- Fill remaining space
		tabContainer.BackgroundTransparency = 1
		tabContainer.ClipsDescendants = true
		tabContainer.ZIndex = 5
		
		-- Create UIListLayout for vertical tab alignment INSIDE tabContainer
		local tabLayout = Instance.new('UIListLayout')
		tabLayout.Name = 'TabLayout'
		tabLayout.FillDirection = Enum.FillDirection.Vertical
		tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 8)  -- More spacing between tabs
		tabLayout.Parent = tabContainer
		
		-- Add padding for tabs
		local tabPadding = Instance.new('UIPadding')
		tabPadding.PaddingTop = UDim.new(0, 5)
		tabPadding.PaddingBottom = UDim.new(0, 8)
		tabPadding.PaddingLeft = UDim.new(0, 5)
		tabPadding.PaddingRight = UDim.new(0, 5)
		tabPadding.Parent = tabContainer
		
		-- Store tabContainer reference for CreateTab (using child lookup instead of property)
		-- TabContainer is now a child of TabList, accessible via FindFirstChild
		local function updateWindowSize()
			local tabs = {}
			for _, child in ipairs(tabContainer:GetChildren()) do
				if child:IsA("Frame") and child.Name ~= "Template" and child.Name ~= "Placeholder" then
					table.insert(tabs, child)
				end
			end
			
			local tabCount = #tabs
			local tabHeight = 36
			local padding = 4
			local avatarHeight = 125
			local extraPadding = 20
			
			-- Calculate required height for all tabs
			local requiredTabSpace = (tabCount * tabHeight) + ((tabCount - 1) * padding) + extraPadding
			local totalSidebarHeight = avatarHeight + requiredTabSpace
			
			-- Window needs: topbar (45) + sidebar content + bottom margin
			local minWindowHeight = 450
			local maxWindowHeight = 700
			local optimalHeight = math.clamp(totalSidebarHeight + 60, minWindowHeight, maxWindowHeight)
			
			-- Animate window resize
			if Main then
				TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 750, 0, optimalHeight)
				}):Play()
			end
		end
		
		-- Update window size when tabs are added
		tabContainer.ChildAdded:Connect(function()
			task.delay(0.2, updateWindowSize)
		end)
		
		-- Avatar container styling - FULLY TRANSPARENT
		avatarContainer.BackgroundTransparency = 1  -- No background, shows sidebar
		avatarContainer.BorderSizePixel = 0
		avatarContainer.ZIndex = 10
		local neonRingContainer = Instance.new("Frame")
		neonRingContainer.Name = "NeonRingContainer"
		neonRingContainer.Parent = avatarContainer
		neonRingContainer.AnchorPoint = Vector2.new(0.5, 0)
		neonRingContainer.Position = UDim2.new(0.5, 0, 0, 7)
		neonRingContainer.Size = UDim2.new(0, 76, 0, 76)
		neonRingContainer.BackgroundTransparency = 1
		neonRingContainer.ZIndex = 10
		local neonRing = Instance.new("Frame")
		neonRing.Name = "NeonRing"
		neonRing.Parent = neonRingContainer
		neonRing.AnchorPoint = Vector2.new(0.5, 0.5)
		neonRing.Position = UDim2.new(0.5, 0, 0.5, 0)
		neonRing.Size = UDim2.new(1, 0, 1, 0)
		neonRing.BackgroundTransparency = 1
		neonRing.ZIndex = 10
		
		local ringCorner = Instance.new("UICorner")
		ringCorner.CornerRadius = UDim.new(1, 0)
		ringCorner.Parent = neonRing
		
		local ringStroke = Instance.new("UIStroke")
		ringStroke.Name = "NeonStroke"
		-- Use ToggleEnabled for consistent accent color across windows
		ringStroke.Color = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)
		ringStroke.Thickness = 3
		ringStroke.Transparency = 0.2
		ringStroke.Parent = neonRing
		
		-- Add gradient to make it look like rotating light
		local ringGradient = Instance.new("UIGradient")
		ringGradient.Name = "NeonGradient"
		ringGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.new(0.3, 0.3, 0.3)),
			ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
		ringGradient.Rotation = 0
		ringGradient.Parent = ringStroke
		
		-- Animate the gradient rotation for spinning neon effect
		task.spawn(function()
			while neonRingContainer.Parent do
				for i = 0, 360, 2 do
					if not neonRingContainer.Parent then break end
					ringGradient.Rotation = i
					-- Use ToggleEnabled for consistent accent color
					ringStroke.Color = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)
					task.wait(0.02)
				end
			end
		end)
		
		-- Listen for theme changes
		if Main then
			Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				local newColor = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)
				ringStroke.Color = newColor
			end)
		end
		
		local avatarImage = Instance.new("ImageLabel")
		avatarImage.Name = "Avatar"
		avatarImage.Parent = avatarContainer
		avatarImage.AnchorPoint = Vector2.new(0.5, 0)
		avatarImage.Position = UDim2.new(0.5, 0, 0, 10)
		avatarImage.Size = UDim2.new(0, 65, 0, 65)
		avatarImage.BackgroundTransparency = 1  -- No background at all
		avatarImage.BorderSizePixel = 0
		avatarImage.ImageTransparency = 1  -- Start hidden, fade in when loaded
		avatarImage.ZIndex = 11
		
		local avatarImageCorner = Instance.new("UICorner")
		avatarImageCorner.CornerRadius = UDim.new(1, 0)
		avatarImageCorner.Parent = avatarImage
		
		-- Subtle inner glow stroke on avatar
		local avatarImageStroke = Instance.new("UIStroke")
		avatarImageStroke.Color = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)
		avatarImageStroke.Thickness = 2
		avatarImageStroke.Transparency = 0.5
		avatarImageStroke.Parent = avatarImage
		
		-- Theme change listener for avatar stroke and background
		if Main then
			Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				avatarImageStroke.Color = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
				avatarImage.BackgroundColor3 = SelectedTheme.Background or Color3.fromRGB(25, 25, 25)
			end)
		end
		
		local usernameLabel = Instance.new("TextLabel")
		usernameLabel.Name = "Username"
		usernameLabel.Parent = avatarContainer
		usernameLabel.AnchorPoint = Vector2.new(0.5, 0)
		usernameLabel.Position = UDim2.new(0.5, 0, 0, 80)
		usernameLabel.Size = UDim2.new(1, -10, 0, 24)
		usernameLabel.BackgroundTransparency = 1
		usernameLabel.Font = Enum.Font.GothamBold
		usernameLabel.Text = Players.LocalPlayer and Players.LocalPlayer.Name or "Player"
		usernameLabel.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(200, 180, 255)
		usernameLabel.TextSize = 14
		usernameLabel.TextTransparency = 1
		usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		usernameLabel.ZIndex = 11
		
		-- Load avatar
		task.spawn(function()
			local player = Players.LocalPlayer
			if player then
				local success, content = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if success and content then
					avatarImage.Image = content
					task.delay(0.5, function()
						TweenService:Create(avatarImage, TweenInfo.new(0.5), {ImageTransparency = 0, BackgroundTransparency = 1}):Play()
						TweenService:Create(usernameLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
					end)
				end
			end
		end)
		
		print("[VeloxLabs] TabList with avatar configured")
	end
	
	if Elements then
		Elements.Position = UDim2.new(0, 200, 0, 45)  -- ðŸ”¥ Right after 200px sidebar
		Elements.Size = UDim2.new(1, -200, 1, -45)    -- ðŸ”¥ Full width minus 200px sidebar
		Elements.BackgroundTransparency = 0.95
		Elements.BackgroundColor3 = SelectedTheme.Background
		Elements.BorderSizePixel = 0
		Elements.ClipsDescendants = true
		Elements.Visible = true
		Elements.AnchorPoint = Vector2.new(0, 0)
		Elements.AutomaticSize = Enum.AutomaticSize.None
		if Elements:IsA("ScrollingFrame") then
			Elements.ScrollBarThickness = 0
			Elements.ScrollingEnabled = false
		end
		
		-- Add corner radius to Elements
		local elementsCorner = Elements:FindFirstChild('VeloxLabs_ElemCorner') or Instance.new('UICorner')
		elementsCorner.Name = 'VeloxLabs_ElemCorner'
		elementsCorner.CornerRadius = UDim.new(0, 8)
		elementsCorner.Parent = Elements
		for _, child in ipairs(Elements:GetChildren()) do
			if child.Name ~= 'Template' then
				if child:IsA('ScrollingFrame') or child:IsA('Frame') or child:IsA('TextLabel') then
					print('[VeloxLabs] Removing element page:', child.Name, child.ClassName)
					child:Destroy()
				end
			end
		end
		for _, child in ipairs(Elements:GetChildren()) do
			if child:IsA('UIPadding') then
				child:Destroy()
			end
		end
		
		-- Also fix the Elements.Template if it exists
		if Elements:FindFirstChild('Template') then
			local template = Elements.Template
			template.Position = UDim2.new(0, 0, 0, 0)
			template.Size = UDim2.new(1, 0, 1, 0)
			template.AnchorPoint = Vector2.new(0, 0)
			for _, child in ipairs(template:GetChildren()) do
				if child:IsA('UIPadding') or child:IsA('UIListLayout') then
					child:Destroy()
				end
			end
			
			-- Add fresh layout to template
			local templateLayout = Instance.new('UIListLayout')
			templateLayout.Name = 'VeloxLabs_ContentLayout'
			templateLayout.Padding = UDim.new(0, 6)  -- Tighter spacing
			templateLayout.SortOrder = Enum.SortOrder.LayoutOrder
			templateLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left  -- Left align for full width
			templateLayout.FillDirection = Enum.FillDirection.Vertical
			templateLayout.Parent = template
			
			-- Add padding to template - more balanced
			local templatePadding = Instance.new('UIPadding')
			templatePadding.PaddingLeft = UDim.new(0, 10)
			templatePadding.PaddingRight = UDim.new(0, 10)
			templatePadding.PaddingTop = UDim.new(0, 8)
			templatePadding.PaddingBottom = UDim.new(0, 8)
			templatePadding.Parent = template
		end
		
		print("[VeloxLabs] Elements container configured with fresh layout")
	end
	
	NightUI.DisplayOrder = 100
	LoadingFrame.Version.Text = "VeloxLabs " .. Release
	
	-- Check sizing
	local minSize = Vector2.new(1024, 768)
	local useMobileSizing = false
	if NightUI.AbsoluteSize.X < minSize.X and NightUI.AbsoluteSize.Y < minSize.Y then
		useMobileSizing = true
	end
	
	local dragOffset = 255
	local dragOffsetMobile = 150
	-- Get LoadingScreen customization from Settings
	local loadingConfig = Settings.LoadingScreen or {}
	
	if LoadingFrame then
		LoadingFrame.BackgroundTransparency = 0
		LoadingFrame.BackgroundColor3 = loadingConfig.BackgroundColor or SelectedTheme.Background or Color3.fromRGB(8, 10, 20)
		LoadingFrame.Size = UDim2.new(1, 0, 1, 0)  -- Full size
		LoadingFrame.Position = UDim2.new(0, 0, 0, 0)  -- Top-left corner
		LoadingFrame.AnchorPoint = Vector2.new(0, 0)
		LoadingFrame.Visible = true
		LoadingFrame.ZIndex = 50  -- Above everything
		
		-- ðŸ”¥ ADD THEME BACKGROUND IMAGE TO LOADING SCREEN ðŸ”¥
		if SelectedTheme.BackgroundImage then
			local loadingBgImage = LoadingFrame:FindFirstChild("ThemeBackground") or Instance.new("ImageLabel")
			loadingBgImage.Name = "ThemeBackground"
			loadingBgImage.Parent = LoadingFrame
			loadingBgImage.Size = UDim2.new(1, 0, 1, 0)
			loadingBgImage.Position = UDim2.new(0, 0, 0, 0)
			loadingBgImage.BackgroundTransparency = 1
			loadingBgImage.Image = SelectedTheme.BackgroundImage
			loadingBgImage.ImageTransparency = SelectedTheme.BackgroundImageTransparency or 0.8
			loadingBgImage.ScaleType = Enum.ScaleType.Crop
			loadingBgImage.ZIndex = 50
		end
		if LoadingFrame:FindFirstChild('Logo') then
			LoadingFrame.Logo.Visible = false
		end
		if LoadingFrame:FindFirstChild('Shadow') then
			LoadingFrame.Shadow.Visible = false
		end
		if LoadingFrame:FindFirstChild('Spinner') then
			LoadingFrame.Spinner.Visible = false
		end
		if LoadingFrame:FindFirstChild('Title') then
			LoadingFrame.Title.Visible = false  -- Hide default title
		end
		if LoadingFrame:FindFirstChild('Subtitle') then
			LoadingFrame.Subtitle.Visible = false  -- Hide default subtitle
		end
		if LoadingFrame:FindFirstChild('Version') then
			LoadingFrame.Version.Visible = false  -- Hide default version
		end
		local bgGradient = LoadingFrame:FindFirstChild("BGGradient") or Instance.new("UIGradient")
		bgGradient.Name = "BGGradient"
		local themeBg = SelectedTheme.Background or Color3.fromRGB(15, 12, 30)
		local themeShadow = SelectedTheme.Shadow or Color3.fromRGB(8, 10, 20)
		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, themeBg),
			ColorSequenceKeypoint.new(0.5, themeShadow),
			ColorSequenceKeypoint.new(1, themeBg),
		})
		bgGradient.Rotation = 45
		bgGradient.Parent = LoadingFrame
		
		-- ðŸ”¥ PLAYER AVATAR ON LOADING SCREEN ðŸ”¥
		local playerAvatar = LoadingFrame:FindFirstChild("PlayerAvatar") or Instance.new("ImageLabel")
		playerAvatar.Name = "PlayerAvatar"
		playerAvatar.Parent = LoadingFrame
		playerAvatar.AnchorPoint = Vector2.new(0.5, 0.5)
		playerAvatar.Position = UDim2.new(0.5, 0, 0.38, 0)
		playerAvatar.Size = UDim2.new(0, 100, 0, 100)
		playerAvatar.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
		playerAvatar.BackgroundTransparency = 0.3
		playerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(Players.LocalPlayer.UserId) .. "&w=150&h=150"
		playerAvatar.ImageTransparency = 0
		playerAvatar.ScaleType = Enum.ScaleType.Crop
		playerAvatar.ZIndex = 52
		
		local avatarCorner = Instance.new("UICorner")
		avatarCorner.CornerRadius = UDim.new(1, 0)
		avatarCorner.Parent = playerAvatar
		
		local avatarStroke = Instance.new("UIStroke")
		avatarStroke.Color = SelectedTheme.ToggleEnabledStroke
		avatarStroke.Thickness = 3
		avatarStroke.Parent = playerAvatar
		
		-- Animated avatar glow - USE CUSTOM OR THEME COLORS
		local accentColor = loadingConfig.AccentColor or SelectedTheme.ToggleEnabled
		local avatarGlowColor1 = loadingConfig.AccentColor or SelectedTheme.ToggleEnabledStroke
		local avatarGlowColor2 = loadingConfig.AccentColor or SelectedTheme.ToggleEnabled
		avatarStroke.Color = accentColor
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				TweenService:Create(avatarStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Color = avatarGlowColor1,
					Thickness = 4
				}):Play()
				task.wait(1)
				TweenService:Create(avatarStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Color = avatarGlowColor2,
					Thickness = 2
				}):Play()
				task.wait(1)
			end
		end)
		
		-- Player name under avatar - ANIMATED TYPING EFFECT
		local playerName = LoadingFrame:FindFirstChild("PlayerName") or Instance.new("TextLabel")
		playerName.Name = "PlayerName"
		playerName.Parent = LoadingFrame
		playerName.AnchorPoint = Vector2.new(0.5, 0)
		playerName.Position = UDim2.new(0.5, 0, 0.55, 0)
		playerName.Size = UDim2.new(0, 300, 0, 25)
		playerName.BackgroundTransparency = 1
		playerName.Font = Enum.Font.GothamBold
		playerName.Text = ""
		playerName.TextColor3 = loadingConfig.SubtitleColor or SelectedTheme.TextColor or Color3.fromRGB(220, 200, 255)
		playerName.TextSize = 16
		playerName.ZIndex = 52
		
		-- Animate welcome text with typing effect
		local welcomeText = "ðŸ‘‹ Welcome, " .. Players.LocalPlayer.Name
		task.spawn(function()
			task.wait(0.5)
			for i = 1, #welcomeText do
				playerName.Text = string.sub(welcomeText, 1, i)
				task.wait(0.03)
			end
		end)
		
		-- Loading title - SIMPLE TEXT (no weird animation symbols)
		local loadingTitle = LoadingFrame:FindFirstChild("LoadingTitle") or Instance.new("TextLabel")
		loadingTitle.Name = "LoadingTitle"
		loadingTitle.Parent = LoadingFrame
		loadingTitle.AnchorPoint = Vector2.new(0.5, 0)
		loadingTitle.Position = UDim2.new(0.5, 0, 0.08, 0)
		loadingTitle.Size = UDim2.new(0, 400, 0, 35)
		loadingTitle.BackgroundTransparency = 1
		loadingTitle.Font = Enum.Font.GothamBlack
		loadingTitle.Text = ""
		loadingTitle.TextColor3 = loadingConfig.TitleColor or SelectedTheme.TextColor or Color3.fromRGB(200, 170, 255)
		loadingTitle.TextSize = 28
		loadingTitle.ZIndex = 52
		
		-- Simple typing animation for title (no weird symbols)
		local titleText = "ðŸŒ™ " .. (Settings.LoadingTitle or Settings.Name or "NIGHT TESTER")
		task.spawn(function()
			for i = 1, #titleText do
				loadingTitle.Text = string.sub(titleText, 1, i)
				task.wait(0.04)
			end
		end)
		
		-- Loading subtitle - REMOVED (duplicate of animated title)
		
		-- Animated Ring Spinner Container
		local spinnerContainer = LoadingFrame:FindFirstChild("SpinnerContainer") or Instance.new("Frame")
		spinnerContainer.Name = "SpinnerContainer"
		spinnerContainer.Parent = LoadingFrame
		spinnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		spinnerContainer.Position = UDim2.new(0.5, 0, 0.72, 0)
		spinnerContainer.Size = UDim2.new(0, 50, 0, 50)
		spinnerContainer.BackgroundTransparency = 1
		spinnerContainer.ZIndex = 52
		
		-- ðŸ”¥ SPINNER COLORS FROM THEME ðŸ”¥
		local spinnerColor1 = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(130, 80, 255)
		local spinnerColor2 = SelectedTheme.ToggleEnabled or Color3.fromRGB(0, 200, 255)
		local spinnerGlow = SelectedTheme.ToggleEnabledStroke or Color3.fromRGB(200, 150, 255)
		
		-- Outer Glow Ring
		local glowRing = spinnerContainer:FindFirstChild("GlowRing") or Instance.new("Frame")
		glowRing.Name = "GlowRing"
		glowRing.Parent = spinnerContainer
		glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
		glowRing.Position = UDim2.new(0.5, 0, 0.5, 0)
		glowRing.Size = UDim2.new(1, 20, 1, 20)
		glowRing.BackgroundColor3 = spinnerColor1
		glowRing.BackgroundTransparency = 0.85
		local glowCorner = Instance.new("UICorner")
		glowCorner.CornerRadius = UDim.new(1, 0)
		glowCorner.Parent = glowRing
		
		-- Main Spinner Ring - USE THEME COLOR
		local spinnerRing = spinnerContainer:FindFirstChild("SpinnerRing") or Instance.new("ImageLabel")
		spinnerRing.Name = "SpinnerRing"
		spinnerRing.Parent = spinnerContainer
		spinnerRing.AnchorPoint = Vector2.new(0.5, 0.5)
		spinnerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
		spinnerRing.Size = UDim2.new(1, 0, 1, 0)
		spinnerRing.BackgroundTransparency = 1
		spinnerRing.Image = SelectedTheme.SpinnerAsset or "rbxassetid://11963373994"
		spinnerRing.ImageColor3 = spinnerColor1
		
		-- Inner Spinner Ring (counter-rotate) - USE THEME COLOR
		local innerRing = spinnerContainer:FindFirstChild("InnerRing") or Instance.new("ImageLabel")
		innerRing.Name = "InnerRing"
		innerRing.Parent = spinnerContainer
		innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
		innerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerRing.Size = UDim2.new(0.7, 0, 0.7, 0)
		innerRing.BackgroundTransparency = 1
		innerRing.Image = SelectedTheme.SpinnerAsset or "rbxassetid://11963373994"
		innerRing.ImageColor3 = spinnerColor2
		
		-- Center Pulse Dot - USE THEME COLOR
		local centerDot = spinnerContainer:FindFirstChild("CenterDot") or Instance.new("Frame")
		centerDot.Name = "CenterDot"
		centerDot.Parent = spinnerContainer
		centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
		centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
		centerDot.Size = UDim2.new(0, 20, 0, 20)
		centerDot.BackgroundColor3 = spinnerGlow
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = centerDot
		
		-- Modern Progress Bar
		local progressBgColor = SelectedTheme.SliderBackground or Color3.fromRGB(25, 20, 40)
		local progressFillColor = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(150, 100, 255)
		local progressGradient1 = SelectedTheme.TabStroke or Color3.fromRGB(80, 60, 200)
		local progressGradient2 = SelectedTheme.ToggleEnabled or Color3.fromRGB(0, 200, 255)
		
		local progressContainer = LoadingFrame:FindFirstChild("ProgressContainer") or Instance.new("Frame")
		progressContainer.Name = "ProgressContainer"
		progressContainer.Parent = LoadingFrame
		progressContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		progressContainer.Position = UDim2.new(0.5, 0, 0.85, 0)
		progressContainer.Size = UDim2.new(0, 280, 0, 5)
		progressContainer.BackgroundColor3 = progressBgColor
		progressContainer.BorderSizePixel = 0
		progressContainer.ZIndex = 52
		local progCorner = Instance.new("UICorner")
		progCorner.CornerRadius = UDim.new(1, 0)
		progCorner.Parent = progressContainer
		
		-- Progress Bar Fill - USE THEME COLOR
		local progressFill = progressContainer:FindFirstChild("Fill") or Instance.new("Frame")
		progressFill.Name = "Fill"
		progressFill.Parent = progressContainer
		progressFill.AnchorPoint = Vector2.new(0, 0.5)
		progressFill.Position = UDim2.new(0, 0, 0.5, 0)
		progressFill.Size = UDim2.new(0, 0, 1, 0)
		progressFill.BackgroundColor3 = progressFillColor
		progressFill.BorderSizePixel = 0
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = progressFill
		local progGradient = Instance.new("UIGradient")
		progGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, progressGradient1),
			ColorSequenceKeypoint.new(0.5, progressFillColor),
			ColorSequenceKeypoint.new(1, progressGradient2),
		})
		progGradient.Parent = progressFill
		
		-- Progress Glow Effect - USE THEME COLOR
		local progressGlow = progressContainer:FindFirstChild("Glow") or Instance.new("Frame")
		progressGlow.Name = "Glow"
		progressGlow.Parent = progressContainer
		progressGlow.AnchorPoint = Vector2.new(0, 0.5)
		progressGlow.Position = UDim2.new(0, 0, 0.5, 0)
		progressGlow.Size = UDim2.new(0, 0, 2.5, 0)
		progressGlow.BackgroundColor3 = progressFillColor
		progressGlow.BackgroundTransparency = 0.7
		progressGlow.BorderSizePixel = 0
		progressGlow.ZIndex = 0
		local glowFillCorner = Instance.new("UICorner")
		glowFillCorner.CornerRadius = UDim.new(1, 0)
		glowFillCorner.Parent = progressGlow
		
		-- Loading Status Text
		local statusText = LoadingFrame:FindFirstChild("StatusText") or Instance.new("TextLabel")
		statusText.Name = "StatusText"
		statusText.Parent = LoadingFrame
		statusText.AnchorPoint = Vector2.new(0.5, 0)
		statusText.Position = UDim2.new(0.5, 0, 0.9, 0)
		statusText.Size = UDim2.new(0, 300, 0, 20)
		statusText.BackgroundTransparency = 1
		statusText.Font = Enum.Font.GothamMedium
		statusText.Text = "âš¡ Initializing..."
		statusText.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(180, 160, 220)
		statusText.TextSize = 12
		statusText.TextTransparency = 0
		statusText.ZIndex = 52
		local particleContainer = LoadingFrame:FindFirstChild("Particles") or Instance.new("Frame")
		particleContainer.Name = "Particles"
		particleContainer.Parent = LoadingFrame
		particleContainer.Size = UDim2.new(1, 0, 1, 0)
		particleContainer.BackgroundTransparency = 1
		particleContainer.ClipsDescendants = true
		particleContainer.ZIndex = 0
		
		-- ðŸ”¥ PARTICLE COLORS FROM THEME ðŸ”¥
		local particleBaseColor = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(100, 150, 255)
		local particleR = math.floor(particleBaseColor.R * 255)
		local particleG = math.floor(particleBaseColor.G * 255)
		local particleB = math.floor(particleBaseColor.B * 255)
		
		-- Spawn floating particles
		task.spawn(function()
			for i = 1, 12 do
				local particle = Instance.new("Frame")
				particle.Parent = particleContainer
				particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
				particle.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, 1.1, 0)
				-- Use theme color with slight variation
				particle.BackgroundColor3 = Color3.fromRGB(
					math.clamp(particleR + math.random(-30, 30), 0, 255),
					math.clamp(particleG + math.random(-30, 30), 0, 255),
					math.clamp(particleB + math.random(-30, 30), 0, 255)
				)
				particle.BackgroundTransparency = math.random(40, 70) / 100
				local pCorner = Instance.new("UICorner")
				pCorner.CornerRadius = UDim.new(1, 0)
				pCorner.Parent = particle
				
				-- Animate particle floating up
				task.spawn(function()
					local delay = math.random() * 2
					task.wait(delay)
					while LoadingFrame.Visible and LoadingFrame.Parent do
						particle.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, 1.1, 0)
						local floatTime = math.random(20, 40) / 10
						local floatTween = TweenService:Create(particle, TweenInfo.new(floatTime, Enum.EasingStyle.Linear), {
							Position = UDim2.new(particle.Position.X.Scale + (math.random() - 0.5) * 0.2, 0, -0.1, 0)
						})
						floatTween:Play()
						floatTween.Completed:Wait()
					end
				end)
			end
		end)
		
		-- Animation loops
		-- Spinner rotation
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local t = TweenService:Create(spinnerRing, TweenInfo.new(1, Enum.EasingStyle.Linear), {Rotation = spinnerRing.Rotation + 360})
				t:Play()
				t.Completed:Wait()
			end
		end)
		
		-- Inner ring counter-rotation
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local t = TweenService:Create(innerRing, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Rotation = innerRing.Rotation - 360})
				t:Play()
				t.Completed:Wait()
			end
		end)
		
		-- Glow ring pulse
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local expand = TweenService:Create(glowRing, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 35, 1, 35),
					BackgroundTransparency = 0.95
				})
				expand:Play()
				expand.Completed:Wait()
				local shrink = TweenService:Create(glowRing, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Size = UDim2.new(1, 20, 1, 20),
					BackgroundTransparency = 0.85
				})
				shrink:Play()
				shrink.Completed:Wait()
			end
		end)
		local dotPulseColor1 = SelectedTheme.ToggleEnabledStroke or Color3.fromRGB(255, 200, 255)
		local dotPulseColor2 = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(200, 150, 255)
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local grow = TweenService:Create(centerDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Size = UDim2.new(0, 26, 0, 26),
					BackgroundColor3 = dotPulseColor1
				})
				grow:Play()
				grow.Completed:Wait()
				local shrinkDot = TweenService:Create(centerDot, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Size = UDim2.new(0, 20, 0, 20),
					BackgroundColor3 = dotPulseColor2
				})
				shrinkDot:Play()
				shrinkDot.Completed:Wait()
			end
		end)
		
		-- Progress bar animation with status updates
		task.spawn(function()
			local statuses = {"Initializing...", "Loading Assets...", "Building Interface...", "Almost Ready...", "Starting..."}
			local progress = 0
			local step = 0
			while LoadingFrame.Visible and LoadingFrame.Parent and progress < 1 do
				progress = math.min(1, progress + math.random(8, 15) / 100)
				
				-- Update status text based on progress
				local statusIndex = math.min(#statuses, math.floor(progress * #statuses) + 1)
				if statusIndex ~= step then
					step = statusIndex
					local fadeOut = TweenService:Create(statusText, TweenInfo.new(0.15), {TextTransparency = 1})
					fadeOut:Play()
					fadeOut.Completed:Wait()
					statusText.Text = statuses[statusIndex]
					local fadeIn = TweenService:Create(statusText, TweenInfo.new(0.15), {TextTransparency = 0})
					fadeIn:Play()
				end
				
				-- Animate progress bar
				local fillTween = TweenService:Create(progressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(progress, 0, 1, 0)
				})
				local glowTween = TweenService:Create(progressGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(progress, 0, 2.5, 0)
				})
				fillTween:Play()
				glowTween:Play()
				task.wait(math.random(15, 30) / 100)
			end
			-- Ensure it reaches 100%
			TweenService:Create(progressFill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
			TweenService:Create(progressGlow, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 2.5, 0)}):Play()
		end)
		
		-- Background gradient rotation
		task.spawn(function()
			while LoadingFrame.Visible and LoadingFrame.Parent do
				local rotTween = TweenService:Create(bgGradient, TweenInfo.new(8, Enum.EasingStyle.Linear), {Rotation = bgGradient.Rotation + 360})
				rotTween:Play()
				rotTween.Completed:Wait()
			end
		end)
	end
	
	

	

	if not correctBuild and not Settings.DisableBuildWarnings then
		task.delay(3, 
			function() 
				NightUILibrary:Notify({Title = 'Build Mismatch', Content = 'NightUI may encounter issues as you are running an incompatible interface version ('.. ((NightUI:FindFirstChild('Build') and NightUI.Build.Value) or 'No Build') ..').\n\nThis version of NightUI is intended for interface build '..InterfaceBuild..'..\n\nTry rejoining and then run the script twice.', Image = 4335487866, Duration = 15})		
			end)
	end

	if Settings.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind = Settings.ToggleUIKeybind
		if type(keybind) == "string" then
			keybind = string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end), "ToggleUIKeybind must be a valid KeyCode")
			overrideSetting("General", "nightuiOpen", keybind)
		elseif typeof(keybind) == "EnumItem" then
			assert(keybind.EnumType == Enum.KeyCode, "ToggleUIKeybind must be a KeyCode enum")
			overrideSetting("General", "nightuiOpen", keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end

	if isfolder and not isfolder(NightUIFolder) then
		makefolder(NightUIFolder)
	end
	
	local Passthrough = false
	if Topbar:FindFirstChild('Title') then
		Topbar.Title.Text = Settings.Name
	end
	Main.Size = UDim2.new(0, 800, 0, 600)  -- Full size from start
	Main.Visible = true
	Main.BackgroundTransparency = 0  -- Visible background
	if Main:FindFirstChild('Notice') then Main.Notice.Visible = false end
	Main.Shadow.Image.ImageTransparency = 1
	if LoadingFrame:FindFirstChild('Title') then
		LoadingFrame.Title.Visible = false
		LoadingFrame.Title.TextTransparency = 1
	end
	if LoadingFrame:FindFirstChild('Subtitle') then
		LoadingFrame.Subtitle.Visible = false
		LoadingFrame.Subtitle.TextTransparency = 1
	end
	if LoadingFrame:FindFirstChild('Version') then
		LoadingFrame.Version.Visible = false
		LoadingFrame.Version.TextTransparency = 1
	end
	if LoadingFrame:FindFirstChild('Logo') then
		LoadingFrame.Logo.Visible = false
	end
	if LoadingFrame:FindFirstChild('LogoHolder') then
		LoadingFrame.LogoHolder.Visible = false
	end

	if Settings.ShowText then
		MPrompt.Title.Text = 'Show '..Settings.ShowText
	end
	


	if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
		Topbar.Icon.Visible = true
		Topbar.Icon.Size = UDim2.new(0, 28, 0, 28)
		Topbar.Icon.Position = UDim2.new(0, 12, 0.5, 0)
		Topbar.Icon.AnchorPoint = Vector2.new(0, 0.5)
		
		if Topbar:FindFirstChild('Title') then
			Topbar.Title.Position = UDim2.new(0, 48, 0.5, 0)
			Topbar.Title.AnchorPoint = Vector2.new(0, 0.5)
		end

		if Settings.Icon then
			if typeof(Settings.Icon) == 'string' and Icons then
				local asset = getIcon(Settings.Icon)
				Topbar.Icon.Image = 'rbxassetid://'..asset.id
				Topbar.Icon.ImageRectOffset = asset.imageRectOffset
				Topbar.Icon.ImageRectSize = asset.imageRectSize
			else
				Topbar.Icon.Image = getAssetUri(Settings.Icon)
			end
		else
			Topbar.Icon.Image = "rbxassetid://" .. 0
		end
	end

	-- ðŸ”¥ HIDE DRAG BAR COMPLETELY
	if dragBar then
		dragBar.Visible = false
		if dragBarCosmetic then
			dragBarCosmetic.Visible = false
			dragBarCosmetic.BackgroundTransparency = 1
		end
	end

	-- ðŸ”¥ ALLOWED THEMES FILTER ðŸ”¥
	-- Store allowed themes for this window (nil = all themes allowed)
	local AllowedThemes = Settings.AllowedThemes  -- table of theme names or nil
	
	-- Function to check if a theme is allowed
	local function isThemeAllowed(themeName)
		if not AllowedThemes then return true end  -- All themes allowed if not specified
		for _, allowed in ipairs(AllowedThemes) do
			if allowed == themeName then return true end
		end
		return false
	end
	
	-- Get list of allowed themes for dropdown
	local function getAvailableThemes()
		local themes = {}
		for themeName, _ in pairs(NightUILibrary.Theme) do
			if isThemeAllowed(themeName) then
				table.insert(themes, themeName)
			end
		end
		table.sort(themes)  -- Sort alphabetically
		return themes
	end
	
	-- Store for external access
	NightUILibrary.AllowedThemes = AllowedThemes
	NightUILibrary.IsThemeAllowed = isThemeAllowed
	NightUILibrary.GetAvailableThemes = getAvailableThemes

	if Settings.Theme then
		-- Check if requested theme is allowed
		local themeToUse = Settings.Theme
		if not isThemeAllowed(themeToUse) then
			warn('[VeloxLabs] Theme "' .. themeToUse .. '" is not in AllowedThemes, using first allowed theme')
			local available = getAvailableThemes()
			themeToUse = available[1] or 'Default'
		end
		local success, result = pcall(ChangeTheme, themeToUse, NightUI)
		if not success then
			local success, result2 = pcall(ChangeTheme, 'Default', NightUI)
			if not success then
				warn('CRITICAL ERROR - NO DEFAULT THEME')
				print(result2)
			end
			warn('issue rendering theme. no theme on file')
			print(result)
		end
	end

	-- ðŸ”¥ SHOW LOADING ANIMATION FOR ALL WINDOWS (user wants it back)
	Topbar.Visible = false
	Elements.Visible = false
	LoadingFrame.Visible = true
		
		-- ðŸ”¥ THEME-MATCHING LOADING SCREEN ANIMATION ðŸ”¥
		task.spawn(function()
		local titleText = Settings.LoadingTitle or "VeloxLabs"
		local subtitleText = Settings.LoadingSubtitle or "by VeloxLabs"
		
		-- Get theme colors for loading animation
		local themeTextColor = SelectedTheme.TextColor or Color3.fromRGB(220, 200, 255)
		local themeAccent = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(100, 70, 180)
		local themeStroke = SelectedTheme.ToggleEnabled or Color3.fromRGB(130, 80, 220)
		
		-- Hide original text labels initially
		LoadingFrame.Title.Text = ""
		LoadingFrame.Title.TextTransparency = 0
		LoadingFrame.Subtitle.TextTransparency = 1
		LoadingFrame.Subtitle.TextColor3 = themeTextColor
		LoadingFrame.Version.TextTransparency = 1
		LoadingFrame.Version.TextColor3 = themeAccent
		
		-- Apply theme background color to LoadingFrame
		LoadingFrame.BackgroundColor3 = SelectedTheme.Background or Color3.fromRGB(15, 12, 25)
		
		-- Create container for wave text letters
		local waveContainer = LoadingFrame:FindFirstChild("WaveContainer") or Instance.new("Frame")
		waveContainer.Name = "WaveContainer"
		waveContainer.Parent = LoadingFrame
		waveContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		waveContainer.Position = UDim2.new(0.5, 0, 0.22, 0)
		waveContainer.Size = UDim2.new(0, 400, 0, 50)
		waveContainer.BackgroundTransparency = 1
		
		-- Clear existing wave letters
		for _, child in ipairs(waveContainer:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
		
		-- TYPING EFFECT for title with THEME COLORS
		local letterLabels = {}
		local totalWidth = 0
		local fontSize = 28
		local letterSpacing = 2
		
		-- First pass: calculate total width
		for i = 1, #titleText do
			local char = string.sub(titleText, i, i)
			local charWidth = char == " " and 10 or (fontSize * 0.6)
			totalWidth = totalWidth + charWidth + letterSpacing
		end
		totalWidth = totalWidth - letterSpacing
		
		-- Create individual letter labels with THEME colors
		local currentX = -totalWidth / 2
		for i = 1, #titleText do
			local char = string.sub(titleText, i, i)
			local charWidth = char == " " and 10 or (fontSize * 0.6)
			
			local letterLabel = Instance.new("TextLabel")
			letterLabel.Name = "Letter" .. i
			letterLabel.Parent = waveContainer
			letterLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			letterLabel.Position = UDim2.new(0.5, currentX + charWidth/2, 0.5, 0)
			letterLabel.Size = UDim2.new(0, charWidth + 5, 1, 0)
			letterLabel.BackgroundTransparency = 1
			letterLabel.Font = Enum.Font.GothamBold
			letterLabel.Text = ""
			letterLabel.TextColor3 = themeTextColor
			letterLabel.TextSize = fontSize
			letterLabel.TextTransparency = 1
			letterLabel.TextStrokeTransparency = 0.7
			letterLabel.TextStrokeColor3 = themeStroke
			
			table.insert(letterLabels, {label = letterLabel, char = char, index = i})
			currentX = currentX + charWidth + letterSpacing
		end
		
		-- Animate typing effect with theme colors
		for i, data in ipairs(letterLabels) do
			if not LoadingFrame.Visible then break end
			
			-- Show letter with pop effect
			data.label.Text = data.char
			data.label.TextTransparency = 0
			data.label.TextSize = fontSize * 1.5
			data.label.TextColor3 = themeAccent  -- Pop color
			
			-- Animate to normal size and color
			local popTween = TweenService:Create(data.label, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				TextSize = fontSize,
				TextColor3 = themeTextColor
			})
			popTween:Play()
			
			task.wait(0.05) -- Delay between letters
		end
		
		-- Wait a moment, then start WAVE ANIMATION
		task.wait(0.3)
		
		-- Fade in subtitle with theme color
		LoadingFrame.Subtitle.Text = subtitleText
		TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
		
		-- Fade in version with theme color
		task.wait(0.2)
		TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
		
		-- THEME-MATCHING Wave animation loop
		local waveAmplitude = 8
		local waveSpeed = 3
		local startTime = tick()
		
		-- Extract RGB values for smooth color cycling
		local baseR, baseG, baseB = themeTextColor.R * 255, themeTextColor.G * 255, themeTextColor.B * 255
		local accentR, accentG, accentB = themeAccent.R * 255, themeAccent.G * 255, themeAccent.B * 255
		
		while LoadingFrame.Visible and LoadingFrame.Parent do
			local elapsed = tick() - startTime
			
			for i, data in ipairs(letterLabels) do
				local offset = math.sin((elapsed * waveSpeed) + (i * 0.4)) * waveAmplitude
				
				-- Calculate base position
				local baseY = 0.5
				
				-- Apply wave offset
				data.label.Position = UDim2.new(
					data.label.Position.X.Scale,
					data.label.Position.X.Offset,
					baseY,
					offset
				)
				
				-- THEME-BASED color shimmer effect
				local colorPhase = (elapsed * 2 + i * 0.3) % 1
				local blend = math.sin(colorPhase * math.pi * 2) * 0.3 + 0.7
				local r = baseR * blend + accentR * (1 - blend)
				local g = baseG * blend + accentG * (1 - blend)
				local b = baseB * blend + accentB * (1 - blend)
				data.label.TextColor3 = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
			end
			
			task.wait(0.016) -- ~60 FPS
		end
	end)
	--[[
	if not Settings.DisableNightUIPrompts then
		task.spawn(function()
			while true do
				task.wait(math.random(180, 600))
				NightUILibrary:Notify({
					Title = "NightUI Interface",
					Content = "Enjoying this UI library? Find it at sirius.menu/discord",
					Duration = 7,
					Image = 4370033185,
				})
			end
		end)
	end
	]]

	pcall(function()
		if not Settings.ConfigurationSaving.FileName then
			Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
		end

		if Settings.ConfigurationSaving.Enabled == nil then
			Settings.ConfigurationSaving.Enabled = false
		end

		CFileName = Settings.ConfigurationSaving.FileName
		ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
		CEnabled = false  -- Force disabled, ignore Settings.ConfigurationSaving.Enabled

		if false then  -- Disabled config folder creation
			if not isfolder(ConfigurationFolder) then
				makefolder(ConfigurationFolder)
			end	
		end
	end)


	makeDraggable(Main, Topbar, false, {dragOffset, dragOffsetMobile})
	if dragBar then dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset) makeDraggable(Main, dragInteract, true, {dragOffset, dragOffsetMobile}) end

	for _, TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName == "Frame" and TabButton.Name ~= "Placeholder" and TabButton.Name ~= "AvatarRow" and TabButton:FindFirstChild('Title') then
			TabButton.BackgroundTransparency = 1
			TabButton.Title.TextTransparency = 1
			TabButton.Image.ImageTransparency = 1
			TabButton.UIStroke.Transparency = 1
		end
	end

	if Settings.Discord and Settings.Discord.Enabled and not useStudio then
		if isfolder and not isfolder(NightUIFolder.."/Discord Invites") then
			makefolder(NightUIFolder.."/Discord Invites")
		end

		if isfile and not isfile(NightUIFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension) then
			if requestFunc then
				pcall(function()
					requestFunc({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = HttpService:JSONEncode({
							cmd = 'INVITE_BROWSER',
							nonce = HttpService:GenerateGUID(false),
							args = {code = Settings.Discord.Invite}
						})
					})
				end)
			end

			if Settings.Discord.RememberJoins then -- We do logic this way so if the developer changes this setting, the user still won't be prompted, only new users
				writefile(NightUIFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension,"NightUI RememberJoins is true for this invite, this invite will not ask you to join again")
			end
		end
	end

	if (Settings.KeySystem) then
		if not Settings.KeySettings then
			Passthrough = true
			return
		end

		if isfolder and not isfolder(NightUIFolder.."/Key System") then
			makefolder(NightUIFolder.."/Key System")
		end

		if typeof(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = {Settings.KeySettings.Key} end

		if Settings.KeySettings.GrabKeyFromSite then
			for i, Key in ipairs(Settings.KeySettings.Key) do
				local Success, Response = pcall(function()
					Settings.KeySettings.Key[i] = tostring(game:HttpGet(Key):gsub("[\n\r]", " "))
					Settings.KeySettings.Key[i] = string.gsub(Settings.KeySettings.Key[i], " ", "")
				end)
				if not Success then
					print("VeloxLabs | "..Key.." Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
				end
			end
		end

		if not Settings.KeySettings.FileName then
			Settings.KeySettings.FileName = "No file name specified"
		end

		if isfile and isfile(NightUIFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension) then
			for _, MKey in ipairs(Settings.KeySettings.Key) do
				if string.find(readfile(NightUIFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension), MKey) then
					Passthrough = true
				end
			end
		end

		if not Passthrough then
			local AttemptsRemaining = math.random(2, 5)
			NightUI.Enabled = false
			NightUI.Name = "VeloxLabs-"..tostring(math.random(100000,999999))
			local KeyUI = useStudio and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]

			KeyUI.Enabled = true

			if gethui then
				KeyUI.Parent = gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(KeyUI)
				KeyUI.Parent = CoreGui
			elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
				KeyUI.Parent = CoreGui:FindFirstChild("RobloxGui")
			elseif not useStudio then
				KeyUI.Parent = CoreGui
			end

			-- Clean up old KeyUI instances
			local parent = gethui and gethui() or CoreGui
			for _, Interface in ipairs(parent:GetChildren()) do
				if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
					Interface.Name = "KeyUI-Old"
				end
			end

			local KeyMain = KeyUI.Main
			
			-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
			-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
			
			-- Get custom colors from KeySettings (or use theme defaults)
			local keyConfig = Settings.KeySettings or {}
			local keyBgColor = keyConfig.BackgroundColor or SelectedTheme.Background
			local keyTitleColor = keyConfig.TitleColor or SelectedTheme.TextColor
			local keyAccentColor = keyConfig.AccentColor or SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
			local keyInputBg = keyConfig.InputBackground or SelectedTheme.InputBackground or SelectedTheme.ElementBackground
			
			-- Apply theme colors to Key UI
			KeyMain.BackgroundColor3 = keyBgColor
			KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
			KeyMain.Title.TextColor3 = keyTitleColor
			KeyMain.Title.Font = Enum.Font.GothamBold
			KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
			KeyMain.Subtitle.TextColor3 = SelectedTheme.SecondaryTextColor or keyTitleColor
			KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"
			KeyMain.NoteMessage.TextColor3 = SelectedTheme.SecondaryTextColor or keyTitleColor
			
			-- Style the input field
			if KeyMain:FindFirstChild("Input") then
				KeyMain.Input.BackgroundColor3 = keyInputBg
				if KeyMain.Input:FindFirstChild("UIStroke") then
					KeyMain.Input.UIStroke.Color = SelectedTheme.InputStroke or SelectedTheme.ElementStroke
				end
				if KeyMain.Input:FindFirstChild("InputBox") then
					KeyMain.Input.InputBox.TextColor3 = keyTitleColor
					KeyMain.Input.InputBox.PlaceholderColor3 = SelectedTheme.PlaceholderColor or Color3.fromRGB(120, 120, 120)
				end
			end
			
			-- Style KeyNote
			if KeyMain:FindFirstChild("KeyNote") then
				KeyMain.KeyNote.TextColor3 = keyAccentColor
			end
			
			-- Style NoteTitle
			if KeyMain:FindFirstChild("NoteTitle") then
				KeyMain.NoteTitle.TextColor3 = keyTitleColor
			end
			
			-- Add accent bar at top
			local accentBar = KeyMain:FindFirstChild("KeyAccentBar") or Instance.new("Frame")
			accentBar.Name = "KeyAccentBar"
			accentBar.Parent = KeyMain
			accentBar.Size = UDim2.new(1, 0, 0, 3)
			accentBar.Position = UDim2.new(0, 0, 0, 0)
			accentBar.BackgroundColor3 = keyAccentColor
			accentBar.BorderSizePixel = 0
			accentBar.ZIndex = 10
			
			-- Add gradient to accent bar
			local accentGradient = accentBar:FindFirstChild("Gradient") or Instance.new("UIGradient")
			accentGradient.Name = "Gradient"
			accentGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled)
			})
			accentGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 0.3)
			})
			accentGradient.Parent = accentBar
			
			-- Animate gradient shimmer
			task.spawn(function()
				while accentBar.Parent do
					TweenService:Create(accentGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1, 0)}):Play()
					task.wait(2)
					accentGradient.Offset = Vector2.new(-1, 0)
				end
			end)
			
			-- Add UIStroke to main frame if not exists
			local mainStroke = KeyMain:FindFirstChild("MainStroke") or Instance.new("UIStroke")
			mainStroke.Name = "MainStroke"
			mainStroke.Color = SelectedTheme.ElementStroke
			mainStroke.Thickness = 1
			mainStroke.Transparency = 0.5
			mainStroke.Parent = KeyMain
			
			-- Initial hidden state
			KeyMain.Size = UDim2.new(0, 400, 0, 0)
			KeyMain.BackgroundTransparency = 1
			KeyMain.Position = UDim2.new(0.5, 0, 0.5, 0)
			KeyMain.AnchorPoint = Vector2.new(0.5, 0.5)
			accentBar.BackgroundTransparency = 1
			mainStroke.Transparency = 1
			
			if KeyMain:FindFirstChild("Shadow") and KeyMain.Shadow:FindFirstChild("Image") then
				KeyMain.Shadow.Image.ImageTransparency = 1
			end
			KeyMain.Title.TextTransparency = 1
			KeyMain.Subtitle.TextTransparency = 1
			if KeyMain:FindFirstChild("KeyNote") then KeyMain.KeyNote.TextTransparency = 1 end
			KeyMain.Input.BackgroundTransparency = 1
			if KeyMain.Input:FindFirstChild("UIStroke") then KeyMain.Input.UIStroke.Transparency = 1 end
			KeyMain.Input.InputBox.TextTransparency = 1
			if KeyMain:FindFirstChild("NoteTitle") then KeyMain.NoteTitle.TextTransparency = 1 end
			KeyMain.NoteMessage.TextTransparency = 1
			if KeyMain:FindFirstChild("Hide") then KeyMain.Hide.ImageTransparency = 1 end
			TweenService:Create(KeyMain, AnimationLib.Presets.PanelOpen, {
				BackgroundTransparency = 0,
				Size = UDim2.new(0, 450, 0, 220)
			}):Play()
			TweenService:Create(accentBar, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0}):Play()
			TweenService:Create(mainStroke, AnimationLib.Presets.Smooth, {Transparency = 0.5}):Play()
			
			if KeyMain:FindFirstChild("Shadow") and KeyMain.Shadow:FindFirstChild("Image") then
				TweenService:Create(KeyMain.Shadow.Image, AnimationLib.Presets.Smooth, {ImageTransparency = 0.4}):Play()
			end
			
			task.wait(0.1)
			TweenService:Create(KeyMain.Title, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.Subtitle, AnimationLib.Presets.Smooth, {TextTransparency = 0.3}):Play()
			task.wait(0.05)
			if KeyMain:FindFirstChild("KeyNote") then
				TweenService:Create(KeyMain.KeyNote, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
			end
			TweenService:Create(KeyMain.Input, AnimationLib.Presets.Smooth, {BackgroundTransparency = 0}):Play()
			if KeyMain.Input:FindFirstChild("UIStroke") then
				TweenService:Create(KeyMain.Input.UIStroke, AnimationLib.Presets.Smooth, {Transparency = 0}):Play()
			end
			TweenService:Create(KeyMain.Input.InputBox, AnimationLib.Presets.Smooth, {TextTransparency = 0}):Play()
			task.wait(0.05)
			if KeyMain:FindFirstChild("NoteTitle") then
				TweenService:Create(KeyMain.NoteTitle, AnimationLib.Presets.Smooth, {TextTransparency = 0.2}):Play()
			end
			TweenService:Create(KeyMain.NoteMessage, AnimationLib.Presets.Smooth, {TextTransparency = 0.3}):Play()
			task.wait(0.1)
			if KeyMain:FindFirstChild("Hide") then
				TweenService:Create(KeyMain.Hide, AnimationLib.Presets.Smooth, {ImageTransparency = 0.3}):Play()
			end

			-- Helper function for close animation
			local function closeKeyUI(destroy)
				TweenService:Create(KeyMain, AnimationLib.Presets.PanelClose, {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 400, 0, 0)
				}):Play()
				TweenService:Create(accentBar, AnimationLib.Presets.Smooth, {BackgroundTransparency = 1}):Play()
				TweenService:Create(mainStroke, AnimationLib.Presets.Smooth, {Transparency = 1}):Play()
				
				if KeyMain:FindFirstChild("Shadow") and KeyMain.Shadow:FindFirstChild("Image") then
					TweenService:Create(KeyMain.Shadow.Image, AnimationLib.Presets.Smooth, {ImageTransparency = 1}):Play()
				end
				TweenService:Create(KeyMain.Title, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.Subtitle, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				if KeyMain:FindFirstChild("KeyNote") then
					TweenService:Create(KeyMain.KeyNote, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				end
				TweenService:Create(KeyMain.Input, AnimationLib.Presets.Smooth, {BackgroundTransparency = 1}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, AnimationLib.Presets.Smooth, {Transparency = 1}):Play()
				end
				TweenService:Create(KeyMain.Input.InputBox, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				if KeyMain:FindFirstChild("NoteTitle") then
					TweenService:Create(KeyMain.NoteTitle, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				end
				TweenService:Create(KeyMain.NoteMessage, AnimationLib.Presets.Smooth, {TextTransparency = 1}):Play()
				if KeyMain:FindFirstChild("Hide") then
					TweenService:Create(KeyMain.Hide, AnimationLib.Presets.Smooth, {ImageTransparency = 1}):Play()
				end
				
				task.wait(0.4)
				if destroy then
					KeyUI:Destroy()
				end
			end
			
			-- Helper function for error shake animation
			local function shakeError()
				-- Flash input red
				local originalColor = KeyMain.Input.BackgroundColor3
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(180, 60, 60)}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(220, 80, 80)}):Play()
				end
				
				-- Shake animation
				TweenService:Create(KeyMain, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -10, 0.5, 0)}):Play()
				task.wait(0.08)
				TweenService:Create(KeyMain, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 10, 0.5, 0)}):Play()
				task.wait(0.08)
				TweenService:Create(KeyMain, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -5, 0.5, 0)}):Play()
				task.wait(0.08)
				TweenService:Create(KeyMain, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
				
				-- Restore colors
				task.wait(0.3)
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.3), {BackgroundColor3 = originalColor}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.3), {Color = SelectedTheme.InputStroke or SelectedTheme.ElementStroke}):Play()
				end
			end
			
			-- Helper function for success animation
			local function successAnimation()
				-- Flash input green
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 180, 80)}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 220, 100)}):Play()
				end
				
				-- Scale bounce
				TweenService:Create(KeyMain, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 460, 0, 230)}):Play()
				task.wait(0.2)
			end

			KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
				if #KeyUI.Main.Input.InputBox.Text == 0 then return end
				local KeyFound = false
				local FoundKey = ''
				
				for _, MKey in ipairs(Settings.KeySettings.Key) do
					if KeyMain.Input.InputBox.Text == MKey then
						KeyFound = true
						FoundKey = MKey
					end
				end
				
				if KeyFound then 
					-- ðŸŽ‰ SUCCESS!
					successAnimation()
					closeKeyUI(false)
					Passthrough = true
					KeyMain.Visible = false
					
					if Settings.KeySettings.SaveKey then
						if writefile then
							writefile(NightUIFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension, FoundKey)
						end
						NightUILibrary:Notify({Title = "ðŸ”“ Key Saved", Content = "Your key has been saved for next time!", Duration = 4})
					else
						NightUILibrary:Notify({Title = "ðŸ”“ Access Granted", Content = "Welcome! Enjoy the script.", Duration = 3})
					end
				else
					-- âŒ WRONG KEY
					if AttemptsRemaining == 0 then
						closeKeyUI(true)
						task.wait(0.5)
						Players.LocalPlayer:Kick("âŒ No attempts remaining")
						game:Shutdown()
					end
					
					KeyMain.Input.InputBox.Text = ""
					AttemptsRemaining = AttemptsRemaining - 1
					shakeError()
					
					-- Update subtitle with attempts remaining
					KeyMain.Subtitle.Text = "âŒ Wrong key! " .. AttemptsRemaining .. " attempts left"
					TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 80, 80)}):Play()
					task.wait(1.5)
					KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
					TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.3), {TextColor3 = SelectedTheme.SecondaryTextColor or SelectedTheme.TextColor}):Play()
				end
			end)

			-- Input focus effects
			KeyMain.Input.InputBox.Focused:Connect(function()
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.2), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover or SelectedTheme.ElementBackground}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.2), {Color = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled}):Play()
				end
			end)
			
			KeyMain.Input.InputBox.FocusLost:Connect(function()
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.2), {BackgroundColor3 = SelectedTheme.InputBackground or SelectedTheme.ElementBackground}):Play()
				if KeyMain.Input:FindFirstChild("UIStroke") then
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.2), {Color = SelectedTheme.InputStroke or SelectedTheme.ElementStroke}):Play()
				end
			end)

			if KeyMain:FindFirstChild("Hide") then
				KeyMain.Hide.MouseButton1Click:Connect(function()
					closeKeyUI(true)
					NightUILibrary:Destroy()
				end)
			end
		else
			Passthrough = true
		end
	end
	if Settings.KeySystem then
		repeat task.wait() until Passthrough
	end
	local Notifications = NightUI:FindFirstChild('Notifications')
	if Notifications and Notifications:FindFirstChild('Template') then
		Notifications.Template.Visible = false
		Notifications.Visible = true
		Notifications.ZIndex = 100  -- Make sure notifications are on top
		
		-- Position notifications in top-right corner
		Notifications.AnchorPoint = Vector2.new(1, 0)
		Notifications.Position = UDim2.new(1, -20, 0, 60)
		Notifications.Size = UDim2.new(0, 300, 1, -80)
		
		print("[VeloxLabs] Notifications container configured")
	else
		warn("[VeloxLabs] Notifications container not found!")
	end
	NightUI.Enabled = true

	task.wait(0.5)
	if LoadingFrame:FindFirstChild('Title') then
		LoadingFrame.Title.Visible = false
	end
	if LoadingFrame:FindFirstChild('Subtitle') then
		LoadingFrame.Subtitle.Visible = false
	end
	if LoadingFrame:FindFirstChild('Version') then
		LoadingFrame.Version.Visible = false
	end
	if LoadingFrame:FindFirstChild('Logo') then
		LoadingFrame.Logo.Visible = false
	end
	if LoadingFrame:FindFirstChild('LogoHolder') then
		LoadingFrame.LogoHolder.Visible = false
	end
	
	-- Just animate the main window background
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()


	Elements.Template.LayoutOrder = 100000
	Elements.Template.Visible = false

	-- UIPageLayout should be Vertical (pages stack on top of each other)
	if Elements.UIPageLayout then
		print("[VeloxLabs] UIPageLayout found, setting to Vertical")
		Elements.UIPageLayout.FillDirection = Enum.FillDirection.Vertical
		Elements.UIPageLayout.Animated = true
		Elements.UIPageLayout.TweenTime = 0.35
		Elements.UIPageLayout.EasingStyle = Enum.EasingStyle.Exponential
		Elements.UIPageLayout.EasingDirection = Enum.EasingDirection.Out
	else
		print("[VeloxLabs] WARNING: UIPageLayout not found in Elements!")
	end
	TabList.Template.Visible = false

	-- Tab
	local FirstTab = false
	local Window = {}
	local tabIndex = 0  -- Track tab order for staggered animations
	local allElements = {}  -- Track all elements for search
	
	-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
	-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
	
	local searchExpanded = false
	
	-- Create search bar in topbar - starts as icon only
	local searchContainer = Instance.new("Frame")
	searchContainer.Name = "SearchContainer"
	searchContainer.Size = UDim2.new(0, 32, 0, 32)
	searchContainer.Position = UDim2.new(1, -50, 0.5, 0)
	searchContainer.AnchorPoint = Vector2.new(0, 0.5)
	searchContainer.BackgroundColor3 = SelectedTheme.ElementBackground
	searchContainer.BackgroundTransparency = 0.5
	searchContainer.BorderSizePixel = 0
	searchContainer.ZIndex = 10
	searchContainer.ClipsDescendants = true
	searchContainer.Parent = Topbar
	
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchContainer
	
	local searchStroke = Instance.new("UIStroke")
	searchStroke.Color = SelectedTheme.ElementStroke
	searchStroke.Thickness = 1
	searchStroke.Transparency = 0.5
	searchStroke.Parent = searchContainer
	
	local searchIconBtn = Instance.new("TextButton")
	searchIconBtn.Name = "IconBtn"
	searchIconBtn.Size = UDim2.new(0, 32, 0, 32)
	searchIconBtn.Position = UDim2.new(0, 0, 0, 0)
	searchIconBtn.BackgroundTransparency = 1
	searchIconBtn.Text = "ðŸ”"
	searchIconBtn.TextSize = 14
	searchIconBtn.Font = Enum.Font.Gotham
	searchIconBtn.TextColor3 = SelectedTheme.TextColor
	searchIconBtn.Parent = searchContainer
	
	local searchInput = Instance.new("TextBox")
	searchInput.Name = "Input"
	searchInput.Size = UDim2.new(1, -40, 1, 0)
	searchInput.Position = UDim2.new(0, 35, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.Text = ""
	searchInput.PlaceholderText = "Search..."
	searchInput.PlaceholderColor3 = SelectedTheme.PlaceholderColor
	searchInput.TextColor3 = SelectedTheme.TextColor
	searchInput.TextSize = 12
	searchInput.Font = Enum.Font.Gotham
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.ClearTextOnFocus = false
	searchInput.Visible = false
	searchInput.Parent = searchContainer
	
	-- Search functionality (MUST be defined before toggleSearch!)
	local function performSearch(query)
		if not query then query = "" end
		query = string.lower(query)
		local hasResults = false
		
		-- Search through all tabs and elements
		for _, tabData in pairs(allElements) do
			local tabHasMatch = false
			
			for _, elementData in ipairs(tabData.elements) do
				local elementName = string.lower(elementData.name or "")
				local matches = query == "" or string.find(elementName, query, 1, true)
				
				if elementData.frame and elementData.frame.Parent then
					if matches then
						elementData.frame.Visible = true
						tabHasMatch = true
						hasResults = true
						
						-- Highlight matching element
						if query ~= "" then
							TweenService:Create(elementData.frame, TweenInfo.new(0.2), {
								BackgroundTransparency = 0
							}):Play()
						end
					else
						if query ~= "" then
							elementData.frame.Visible = false
						else
							elementData.frame.Visible = true
						end
					end
				end
			end
			
			-- Show/hide tab based on matches (but respect hidden tabs!)
			if tabData.button and tabData.button.Parent then
				-- Don't show tabs that were originally hidden (Ext = true)
				local isHiddenTab = tabData.button:GetAttribute("HiddenTab")
				if isHiddenTab then
					tabData.button.Visible = false
				elseif query == "" or tabHasMatch then
					tabData.button.Visible = true
				else
					tabData.button.Visible = false
				end
			end
		end
		
		return hasResults
	end
	
	-- Toggle search expansion (defined AFTER performSearch)
	local function toggleSearch()
		searchExpanded = not searchExpanded
		if searchExpanded then
			TweenService:Create(searchContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 150, 0, 28),
				Position = UDim2.new(1, -165, 0.5, 0)
			}):Play()
			TweenService:Create(searchStroke, TweenInfo.new(0.2), {
				Color = SelectedTheme.ToggleEnabled or Color3.fromRGB(100, 100, 255),
				Transparency = 0
			}):Play()
			task.delay(0.15, function()
				searchInput.Visible = true
				searchInput:CaptureFocus()
			end)
		else
			searchInput.Text = ""
			performSearch("")
			searchInput.Visible = false
			TweenService:Create(searchContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(1, -50, 0.5, 0)
			}):Play()
			TweenService:Create(searchStroke, TweenInfo.new(0.2), {
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			}):Play()
		end
	end
	
	searchIconBtn.MouseButton1Click:Connect(toggleSearch)
	
	-- Connect search input
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		performSearch(searchInput.Text)
	end)
	
	-- Close search when focus lost and empty
	searchInput.FocusLost:Connect(function()
		if searchInput.Text == "" and searchExpanded then
			toggleSearch()
		end
	end)
	
	-- Register element for search
	local function registerElement(tabName, elementName, elementFrame)
		if not allElements[tabName] then
			allElements[tabName] = { elements = {}, button = nil }
		end
		table.insert(allElements[tabName].elements, {
			name = elementName,
			frame = elementFrame
		})
	end
	
	-- Register tab button for search
	local function registerTabButton(tabName, tabButton)
		if not allElements[tabName] then
			allElements[tabName] = { elements = {}, button = nil }
		end
		allElements[tabName].button = tabButton
	end
	
	-- Expose search function
	function Window:Search(query)
		searchInput.Text = query
		return performSearch(query)
	end
	
	function Window:ClearSearch()
		searchInput.Text = ""
		performSearch("")
	end
	
	-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
	-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
	local autoResizeEnabled = true
	local baseWindowHeight = 400
	local maxWindowHeight = 650
	local minWindowHeight = 300
	
	local function autoResizeWindow()
		if not autoResizeEnabled then return end
		
		-- Count visible elements in current tab
		local currentPage = Elements.UIPageLayout.CurrentPage
		if not currentPage then return end
		
		local totalHeight = 80  -- Base padding
		for _, child in ipairs(currentPage:GetChildren()) do
			if child:IsA("Frame") and child.Visible and child.Name ~= "Template" then
				totalHeight = totalHeight + child.AbsoluteSize.Y + 8
			end
		end
		
		local targetHeight = math.clamp(totalHeight, minWindowHeight, maxWindowHeight)
		TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, Main.AbsoluteSize.X, 0, targetHeight)
		}):Play()
	end
	function Window:SetAutoResize(enabled)
		autoResizeEnabled = enabled
	end
	
	-- Manual resize
	function Window:SetSize(width, height)
		TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
			Size = UDim2.new(0, width, 0, height)
		}):Play()
	end
	
	-- Collapsible section creator
	function Window:CreateSection(sectionName)
		local section = {
			collapsed = false,
			elements = {}
		}
		
		return section
	end
	
	function Window:CreateTab(Name, Image, Ext)
		local SDone = false
		tabIndex = tabIndex + 1
		local currentTabIndex = tabIndex
		
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabButton.Title.TextWrapped = false
		TabButton.Size = UDim2.new(1, -10, 0, 44)  -- Full width with padding, 44px height
		TabButton.AnchorPoint = Vector2.new(0.5, 0)
		TabButton.Position = UDim2.new(0.5, 0, 0, 0)
		
		-- Parent to TabContainer if it exists, otherwise TabList
		local tabParent = TabList:FindFirstChild("TabContainer") or TabList
		TabButton.Parent = tabParent
		TabButton.BackgroundTransparency = 1
		TabButton.Title.TextTransparency = 1
		TabButton.Image.ImageTransparency = 1
		TabButton.Title.Font = Enum.Font.GothamMedium
		TabButton.Title.TextSize = 13
		
		-- Ensure proper corner radius
		local tabCorner = TabButton:FindFirstChildOfClass('UICorner')
		if not tabCorner then
			tabCorner = Instance.new('UICorner')
			tabCorner.Parent = TabButton
		end
		tabCorner.CornerRadius = UDim.new(0, 8)
		
		-- Ensure UIStroke exists and is styled
		local tabStroke = TabButton:FindFirstChildOfClass('UIStroke')
		if not tabStroke then
			tabStroke = Instance.new('UIStroke')
			tabStroke.Parent = TabButton
		end
		tabStroke.Thickness = 1.5
		tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
		-- Register tab for search
		registerTabButton(Name, TabButton)
		TabButton.UIStroke.Transparency = 1
		TabButton.LayoutOrder = currentTabIndex  -- Ensure proper order
		TabButton.Visible = (Ext ~= true)  -- Hide if Ext is true
		
		-- Mark hidden tabs so search doesn't show them
		if Ext then
			TabButton:SetAttribute("HiddenTab", true)
		end

		if Image and Image ~= 0 then
			if typeof(Image) == 'string' and Icons then
				local asset = getIcon(Image)
				TabButton.Image.Image = 'rbxassetid://'..asset.id
				TabButton.Image.ImageRectOffset = asset.imageRectOffset
				TabButton.Image.ImageRectSize = asset.imageRectSize
			else
				TabButton.Image.Image = getAssetUri(Image)
			end
			TabButton.Image.Size = UDim2.new(0, 20, 0, 20)
			TabButton.Image.Position = UDim2.new(0, 12, 0.5, 0)
			TabButton.Image.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Title.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Title.Position = UDim2.new(0, 40, 0.5, 0)
			TabButton.Title.Size = UDim2.new(1, -52, 1, 0)
			TabButton.Image.Visible = true
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
		else
			TabButton.Title.AnchorPoint = Vector2.new(0.5, 0.5)
			TabButton.Title.Position = UDim2.new(0.5, 0, 0.5, 0)
			TabButton.Title.Size = UDim2.new(1, -20, 1, 0)
			TabButton.Image.Visible = false
		end
		TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
		TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
		TabButton.UIStroke.Color = SelectedTheme.TabStroke
		TabButton.BackgroundColor3 = SelectedTheme.TabBackground

		-- Create Elements Page with proper configuration
		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true
		TabPage.BackgroundTransparency = 1
		TabPage.BorderSizePixel = 0
		TabPage.AnchorPoint = Vector2.new(0, 0)
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.Position = UDim2.new(0, 0, 0, 0)
		
		print("[VeloxLabs] Created TabPage '", Name, "' - Class:", TabPage.ClassName)
		
		-- Configure scrolling if it's a ScrollingFrame
		if TabPage:IsA('ScrollingFrame') then
			TabPage.ScrollBarThickness = 4
			TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
			TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
			TabPage.ScrollingDirection = Enum.ScrollingDirection.Y
			TabPage.ScrollBarImageColor3 = SelectedTheme.ElementStroke or Color3.fromRGB(80, 60, 140)
			TabPage.BorderSizePixel = 0
			TabPage.ScrollingEnabled = true
			TabPage.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
			print("[VeloxLabs] TabPage is ScrollingFrame, configured scrolling")
		else
			print("[VeloxLabs] TabPage is", TabPage.ClassName, "- may need Frame instead")
		end
		
		-- REMOVE all existing layout constraints from the template
		for _, child in ipairs(TabPage:GetChildren()) do
			if child:IsA('UIPadding') or child:IsA('UIListLayout') or child:IsA('UIGridLayout') then
				child:Destroy()
			end
		end
		
		-- Create fresh UIListLayout for content elements
		-- Use LEFT alignment for full-width elements (Size = 1 scale)
		local newListLayout = Instance.new('UIListLayout')
		newListLayout.Padding = UDim.new(0, 6)  -- Tighter spacing between elements
		newListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		newListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		newListLayout.FillDirection = Enum.FillDirection.Vertical
		newListLayout.Parent = TabPage
		print("[NightUI] TabPage '", Name, "' - Created UIListLayout")
		
		-- Add padding for content margins (this creates the centered look)
		local contentPadding = Instance.new('UIPadding')
		contentPadding.PaddingLeft = UDim.new(0, 12)
		contentPadding.PaddingRight = UDim.new(0, 12)
		contentPadding.PaddingTop = UDim.new(0, 8)
		contentPadding.PaddingBottom = UDim.new(0, 8)
		contentPadding.Parent = TabPage

		TabPage.LayoutOrder = #Elements:GetChildren() or Ext and 10000

		for _, TemplateElement in ipairs(TabPage:GetChildren()) do
			if TemplateElement.ClassName == "Frame" and TemplateElement.Name ~= "Placeholder" then
				TemplateElement:Destroy()
			end
		end

		TabPage.Parent = Elements
		if not FirstTab and not Ext then
			Elements.UIPageLayout.Animated = false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated = true
		end

		TabButton.UIStroke.Color = SelectedTheme.TabStroke

		if Elements.UIPageLayout.CurrentPage == TabPage then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
		else
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
		end


		-- Animate (skip hidden tabs)
		task.wait(0.1)
		if Ext then
			-- Hidden tab - don't animate, keep invisible
			TabButton.Visible = false
			TabButton.BackgroundTransparency = 1
		elseif FirstTab then
			-- Not the first visible tab
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
		else
			-- First visible tab - make it selected
			FirstTab = Name
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		end


		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			
			-- ðŸ”¥ SCALE BOUNCE on click
			AnimationLib.ScaleBounce(TabButton, 1.05)
			
			-- Smooth tab selection with AnimationLib presets
			TweenService:Create(TabButton, AnimationLib.Presets.TabHighlight, {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.UIStroke, AnimationLib.Presets.TabHighlight, {Transparency = 1}):Play()
			TweenService:Create(TabButton.Title, AnimationLib.Presets.TabHighlight, {TextTransparency = 0}):Play()
			TweenService:Create(TabButton.Image, AnimationLib.Presets.TabHighlight, {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, AnimationLib.Presets.TabSlide, {BackgroundColor3 = SelectedTheme.TabBackgroundSelected}):Play()
			TweenService:Create(TabButton.Title, AnimationLib.Presets.TabSlide, {TextColor3 = SelectedTheme.SelectedTabTextColor}):Play()
			TweenService:Create(TabButton.Image, AnimationLib.Presets.TabSlide, {ImageColor3 = SelectedTheme.SelectedTabTextColor}):Play()
			local tabParent = TabList:FindFirstChild("TabContainer") or TabList
			for _, OtherTabButton in ipairs(tabParent:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" and OtherTabButton.Name ~= "AvatarRow" and OtherTabButton:FindFirstChild('Title') then
					TweenService:Create(OtherTabButton, AnimationLib.Presets.TabSlide, {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, AnimationLib.Presets.TabSlide, {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, AnimationLib.Presets.TabSlide, {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, AnimationLib.Presets.TabSlide, {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, AnimationLib.Presets.TabSlide, {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, AnimationLib.Presets.TabSlide, {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, AnimationLib.Presets.TabSlide, {Transparency = 0.5}):Play()
				end
			end

			if Elements.UIPageLayout.CurrentPage ~= TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
				task.spawn(function()
					local elements = {}
					for _, element in ipairs(TabPage:GetChildren()) do
						if element:IsA('Frame') and element.Name ~= 'Template' and not element:IsA('UIListLayout') and not element:IsA('UIPadding') then
							table.insert(elements, element)
						end
					end
					
					for i, element in ipairs(elements) do
						-- Save original values
						local originalPos = element.Position
						local originalTransparency = element.BackgroundTransparency
						
						-- Start offset and slightly faded
						element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 25, originalPos.Y.Scale, originalPos.Y.Offset)
						element.BackgroundTransparency = math.min(originalTransparency + 0.3, 1)
						
						-- Staggered animation
						task.delay(i * AnimationLib.Stagger.Fast, function()
							TweenService:Create(element, AnimationLib.Presets.TabContent, {
								Position = originalPos,
								BackgroundTransparency = originalTransparency
							}):Play()
							
							-- Animate children too
							if element:FindFirstChild('Title') then
								TweenService:Create(element.Title, AnimationLib.Presets.TabContent, {TextTransparency = 0}):Play()
							end
						end)
					end
				end)
			end
		end)
		local function isThisTabSelected()
			return Elements.UIPageLayout.CurrentPage and Elements.UIPageLayout.CurrentPage.Name == Name
		end
		
		TabButton.MouseEnter:Connect(function()
			if isThisTabSelected() then
				-- Selected tab - subtle glow pulse
				TweenService:Create(TabButton.UIStroke, AnimationLib.Presets.HoverIn, {
					Transparency = 0,
					Thickness = 2
				}):Play()
				return
			end
			TweenService:Create(TabButton, AnimationLib.Presets.HoverIn, {
				BackgroundTransparency = 0.3,
				BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			}):Play()
			
			TweenService:Create(TabButton.UIStroke, AnimationLib.Presets.HoverIn, {
				Transparency = 0.2,
				Color = SelectedTheme.ToggleEnabled
			}):Play()
			
			TweenService:Create(TabButton.Title, AnimationLib.Presets.HoverIn, {
				TextTransparency = 0,
				TextColor3 = SelectedTheme.SelectedTabTextColor
			}):Play()
			
			TweenService:Create(TabButton.Image, AnimationLib.Presets.HoverIn, {
				ImageTransparency = 0,
				ImageColor3 = SelectedTheme.SelectedTabTextColor
			}):Play()
		end)
		
		TabButton.MouseLeave:Connect(function()
			if isThisTabSelected() then
				-- Selected tab - subtle glow reset
				TweenService:Create(TabButton.UIStroke, AnimationLib.Presets.HoverOut, {
					Transparency = 0.3,
					Thickness = 1.5
				}):Play()
				return
			end
			TweenService:Create(TabButton, AnimationLib.Presets.HoverOut, {
				BackgroundTransparency = 0.7,
				BackgroundColor3 = SelectedTheme.TabBackground
			}):Play()
			
			TweenService:Create(TabButton.UIStroke, AnimationLib.Presets.HoverOut, {
				Transparency = 0.5,
				Color = SelectedTheme.TabStroke
			}):Play()
			
			TweenService:Create(TabButton.Title, AnimationLib.Presets.HoverOut, {
				TextTransparency = 0.2,
				TextColor3 = SelectedTheme.TabTextColor
			}):Play()
			
			TweenService:Create(TabButton.Image, AnimationLib.Presets.HoverOut, {
				ImageTransparency = 0.2,
				ImageColor3 = SelectedTheme.TabTextColor
			}):Play()
		end)

		local Tab = {}
		
		-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
		-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
		
		function Tab:CreateSection(SectionSettings)
			local sectionName = SectionSettings.Name or "Section"
			local collapsed = SectionSettings.Collapsed or false
			local sectionElements = {}
			
			-- Section header
			local sectionHeader = Instance.new("TextButton")
			sectionHeader.Name = "Section_" .. sectionName
			sectionHeader.Size = UDim2.new(1, 0, 0, 32)
			sectionHeader.BackgroundColor3 = SelectedTheme.SecondaryElementBackground or Color3.fromRGB(30, 30, 35)
			sectionHeader.BackgroundTransparency = 0.3
			sectionHeader.BorderSizePixel = 0
			sectionHeader.Text = ""
			sectionHeader.AutoButtonColor = false
			sectionHeader.Parent = TabPage
			
			local headerCorner = Instance.new("UICorner")
			headerCorner.CornerRadius = UDim.new(0, 6)
			headerCorner.Parent = sectionHeader
			
			local headerIcon = Instance.new("TextLabel")
			headerIcon.Name = "Icon"
			headerIcon.Size = UDim2.new(0, 20, 1, 0)
			headerIcon.Position = UDim2.new(0, 10, 0, 0)
			headerIcon.BackgroundTransparency = 1
			headerIcon.Text = collapsed and "â–¶" or "â–¼"
			headerIcon.TextColor3 = SelectedTheme.TextColor
			headerIcon.TextSize = 10
			headerIcon.Font = Enum.Font.GothamBold
			headerIcon.Parent = sectionHeader
			
			local headerTitle = Instance.new("TextLabel")
			headerTitle.Name = "Title"
			headerTitle.Size = UDim2.new(1, -40, 1, 0)
			headerTitle.Position = UDim2.new(0, 35, 0, 0)
			headerTitle.BackgroundTransparency = 1
			headerTitle.Text = sectionName
			headerTitle.TextColor3 = SelectedTheme.TextColor
			headerTitle.TextSize = 12
			headerTitle.Font = Enum.Font.GothamBold
			headerTitle.TextXAlignment = Enum.TextXAlignment.Left
			headerTitle.Parent = sectionHeader
			
			-- Section container for elements
			local sectionContainer = Instance.new("Frame")
			sectionContainer.Name = "SectionContainer_" .. sectionName
			sectionContainer.Size = UDim2.new(1, 0, 0, 0)
			sectionContainer.BackgroundTransparency = 1
			sectionContainer.ClipsDescendants = true
			sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
			sectionContainer.Visible = not collapsed
			sectionContainer.Parent = TabPage
			
			local containerLayout = Instance.new("UIListLayout")
			containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			containerLayout.Padding = UDim.new(0, 5)
			containerLayout.Parent = sectionContainer
			
			local containerPadding = Instance.new("UIPadding")
			containerPadding.PaddingLeft = UDim.new(0, 10)
			containerPadding.PaddingTop = UDim.new(0, 5)
			containerPadding.PaddingBottom = UDim.new(0, 5)
			containerPadding.Parent = sectionContainer
			
			-- Toggle collapse
			local function toggleCollapse()
				collapsed = not collapsed
				
				if collapsed then
					TweenService:Create(headerIcon, TweenInfo.new(0.2), {
						Rotation = -90
					}):Play()
					TweenService:Create(sectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, 0, 0, 0)
					}):Play()
					task.delay(0.3, function()
						sectionContainer.Visible = false
					end)
				else
					sectionContainer.Visible = true
					TweenService:Create(headerIcon, TweenInfo.new(0.2), {
						Rotation = 0
					}):Play()
					sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
				end
			end
			
			sectionHeader.MouseButton1Click:Connect(toggleCollapse)
			
			-- Hover effect
			sectionHeader.MouseEnter:Connect(function()
				TweenService:Create(sectionHeader, TweenInfo.new(0.15), {
					BackgroundTransparency = 0.1
				}):Play()
			end)
			
			sectionHeader.MouseLeave:Connect(function()
				TweenService:Create(sectionHeader, TweenInfo.new(0.15), {
					BackgroundTransparency = 0.3
				}):Play()
			end)
			
			-- Return section object with methods to add elements
			local Section = {}
			Section.Container = sectionContainer
			Section.Header = sectionHeader
			
			function Section:Collapse()
				if not collapsed then toggleCollapse() end
			end
			
			function Section:Expand()
				if collapsed then toggleCollapse() end
			end
			
			function Section:Toggle()
				toggleCollapse()
			end
			
			-- Register for search
			registerElement(Name, sectionName, sectionHeader)
			
			return Section
		end
		
		-- Divider
		function Tab:CreateDivider()
			local divider = Instance.new("Frame")
			divider.Name = "Divider"
			divider.Size = UDim2.new(1, -20, 0, 1)
			divider.Position = UDim2.new(0, 10, 0, 0)
			divider.BackgroundColor3 = SelectedTheme.ElementStroke
			divider.BackgroundTransparency = 0.5
			divider.BorderSizePixel = 0
			divider.Parent = TabPage
			
			return divider
		end
		
		-- Spacer
		function Tab:CreateSpacer(height)
			local spacer = Instance.new("Frame")
			spacer.Name = "Spacer"
			spacer.Size = UDim2.new(1, 0, 0, height or 10)
			spacer.BackgroundTransparency = 1
			spacer.Parent = TabPage
			
			return spacer
		end
		
		-- Label/Paragraph
		function Tab:CreateLabel(text)
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(1, -20, 0, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = SelectedTheme.TextColor
			label.TextSize = 12
			label.Font = Enum.Font.Gotham
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.AutomaticSize = Enum.AutomaticSize.Y
			label.Parent = TabPage
			
			local LabelObj = {}
			function LabelObj:Set(newText)
				label.Text = newText
			end
			
			return LabelObj
		end

		-- Button
		function Tab:CreateButton(ButtonSettings)
			local ButtonValue = {}

			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Name
			Button.Visible = true
			-- Hide the old ElementIndicator
			if Button:FindFirstChild("ElementIndicator") then
				Button.ElementIndicator.Visible = false
			end
			
			-- Reset for UIListLayout
			Button.AnchorPoint = Vector2.new(0, 0)
			Button.Position = UDim2.new(0, 0, 0, 0)
			Button.Size = UDim2.new(1, 0, 0, 42)
			Button.BackgroundColor3 = SelectedTheme.ElementBackground
			Button.BackgroundTransparency = 0.3
			Button.Title.Text = ButtonSettings.Name
			Button.Title.Font = Enum.Font.GothamMedium
			Button.Title.TextSize = 13
			Button.Title.TextColor3 = SelectedTheme.TextColor
			Button.Title.TextXAlignment = Enum.TextXAlignment.Left
			Button.Title.Position = UDim2.new(0, 15, 0.5, 0)
			Button.Title.AnchorPoint = Vector2.new(0, 0.5)
			Button.Title.Size = UDim2.new(1, -50, 1, 0)
			
			-- Custom corner radius - more subtle
			local buttonCorner = Button:FindFirstChild('UICorner') or Instance.new('UICorner')
			buttonCorner.CornerRadius = UDim.new(0, 8)
			buttonCorner.Parent = Button
			
			-- Custom stroke - thin accent line on left
			if Button:FindFirstChild('UIStroke') then
				Button.UIStroke:Destroy()
			end
			
			-- Left accent bar
			local accentBar = Instance.new("Frame")
			accentBar.Name = "AccentBar"
			accentBar.Parent = Button
			accentBar.AnchorPoint = Vector2.new(0, 0.5)
			accentBar.Position = UDim2.new(0, 0, 0.5, 0)
			accentBar.Size = UDim2.new(0, 3, 0.6, 0)
			accentBar.BackgroundColor3 = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
			accentBar.BackgroundTransparency = 0.3
			accentBar.BorderSizePixel = 0
			
			local accentCorner = Instance.new("UICorner")
			accentCorner.CornerRadius = UDim.new(0, 2)
			accentCorner.Parent = accentBar
			
			-- Right arrow indicator
			local arrowLabel = Instance.new("TextLabel")
			arrowLabel.Name = "Arrow"
			arrowLabel.Parent = Button
			arrowLabel.AnchorPoint = Vector2.new(1, 0.5)
			arrowLabel.Position = UDim2.new(1, -12, 0.5, 0)
			arrowLabel.Size = UDim2.new(0, 20, 0, 20)
			arrowLabel.BackgroundTransparency = 1
			arrowLabel.Font = Enum.Font.GothamBold
			arrowLabel.Text = ">"
			arrowLabel.TextSize = 14
			arrowLabel.TextColor3 = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
			arrowLabel.TextTransparency = 0.5
			
			Button.Parent = TabPage
			
			-- Register for search
			registerElement(Name, ButtonSettings.Name, Button)

			-- Entrance animation
			local elementCount = #TabPage:GetChildren()
			local staggerDelay = math.min(elementCount * 0.03, 0.3)
			
			Button.BackgroundTransparency = 1
			Button.Title.TextTransparency = 1
			accentBar.BackgroundTransparency = 1
			arrowLabel.TextTransparency = 1

			task.delay(staggerDelay, function()
				TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()
				TweenService:Create(Button.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
				TweenService:Create(accentBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()
				TweenService:Create(arrowLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 0.5}):Play()
			end)
			local originalButtonSize = Button.Size
			
			Button.Interact.MouseEnter:Connect(function()
				TweenService:Create(Button, AnimationLib.Presets.HoverIn, {
					BackgroundTransparency = 0.1,
					BackgroundColor3 = SelectedTheme.ElementBackgroundHover or SelectedTheme.ElementBackground
				}):Play()
				TweenService:Create(accentBar, AnimationLib.Presets.HoverIn, {
					Size = UDim2.new(0, 4, 0.8, 0), 
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(arrowLabel, AnimationLib.Presets.HoverIn, {
					TextTransparency = 0, 
					Position = UDim2.new(1, -8, 0.5, 0)
				}):Play()
			end)
			
			Button.Interact.MouseLeave:Connect(function()
				TweenService:Create(Button, AnimationLib.Presets.HoverOut, {
					BackgroundTransparency = 0.3,
					BackgroundColor3 = SelectedTheme.ElementBackground
				}):Play()
				TweenService:Create(accentBar, AnimationLib.Presets.HoverOut, {
					Size = UDim2.new(0, 3, 0.6, 0), 
					BackgroundTransparency = 0.3
				}):Play()
				TweenService:Create(arrowLabel, AnimationLib.Presets.HoverOut, {
					TextTransparency = 0.5, 
					Position = UDim2.new(1, -12, 0.5, 0)
				}):Play()
			end)
			Button.Interact.MouseButton1Down:Connect(function()
				TweenService:Create(Button, AnimationLib.Presets.Press, {
					Size = UDim2.new(originalButtonSize.X.Scale * 0.98, originalButtonSize.X.Offset, originalButtonSize.Y.Scale, originalButtonSize.Y.Offset - 2)
				}):Play()
			end)
			
			Button.Interact.MouseButton1Up:Connect(function()
				TweenService:Create(Button, AnimationLib.Presets.Release, {
					Size = originalButtonSize
				}):Play()
			end)

			Button.Interact.MouseButton1Click:Connect(function()
				local Success, Response = pcall(ButtonSettings.Callback)
				if nightuiDestroyed then return end
				
				if not Success then
					TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					Button.Title.Text = "Error"
					print("VeloxLabs | "..ButtonSettings.Name.." Callback Error " ..tostring(Response))
					task.wait(0.5)
					Button.Title.Text = ButtonSettings.Name
					TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				else
					if not ButtonSettings.Ext then
						SaveConfiguration(ButtonSettings.Name..'\n')
					end
					-- Click feedback - subtle pulse effect (no accent bar expansion)
					local clickColor = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
					TweenService:Create(accentBar, TweenInfo.new(0.1), {Size = UDim2.new(0, 5, 1, 0), BackgroundTransparency = 0}):Play()
					TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = clickColor}):Play()
					task.wait(0.15)
					TweenService:Create(accentBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 3, 0.6, 0), BackgroundTransparency = 0.3}):Play()
					TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				end
			end)
			
			-- Theme change listener
			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Button.Title.TextColor3 = SelectedTheme.TextColor
				Button.BackgroundColor3 = SelectedTheme.ElementBackground
				accentBar.BackgroundColor3 = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
				arrowLabel.TextColor3 = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
			end)

			function ButtonValue:Set(NewButton)
				Button.Title.Text = NewButton
				Button.Name = NewButton
			end

			return ButtonValue
		end

		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerSettings) -- by Throit
			ColorPickerSettings.Type = "ColorPicker"
			local ColorPicker = Elements.Template.ColorPicker:Clone()
			local Background = ColorPicker.CPBackground
			local Display = Background.Display
			local Main = Background.MainCP
			local Slider = ColorPicker.ColorSlider
			ColorPicker.ClipsDescendants = true
			ColorPicker.Name = ColorPickerSettings.Name
			ColorPicker.Title.Text = ColorPickerSettings.Name
			ColorPicker.Visible = true
			ColorPicker.AnchorPoint = Vector2.new(0, 0)
			ColorPicker.Position = UDim2.new(0, 0, 0, 0)
			ColorPicker.Size = UDim2.new(1, 0, 0, 45)
			
			ColorPicker.Parent = TabPage
			Background.Size = UDim2.new(0, 39, 0, 22)
			Display.BackgroundTransparency = 0
			Main.MainPoint.ImageTransparency = 1
			ColorPicker.Interact.Size = UDim2.new(1, 0, 1, 0)
			ColorPicker.Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
			ColorPicker.RGB.Position = UDim2.new(0, 17, 0, 70)
			ColorPicker.HexInput.Position = UDim2.new(0, 17, 0, 90)
			Main.ImageTransparency = 1
			Background.BackgroundTransparency = 1

			for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
				if rgbinput:IsA("Frame") then
					rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
					rgbinput.UIStroke.Color = SelectedTheme.InputStroke
				end
			end

			ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
			ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke

			local opened = false 
			local mouse = Players.LocalPlayer:GetMouse()
			Main.Image = "http://www.roblox.com/asset/?id=11415645739"
			local mainDragging = false 
			local sliderDragging = false 
			ColorPicker.Interact.MouseButton1Down:Connect(function()
				task.spawn(function()
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					task.wait(0.2)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end)

				if not opened then
					opened = true 
					TweenService:Create(Background, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 18, 0, 15)}):Play()
					task.wait(0.1)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 120)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 173, 0, 86)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.289, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 40)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 73)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0.574, 0, 1, 0)}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = SelectedTheme ~= NightUILibrary.Theme.Default and 0.25 or 0.1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				else
					opened = false
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 45)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 39, 0, 22)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 70)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 90)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				end

			end)

			UserInputService.InputEnded:Connect(function(input, gameProcessed) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
					mainDragging = false
					sliderDragging = false
				end end)
			Main.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Main.MainPoint.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Slider.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			Slider.SliderPoint.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			local h,s,v = ColorPickerSettings.Color:ToHSV()
			local color = Color3.fromHSV(h,s,v) 
			local hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
			ColorPicker.HexInput.InputBox.Text = hex
			local function setDisplay()
				--Main
				Main.MainPoint.Position = UDim2.new(s,-Main.MainPoint.AbsoluteSize.X/2,1-v,-Main.MainPoint.AbsoluteSize.Y/2)
				Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
				Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
				Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
				--Slider 
				local x = h * Slider.AbsoluteSize.X
				Slider.SliderPoint.Position = UDim2.new(0,x-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
				Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
				local color = Color3.fromHSV(h,s,v) 
				local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
				ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
				ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
				hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
				ColorPicker.HexInput.InputBox.Text = hex
			end
			setDisplay()
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				if not pcall(function()
						local r, g, b = string.match(ColorPicker.HexInput.InputBox.Text, "^#?(%w%w)(%w%w)(%w%w)$")
						local rgbColor = Color3.fromRGB(tonumber(r, 16),tonumber(g, 16), tonumber(b, 16))
						h,s,v = rgbColor:ToHSV()
						hex = ColorPicker.HexInput.InputBox.Text
						setDisplay()
						ColorPickerSettings.Color = rgbColor
					end) 
				then 
					ColorPicker.HexInput.InputBox.Text = hex 
				end
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration()
				end
			end)
			--RGB
			local function rgbBoxes(box,toChange)
				local value = tonumber(box.Text) 
				local color = Color3.fromHSV(h,s,v) 
				local oldR,oldG,oldB = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				local save 
				if toChange == "R" then save = oldR;oldR = value elseif toChange == "G" then save = oldG;oldG = value else save = oldB;oldB = value end
				if value then 
					value = math.clamp(value,0,255)
					h,s,v = Color3.fromRGB(oldR,oldG,oldB):ToHSV()

					setDisplay()
				else 
					box.Text = tostring(save)
				end
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration(ColorPickerSettings.Flag..'\n'..tostring(ColorPickerSettings.Color))
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox,"R")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox,"G")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox,"B")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)

			RunService.RenderStepped:connect(function()
				if mainDragging then 
					local localX = math.clamp(mouse.X-Main.AbsolutePosition.X,0,Main.AbsoluteSize.X)
					local localY = math.clamp(mouse.Y-Main.AbsolutePosition.Y,0,Main.AbsoluteSize.Y)
					Main.MainPoint.Position = UDim2.new(0,localX-Main.MainPoint.AbsoluteSize.X/2,0,localY-Main.MainPoint.AbsoluteSize.Y/2)
					s = localX / Main.AbsoluteSize.X
					v = 1 - (localY / Main.AbsoluteSize.Y)
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
				if sliderDragging then 
					local localX = math.clamp(mouse.X-Slider.AbsolutePosition.X,0,Slider.AbsoluteSize.X)
					h = localX / Slider.AbsoluteSize.X
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Slider.SliderPoint.Position = UDim2.new(0,localX-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
					Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and ColorPickerSettings.Flag then
					NightUILibrary.Flags[ColorPickerSettings.Flag] = ColorPickerSettings
				end
			end

			function ColorPickerSettings:Set(RGBColor)
				ColorPickerSettings.Color = RGBColor
				h,s,v = ColorPickerSettings.Color:ToHSV()
				color = Color3.fromHSV(h,s,v)
				setDisplay()
			end

			ColorPicker.MouseEnter:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			ColorPicker.MouseLeave:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
					if rgbinput:IsA("Frame") then
						rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
						rgbinput.UIStroke.Color = SelectedTheme.InputStroke
					end
				end

				ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
				ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return ColorPickerSettings
		end

		-- Section
		function Tab:CreateSection(SectionName)

			local SectionValue = {}

			if SDone then
				local SectionSpace = Elements.Template.SectionSpacing:Clone()
				SectionSpace.Visible = true
				SectionSpace.Parent = TabPage
			end

			local Section = Elements.Template.SectionTitle:Clone()
			Section.Title.Text = "// " .. string.upper(SectionName)
			Section.Visible = true
			Section.Parent = TabPage
			Section.BackgroundTransparency = 1
			Section.Size = UDim2.new(1, 0, 0, 32)
			local sectionColor = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
			Section.Title.TextColor3 = sectionColor
			Section.Title.Font = Enum.Font.GothamBold
			Section.Title.TextSize = 13
			Section.Title.TextTransparency = 1
			
			-- Add subtle gradient line under section - BIGGER & LONGER
			local sectionLine = Instance.new("Frame")
			sectionLine.Name = "SectionLine"
			sectionLine.Parent = Section
			sectionLine.AnchorPoint = Vector2.new(0.5, 0)
			sectionLine.Position = UDim2.new(0.5, 0, 1, -2)
			sectionLine.Size = UDim2.new(0.85, 0, 0, 3)  -- ðŸ”¥ BIGGER: 85% width, 3px height
			sectionLine.BackgroundColor3 = sectionColor
			sectionLine.BackgroundTransparency = 0.3  -- ðŸ”¥ More visible
			sectionLine.BorderSizePixel = 0
			
			local lineCorner = Instance.new("UICorner")
			lineCorner.CornerRadius = UDim.new(0, 3)
			lineCorner.Parent = sectionLine
			
			local lineGradient = Instance.new("UIGradient")
			lineGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),  -- Fade from dark
				ColorSequenceKeypoint.new(0.3, sectionColor),  -- Theme color
				ColorSequenceKeypoint.new(0.7, sectionColor),  -- Theme color
				ColorSequenceKeypoint.new(1, Color3.new(0.3, 0.3, 0.3))  -- Fade to dark
			})
			lineGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.2, 0.3),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.8, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			})
			lineGradient.Parent = sectionLine
			
			-- Cool animated entrance with line
			sectionLine.Size = UDim2.new(0, 0, 0, 2)
			TweenService:Create(Section.Title, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0.15}):Play()
			TweenService:Create(sectionLine, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = UDim2.new(0.6, 0, 0, 2)}):Play()
			
			-- Animated shimmer effect on line
			task.spawn(function()
				while Section.Parent do
					TweenService:Create(lineGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1, 0)}):Play()
					task.wait(2)
					lineGradient.Offset = Vector2.new(-1, 0)
				end
			end)
			
			-- Listen for theme changes - use theme color
			if NightUI and NightUI.Main then
				NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
					local newColor = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
					Section.Title.TextColor3 = newColor
					sectionLine.BackgroundColor3 = newColor
				end)
			end

			function SectionValue:Set(NewSection)
				Section.Title.Text = "// " .. string.upper(NewSection)
			end

			SDone = true

			return SectionValue
		end

		-- Divider (safe version - creates manually if template doesn't exist)
		function Tab:CreateDivider()
			local DividerValue = {}
			local Divider
			
			-- Try to use template, fallback to manual creation
			if Elements.Template and Elements.Template:FindFirstChild("Divider") then
				Divider = Elements.Template.Divider:Clone()
				Divider.Visible = true
				Divider.Parent = TabPage
				
				if Divider:FindFirstChild("Divider") then
					Divider.Divider.BackgroundTransparency = 1
					TweenService:Create(Divider.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
				end
			else
				-- Manual creation fallback
				Divider = Instance.new("Frame")
				Divider.Name = "Divider"
				Divider.Size = UDim2.new(1, -20, 0, 1)
				Divider.Position = UDim2.new(0, 10, 0, 0)
				Divider.BackgroundColor3 = SelectedTheme.ElementStroke or Color3.fromRGB(60, 60, 60)
				Divider.BackgroundTransparency = 0.5
				Divider.BorderSizePixel = 0
				Divider.Parent = TabPage
			end

			function DividerValue:Set(Value)
				if Divider then
					Divider.Visible = Value
				end
			end

			return DividerValue
		end

		-- Label (safe version with fallback)
		function Tab:CreateLabel(LabelText : string, Icon: number, Color : Color3, IgnoreTheme : boolean)
			local LabelValue = {}
			local Label
			
			-- Try to use template, fallback to manual creation
			if Elements.Template and Elements.Template:FindFirstChild("Label") then
				Label = Elements.Template.Label:Clone()
			else
				-- Manual creation fallback
				Label = Instance.new("Frame")
				Label.Name = "Label"
				Label.Size = UDim2.new(1, -20, 0, 30)
				Label.BackgroundColor3 = SelectedTheme.SecondaryElementBackground or Color3.fromRGB(35, 35, 35)
				Label.BorderSizePixel = 0
				Label.Parent = TabPage
				
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 6)
				corner.Parent = Label
				
				local stroke = Instance.new("UIStroke")
				stroke.Color = SelectedTheme.SecondaryElementStroke or Color3.fromRGB(50, 50, 50)
				stroke.Thickness = 1
				stroke.Parent = Label
				
				local title = Instance.new("TextLabel")
				title.Name = "Title"
				title.Size = UDim2.new(1, -20, 1, 0)
				title.Position = UDim2.new(0, 10, 0, 0)
				title.BackgroundTransparency = 1
				title.Text = LabelText or ""
				title.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(240, 240, 240)
				title.TextSize = 12
				title.Font = Enum.Font.Gotham
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Parent = Label
				
				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.Size = UDim2.new(0, 20, 0, 20)
				icon.Position = UDim2.new(0, 10, 0.5, 0)
				icon.AnchorPoint = Vector2.new(0, 0.5)
				icon.BackgroundTransparency = 1
				icon.Visible = false
				icon.Parent = Label
				
				function LabelValue:Set(NewLabel)
					title.Text = NewLabel
				end
				
				return LabelValue
			end
			Label.Title.Text = LabelText
			Label.Visible = true
			Label.Parent = TabPage

			Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke

			if Icon then
				if typeof(Icon) == 'string' and Icons then
					local asset = getIcon(Icon)

					Label.Icon.Image = 'rbxassetid://'..asset.id
					Label.Icon.ImageRectOffset = asset.imageRectOffset
					Label.Icon.ImageRectSize = asset.imageRectSize
				else
					Label.Icon.Image = getAssetUri(Icon)
				end
			else
				Label.Icon.Image = "rbxassetid://" .. 0
			end

			if Icon and Label:FindFirstChild('Icon') then
				Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
				Label.Title.Size = UDim2.new(1, -100, 0, 14)

				if Icon then
					if typeof(Icon) == 'string' and Icons then
						local asset = getIcon(Icon)

						Label.Icon.Image = 'rbxassetid://'..asset.id
						Label.Icon.ImageRectOffset = asset.imageRectOffset
						Label.Icon.ImageRectSize = asset.imageRectSize
					else
						Label.Icon.Image = getAssetUri(Icon)
					end
				else
					Label.Icon.Image = "rbxassetid://" .. 0
				end

				Label.Icon.Visible = true
			end

			Label.Icon.ImageTransparency = 1
			Label.BackgroundTransparency = 1
			Label.UIStroke.Transparency = 1
			Label.Title.TextTransparency = 1
			Label.Title.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(200, 180, 240)
			
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255)),
				ColorSequenceKeypoint.new(0.5, SelectedTheme.SecondaryElementBackground or Color3.fromRGB(35, 35, 35)),
				ColorSequenceKeypoint.new(1, SelectedTheme.TabBackgroundSelected or Color3.fromRGB(140, 100, 255))
			})
			gradient.Transparency = NumberSequence.new(0.85)
			gradient.Parent = Label
			
			local interact = Instance.new("TextButton")
			interact.Name = "Interact"
			interact.Size = UDim2.new(1, 0, 1, 0)
			interact.BackgroundTransparency = 1
			interact.Text = ""
			interact.ZIndex = 10
			interact.Parent = Label
			
			interact.MouseEnter:Connect(function()
				TweenService:Create(Label, AnimationLib.Presets.HoverIn, {Size = UDim2.new(1, -18, 0, Label.Size.Y.Offset)}):Play()
				TweenService:Create(Label.UIStroke, AnimationLib.Presets.HoverIn, {Transparency = 0.3}):Play()
			end)
			
			interact.MouseLeave:Connect(function()
				TweenService:Create(Label, AnimationLib.Presets.HoverOut, {Size = UDim2.new(1, -20, 0, Label.Size.Y.Offset)}):Play()
				TweenService:Create(Label.UIStroke, AnimationLib.Presets.HoverOut, {Transparency = 0}):Play()
			end)

			TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = Color and 0.8 or 0}):Play()
			TweenService:Create(Label.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = Color and 0.7 or 0}):Play()
			TweenService:Create(Label.Icon, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(Label.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = Color and 0.2 or 0}):Play()	

			function LabelValue:Set(NewLabel, Icon, Color)
				Label.Title.Text = NewLabel

				if Color then
					Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
					Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke
				end

				if Icon and Label:FindFirstChild('Icon') then
					Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
					Label.Title.Size = UDim2.new(1, -100, 0, 14)

					if Icon then
						if typeof(Icon) == 'string' and Icons then
							local asset = getIcon(Icon)

							Label.Icon.Image = 'rbxassetid://'..asset.id
							Label.Icon.ImageRectOffset = asset.imageRectOffset
							Label.Icon.ImageRectSize = asset.imageRectSize
						else
							Label.Icon.Image = getAssetUri(Icon)
						end
					else
						Label.Icon.Image = "rbxassetid://" .. 0
					end

					Label.Icon.Visible = true
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Label.BackgroundColor3 = IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color = IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementStroke
			end)

			return LabelValue
		end

		-- Paragraph with optional FLEX mode
		function Tab:CreateParagraph(ParagraphSettings)
			local ParagraphValue = {}
			local isFlex = ParagraphSettings.Flex or false

			local Paragraph = Elements.Template.Paragraph:Clone()
			Paragraph.Title.Text = ParagraphSettings.Title
			Paragraph.Content.Text = ParagraphSettings.Content
			Paragraph.Visible = true
			Paragraph.AnchorPoint = Vector2.new(0, 0)
			Paragraph.Position = UDim2.new(0, 0, 0, 0)
			
			Paragraph.Parent = TabPage
			Paragraph.Content.TextWrapped = true
			Paragraph.Content.TextSize = 13
			Paragraph.Content.TextXAlignment = Enum.TextXAlignment.Left
			Paragraph.Content.TextYAlignment = Enum.TextYAlignment.Top
			Paragraph.Title.TextSize = 15
			Paragraph.Title.Font = Enum.Font.GothamBold
			Paragraph.Content.Font = Enum.Font.Gotham
			Paragraph.AutomaticSize = Enum.AutomaticSize.Y
			Paragraph.Size = UDim2.new(1, 0, 0, 0)  -- Full width, auto height
			Paragraph.Content.AutomaticSize = Enum.AutomaticSize.Y
			Paragraph.Content.Size = UDim2.new(1, -24, 0, 0)  -- Full width with padding
			Paragraph.Content.Position = UDim2.new(0, 12, 0, 28)  -- Below title with padding
			Paragraph.Title.Size = UDim2.new(1, -24, 0, 22)
			Paragraph.Title.Position = UDim2.new(0, 12, 0, 6)

			Paragraph.BackgroundTransparency = 1
			Paragraph.UIStroke.Transparency = 1
			Paragraph.Title.TextTransparency = 1
			Paragraph.Content.TextTransparency = 1
			
			-- ðŸ”¥ FLEX MODE - ENHANCED STYLING (USES THEME COLORS) ðŸ”¥
			if isFlex then
				-- Get theme colors for flex gradient
				local flexColor1 = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(50, 30, 90)
				local flexColor2 = SelectedTheme.ElementBackground or Color3.fromRGB(30, 20, 60)
				local flexStroke = SelectedTheme.ToggleEnabledStroke or Color3.fromRGB(160, 100, 255)
				local flexStrokeAlt = SelectedTheme.ToggleEnabled or Color3.fromRGB(120, 80, 200)
				local flexGradient = Instance.new("UIGradient")
				flexGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, flexColor1),
					ColorSequenceKeypoint.new(0.5, flexColor2),
					ColorSequenceKeypoint.new(1, flexColor1)
				})
				flexGradient.Rotation = 45
				flexGradient.Parent = Paragraph
				
				-- Animated gradient
				task.spawn(function()
					local rotation = 45
					while Paragraph.Parent do
						rotation = (rotation + 0.5) % 360
						flexGradient.Rotation = rotation
						task.wait(0.05)
					end
				end)
				
				-- Enhanced stroke for flex - USE THEME COLOR
				local flexUIStroke = Paragraph:FindFirstChild("UIStroke")
				if flexUIStroke then
					flexUIStroke.Thickness = 2
					flexUIStroke.Color = flexStroke
					task.spawn(function()
						while Paragraph.Parent and flexUIStroke and flexUIStroke.Parent do
							pcall(function()
								TweenService:Create(flexUIStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
									Color = flexStroke,
									Transparency = 0
								}):Play()
							end)
							task.wait(1.5)
							pcall(function()
								TweenService:Create(flexUIStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
									Color = flexStrokeAlt,
									Transparency = 0.2
								}):Play()
							end)
							task.wait(1.5)
						end
					end)
				end
				local flexTitle = Paragraph:FindFirstChild("Title")
				local flexContent = Paragraph:FindFirstChild("Content")
				if flexTitle then
					flexTitle.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(255, 220, 255)
					flexTitle.Font = Enum.Font.GothamBold
					flexTitle.TextSize = 16
				end
				if flexContent then
					flexContent.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(220, 200, 255)
				end
				
				-- Corner radius
				local flexCorner = Paragraph:FindFirstChild('UICorner') or Instance.new('UICorner')
				flexCorner.CornerRadius = UDim.new(0, 10)
				flexCorner.Parent = Paragraph
			else
				local normalTitle = Paragraph:FindFirstChild("Title")
				local normalContent = Paragraph:FindFirstChild("Content")
				if normalTitle then
					normalTitle.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(200, 180, 240)
				end
				if normalContent then
					normalContent.TextColor3 = SelectedTheme.TextColor or Color3.fromRGB(180, 170, 220)
				end
				
				-- Add corner radius for normal paragraphs too
				local normalCorner = Paragraph:FindFirstChild('UICorner') or Instance.new('UICorner')
				normalCorner.CornerRadius = UDim.new(0, 8)
				normalCorner.Parent = Paragraph
			end
			
			-- Add padding inside paragraph
			local paragraphPadding = Instance.new('UIPadding')
			paragraphPadding.PaddingTop = UDim.new(0, 8)
			paragraphPadding.PaddingBottom = UDim.new(0, 12)
			paragraphPadding.PaddingLeft = UDim.new(0, 0)
			paragraphPadding.PaddingRight = UDim.new(0, 0)
			paragraphPadding.Parent = Paragraph

			Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
			local paraStroke = Paragraph:FindFirstChild("UIStroke")
			if not isFlex and paraStroke then
				paraStroke.Color = SelectedTheme.SecondaryElementStroke
			end

			-- Entrance animation with slide
			local staggerDelay = math.min(#TabPage:GetChildren() * 0.04, 0.4)
			Paragraph.Position = UDim2.new(0.05, 0, 0, 0)
			Paragraph.BackgroundTransparency = 1
			
			task.delay(staggerDelay, function()
				TweenService:Create(Paragraph, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					BackgroundTransparency = isFlex and 0.1 or 0,
					Position = UDim2.new(0, 0, 0, 0)
				}):Play()
				if paraStroke then
					TweenService:Create(paraStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = isFlex and 0 or 0}):Play()
				end
				local paraTitle = Paragraph:FindFirstChild("Title")
				local paraContent = Paragraph:FindFirstChild("Content")
				if paraTitle then
					TweenService:Create(paraTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
				end
				if paraContent then
					TweenService:Create(paraContent, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
				end
			end)

			function ParagraphValue:Set(NewParagraphSettings)
				local titleChild = Paragraph:FindFirstChild('Title')
				local contentChild = Paragraph:FindFirstChild('Content')
				
				if titleChild and NewParagraphSettings.Title then
					titleChild.Text = NewParagraphSettings.Title
				end
				if contentChild and NewParagraphSettings.Content then
					contentChild.Text = NewParagraphSettings.Content
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
				if not isFlex then
					Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke
				end
			end)

			return ParagraphValue
		end

		-- Input
		function Tab:CreateInput(InputSettings)
			local Input = Elements.Template.Input:Clone()
			Input.Name = InputSettings.Name
			Input.Title.Text = InputSettings.Name
			Input.Visible = true
			Input.AnchorPoint = Vector2.new(0, 0)
			Input.Position = UDim2.new(0, 0, 0, 0)
			Input.Size = UDim2.new(1, 0, 0, 48)
			
			Input.Parent = TabPage
			
			-- Register for search
			registerElement(Name, InputSettings.Name, Input)
			Input.BackgroundTransparency = 1
			Input.UIStroke.Transparency = 1
			Input.Title.TextTransparency = 1
			Input.Title.Font = Enum.Font.GothamBold
			Input.Title.TextSize = 13

			Input.InputFrame.InputBox.Text = InputSettings.CurrentValue or ''
			Input.InputFrame.InputBox.Font = Enum.Font.GothamMedium
			Input.InputFrame.InputBox.TextSize = 13
			Input.InputFrame.InputBox.PlaceholderColor3 = SelectedTheme.PlaceholderColor or Color3.fromRGB(120, 120, 120)

			Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke
			
			-- Add corner radius to input frame
			local inputCorner = Input.InputFrame:FindFirstChild('UICorner') or Instance.new('UICorner')
			inputCorner.CornerRadius = UDim.new(0, 8)
			inputCorner.Parent = Input.InputFrame
			
			-- Add subtle gradient to input
			local inputGradient = Instance.new("UIGradient")
			inputGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
			})
			inputGradient.Rotation = 90
			inputGradient.Parent = Input.InputFrame

			TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Input.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Input.InputFrame.InputBox.PlaceholderText = InputSettings.PlaceholderText or "Type here..."
			Input.InputFrame.Size = UDim2.new(0, math.max(Input.InputFrame.InputBox.TextBounds.X + 30, 100), 0, 32)

			Input.InputFrame.InputBox.FocusLost:Connect(function()
				local Success, Response = pcall(function()
					InputSettings.Callback(Input.InputFrame.InputBox.Text)
					InputSettings.CurrentValue = Input.InputFrame.InputBox.Text
				end)

				if not Success then
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Input.Title.Text = "Callback Error"
					print("VeloxLabs | "..InputSettings.Name.." Callback Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
					task.wait(0.5)
					Input.Title.Text = InputSettings.Name
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if InputSettings.RemoveTextAfterFocusLost then
					Input.InputFrame.InputBox.Text = ""
				end

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end)

			Input.MouseEnter:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Input.MouseLeave:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Input.InputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function InputSettings:Set(text)
				Input.InputFrame.InputBox.Text = text
				InputSettings.CurrentValue = text

				local Success, Response = pcall(function()
					InputSettings.Callback(text)
				end)

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and InputSettings.Flag then
					NightUILibrary.Flags[InputSettings.Flag] = InputSettings
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return InputSettings
		end

		-- Dropdown
		function Tab:CreateDropdown(DropdownSettings)
			local Dropdown = Elements.Template.Dropdown:Clone()
			if string.find(DropdownSettings.Name,"closed") then
				Dropdown.Name = "Dropdown"
			else
				Dropdown.Name = DropdownSettings.Name
			end
			Dropdown.Visible = true
			Dropdown.AnchorPoint = Vector2.new(0, 0)
			Dropdown.Position = UDim2.new(0, 0, 0, 0)
			Dropdown.Size = UDim2.new(1, 0, 0, 45)
			Dropdown.BackgroundColor3 = SelectedTheme.ElementBackground
			Dropdown.BackgroundTransparency = 0.3
			
			-- ðŸ”¥ CREATE A NEW TITLE LABEL (don't rely on template) ðŸ”¥
			local existingTitle = Dropdown:FindFirstChild("Title")
			if existingTitle then
				existingTitle:Destroy()  -- Remove old title
			end
			
			local DropdownTitle = Instance.new("TextLabel")
			DropdownTitle.Name = "Title"
			DropdownTitle.Parent = Dropdown
			DropdownTitle.Text = DropdownSettings.Name
			DropdownTitle.Font = Enum.Font.GothamMedium
			DropdownTitle.TextSize = 13
			DropdownTitle.TextColor3 = SelectedTheme.TextColor
			DropdownTitle.TextTransparency = 0
			DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
			DropdownTitle.TextYAlignment = Enum.TextYAlignment.Center
			DropdownTitle.Position = UDim2.new(0, 12, 0, 0)
			DropdownTitle.Size = UDim2.new(0.5, 0, 1, 0)
			DropdownTitle.Visible = true
			DropdownTitle.ZIndex = 15
			DropdownTitle.BackgroundTransparency = 1
			DropdownTitle.BorderSizePixel = 0
			
			-- ðŸ”¥ CREATE SELECTED LABEL (don't rely on template) ðŸ”¥
			local existingSelected = Dropdown:FindFirstChild("Selected")
			if existingSelected then
				existingSelected:Destroy()
			end
			
			local DropdownSelected = Instance.new("TextLabel")
			DropdownSelected.Name = "Selected"
			DropdownSelected.Parent = Dropdown
			DropdownSelected.Font = Enum.Font.Gotham
			DropdownSelected.TextSize = 12
			DropdownSelected.TextColor3 = SelectedTheme.TextColor
			DropdownSelected.TextTransparency = 0.3
			DropdownSelected.TextXAlignment = Enum.TextXAlignment.Right
			DropdownSelected.TextYAlignment = Enum.TextYAlignment.Center
			DropdownSelected.AnchorPoint = Vector2.new(1, 0.5)
			DropdownSelected.Position = UDim2.new(1, -35, 0.5, 0)
			DropdownSelected.Size = UDim2.new(0.4, 0, 0, 20)
			DropdownSelected.Visible = true
			DropdownSelected.ZIndex = 10
			DropdownSelected.BackgroundTransparency = 1
			DropdownSelected.BorderSizePixel = 0
			DropdownSelected.Text = "None"
			
			-- Remove old stroke, add custom corner with theme color
			local dropdownStroke = Dropdown:FindFirstChild('UIStroke')
			if dropdownStroke then
				dropdownStroke.Color = SelectedTheme.ElementStroke
				dropdownStroke.Transparency = 0.5
			end
			local ddCorner = Dropdown:FindFirstChild('UICorner') or Instance.new('UICorner')
			ddCorner.CornerRadius = UDim.new(0, 8)
			ddCorner.Parent = Dropdown
			
			-- Left accent bar - HIDDEN by default, only show on hover
			local ddAccent = Instance.new("Frame")
			ddAccent.Name = "AccentBar"
			ddAccent.Parent = Dropdown
			ddAccent.AnchorPoint = Vector2.new(0, 0.5)
			ddAccent.Position = UDim2.new(0, 0, 0.5, 0)
			ddAccent.Size = UDim2.new(0, 3, 0.6, 0)
			ddAccent.BackgroundColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
			ddAccent.BackgroundTransparency = 1  -- Start hidden
			ddAccent.BorderSizePixel = 0
			ddAccent.ZIndex = 5
			local ddAccentCorner = Instance.new("UICorner")
			ddAccentCorner.CornerRadius = UDim.new(0, 2)
			ddAccentCorner.Parent = ddAccent
			local DropdownToggle = Dropdown:FindFirstChild("Toggle")
			if not DropdownToggle then
				DropdownToggle = Instance.new("ImageLabel")
				DropdownToggle.Name = "Toggle"
				DropdownToggle.Parent = Dropdown
				DropdownToggle.Image = "rbxassetid://6031091004"  -- Arrow icon
				DropdownToggle.BackgroundTransparency = 1
			end
			
			-- Toggle arrow styling
			DropdownToggle.AnchorPoint = Vector2.new(1, 0.5)
			DropdownToggle.Position = UDim2.new(1, -10, 0.5, 0)
			DropdownToggle.Size = UDim2.new(0, 16, 0, 16)
			DropdownToggle.ImageColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
			DropdownToggle.ImageTransparency = 0.3
			DropdownToggle.Rotation = 180
			local DropdownInteract = Dropdown:FindFirstChild("Interact")
			if not DropdownInteract then
				DropdownInteract = Instance.new("TextButton")
				DropdownInteract.Name = "Interact"
				DropdownInteract.Parent = Dropdown
				DropdownInteract.Size = UDim2.new(1, 0, 1, 0)
				DropdownInteract.BackgroundTransparency = 1
				DropdownInteract.Text = ""
				DropdownInteract.ZIndex = 5
			end
			
			Dropdown.Parent = TabPage
			
			-- Register for search
			registerElement(Name, DropdownSettings.Name, Dropdown)
			local DropdownList = Dropdown:FindFirstChild("List")
			if not DropdownList then
				DropdownList = Instance.new("ScrollingFrame")
				DropdownList.Name = "List"
				DropdownList.Parent = Dropdown
				DropdownList.BackgroundColor3 = SelectedTheme.Background
				DropdownList.BackgroundTransparency = 0
				DropdownList.BorderSizePixel = 0
				DropdownList.ScrollBarThickness = 3
				DropdownList.ScrollBarImageColor3 = SelectedTheme.TextColor
				DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
				DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
				
				local listCorner = Instance.new("UICorner")
				listCorner.CornerRadius = UDim.new(0, 6)
				listCorner.Parent = DropdownList
				
				local listStroke = Instance.new("UIStroke")
				listStroke.Color = SelectedTheme.ElementStroke
				listStroke.Transparency = 0.3
				listStroke.Parent = DropdownList
				
				local listLayout = Instance.new("UIListLayout")
				listLayout.Padding = UDim.new(0, 2)
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Parent = DropdownList
				
				local listPadding = Instance.new("UIPadding")
				listPadding.PaddingTop = UDim.new(0, 4)
				listPadding.PaddingBottom = UDim.new(0, 4)
				listPadding.PaddingLeft = UDim.new(0, 4)
				listPadding.PaddingRight = UDim.new(0, 4)
				listPadding.Parent = DropdownList
			end

			-- Fix dropdown selection: Ensure list is above the main interact button
			DropdownList.ZIndex = 100
			DropdownList.Visible = false
			DropdownList.BackgroundColor3 = SelectedTheme.Background
			DropdownList.BackgroundTransparency = 0
			DropdownList.AnchorPoint = Vector2.new(0, 0)
			DropdownList.Position = UDim2.new(0, 0, 0, 47)  -- Fixed position from top
			DropdownList.Size = UDim2.new(1, 0, 0, 120)     -- Fixed height for dropdown list
			DropdownList.ClipsDescendants = true
			local listStroke = DropdownList:FindFirstChild("UIStroke")
			if listStroke then
				listStroke.Color = SelectedTheme.ElementStroke
				listStroke.Transparency = 0.3
			end
			
			-- Keep original list layout - don't add new one
			-- Just ensure proper canvas size for scrolling
			if DropdownList:IsA('ScrollingFrame') then
				DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
				DropdownList.ScrollBarThickness = 3
			end
			if DropdownSettings.CurrentOption then
				if type(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end
				if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end
			else
				DropdownSettings.CurrentOption = {}
			end

			if DropdownSettings.MultipleOptions then
				if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
					if #DropdownSettings.CurrentOption == 1 then
						DropdownSelected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						DropdownSelected.Text = "None"
					else
						DropdownSelected.Text = "Various"
					end
				else
					DropdownSettings.CurrentOption = {}
					DropdownSelected.Text = "None"
				end
			else
				DropdownSelected.Text = DropdownSettings.CurrentOption[1] or "None"
			end

			DropdownToggle.ImageColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
			DropdownSelected.TextColor3 = SelectedTheme.TextColor
			
			-- Entrance animation for custom design - BUT KEEP TITLE VISIBLE!
			Dropdown.BackgroundTransparency = 1
			-- DON'T hide title - it should always be visible
			DropdownTitle.TextTransparency = 0
			DropdownTitle.Visible = true
			ddAccent.BackgroundTransparency = 1
			
			TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()
			-- Title stays visible, no tween needed
			TweenService:Create(ddAccent, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()	

			for _, ununusedoption in ipairs(DropdownList:GetChildren()) do
				if ununusedoption.ClassName == "Frame" and ununusedoption.Name ~= "Placeholder" then
					ununusedoption:Destroy()
				end
			end

			DropdownToggle.Rotation = 180

			DropdownInteract.MouseButton1Click:Connect(function()
				-- ðŸ”¥ CLICK FEEDBACK
				TweenService:Create(Dropdown, AnimationLib.Presets.Press, {BackgroundTransparency = 0.1}):Play()
				TweenService:Create(ddAccent, AnimationLib.Presets.Press, {Size = UDim2.new(0, 4, 0.8, 0)}):Play()
				task.wait(0.08)
				TweenService:Create(Dropdown, AnimationLib.Presets.Release, {BackgroundTransparency = 0.3}):Play()
				
				if Debounce then return end
				if DropdownList.Visible then
					-- ðŸ”¥ SMOOTH COLLAPSE
					Debounce = true
					TweenService:Create(Dropdown, AnimationLib.Presets.DropdownCollapse, {Size = UDim2.new(1, 0, 0, 45)}):Play()
					
					-- Fade out options
					for _, DropdownOpt in ipairs(DropdownList:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							TweenService:Create(DropdownOpt, AnimationLib.Presets.DropdownFade, {BackgroundTransparency = 1}):Play()
							local optStroke = DropdownOpt:FindFirstChild("UIStroke")
							if optStroke then
								TweenService:Create(optStroke, AnimationLib.Presets.DropdownFade, {Transparency = 1}):Play()
							end
							local optTitle = DropdownOpt:FindFirstChild("Title")
							if optTitle then
								TweenService:Create(optTitle, AnimationLib.Presets.DropdownFade, {TextTransparency = 1}):Play()
							end
						end
					end
					TweenService:Create(DropdownList, AnimationLib.Presets.DropdownFade, {ScrollBarImageTransparency = 1}):Play()
					TweenService:Create(DropdownToggle, AnimationLib.Presets.DropdownCollapse, {Rotation = 180}):Play()
					task.wait(0.25)
					DropdownList.Visible = false
					Debounce = false
				else
					-- SMOOTH DROPDOWN EXPAND
					TweenService:Create(Dropdown, AnimationLib.Presets.DropdownExpand, {Size = UDim2.new(1, 0, 0, 180)}):Play()
					DropdownList.Visible = true
					TweenService:Create(DropdownList, AnimationLib.Presets.DropdownFade, {ScrollBarImageTransparency = 0.7}):Play()
					TweenService:Create(DropdownToggle, AnimationLib.Presets.Spring, {Rotation = 0}):Play()
					
					-- Staggered fade-in for options
					local optionIndex = 0
					for _, DropdownOpt in ipairs(DropdownList:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							optionIndex = optionIndex + 1
							local optStroke = DropdownOpt:FindFirstChild("UIStroke")
							
							-- Start invisible
							DropdownOpt.BackgroundTransparency = 1
							local optTitle = DropdownOpt:FindFirstChild("Title")
							if optTitle then optTitle.TextTransparency = 1 end
							
							-- Staggered animation
							task.delay(optionIndex * 0.03, function()
								if DropdownOpt.Name ~= DropdownSelected.Text and optStroke then
									TweenService:Create(optStroke, AnimationLib.Presets.DropdownFade, {Transparency = 0}):Play()
								end
								TweenService:Create(DropdownOpt, AnimationLib.Presets.DropdownFade, {BackgroundTransparency = 0}):Play()
								if optTitle then
									TweenService:Create(optTitle, AnimationLib.Presets.DropdownFade, {TextTransparency = 0}):Play()
								end
							end)
						end
					end
				end
			end)
			Dropdown.MouseEnter:Connect(function()
				if not DropdownList.Visible then
					TweenService:Create(Dropdown, AnimationLib.Presets.HoverIn, {
						BackgroundColor3 = SelectedTheme.ElementBackgroundHover,
						BackgroundTransparency = 0.1
					}):Play()
					-- Accent bar grows
					local accentBar = Dropdown:FindFirstChild("AccentBar")
					if accentBar then
						TweenService:Create(accentBar, AnimationLib.Presets.HoverIn, {
							Size = UDim2.new(0, 4, 0.8, 0),
							BackgroundTransparency = 0
						}):Play()
					end
				end
			end)

			Dropdown.MouseLeave:Connect(function()
				TweenService:Create(Dropdown, AnimationLib.Presets.HoverOut, {
					BackgroundColor3 = SelectedTheme.ElementBackground,
					BackgroundTransparency = 0.3
				}):Play()
				-- Accent bar shrinks
				local accentBar = Dropdown:FindFirstChild("AccentBar")
				if accentBar then
					TweenService:Create(accentBar, AnimationLib.Presets.HoverOut, {
						Size = UDim2.new(0, 3, 0.6, 0),
						BackgroundTransparency = 0.3
					}):Play()
				end
			end)
			
			-- Listen for theme changes to update dropdown colors
			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				DropdownTitle.TextColor3 = SelectedTheme.TextColor
				DropdownSelected.TextColor3 = SelectedTheme.TextColor
				DropdownToggle.ImageColor3 = SelectedTheme.TextColor
			end)

			local function SetDropdownOptions()
				for _, Option in ipairs(DropdownSettings.Options) do
					-- ðŸ”¥ CREATE OPTION FROM SCRATCH (don't rely on template) ðŸ”¥
					local DropdownOption = Instance.new("Frame")
					DropdownOption.Name = Option
					DropdownOption.Parent = DropdownList
					DropdownOption.Size = UDim2.new(1, 0, 0, 30)
					DropdownOption.BackgroundColor3 = SelectedTheme.ElementBackground
					DropdownOption.BackgroundTransparency = 0
					DropdownOption.BorderSizePixel = 0
					DropdownOption.Visible = true
					DropdownOption.ZIndex = 101
					
					local optCorner = Instance.new("UICorner")
					optCorner.CornerRadius = UDim.new(0, 4)
					optCorner.Parent = DropdownOption
					
					local optStroke = Instance.new("UIStroke")
					optStroke.Name = "UIStroke"
					optStroke.Color = SelectedTheme.ElementStroke
					optStroke.Transparency = 0.5
					optStroke.Parent = DropdownOption
					
					local optTitle = Instance.new("TextLabel")
					optTitle.Name = "Title"
					optTitle.Parent = DropdownOption
					optTitle.Text = Option
					optTitle.Font = Enum.Font.Gotham
					optTitle.TextSize = 12
					optTitle.TextColor3 = SelectedTheme.TextColor
					optTitle.BackgroundTransparency = 1
					optTitle.Size = UDim2.new(1, -10, 1, 0)
					optTitle.Position = UDim2.new(0, 10, 0, 0)
					optTitle.TextXAlignment = Enum.TextXAlignment.Left
					optTitle.ZIndex = 102
					
					local optInteract = Instance.new("TextButton")
					optInteract.Name = "Interact"
					optInteract.Parent = DropdownOption
					optInteract.Size = UDim2.new(1, 0, 1, 0)
					optInteract.BackgroundTransparency = 1
					optInteract.Text = ""
					optInteract.ZIndex = 103
					
					optInteract.MouseButton1Click:Connect(function()
						if not DropdownSettings.MultipleOptions and table.find(DropdownSettings.CurrentOption, Option) then 
							return
						end

						if table.find(DropdownSettings.CurrentOption, Option) then
							table.remove(DropdownSettings.CurrentOption, table.find(DropdownSettings.CurrentOption, Option))
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									DropdownSelected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									DropdownSelected.Text = "None"
								else
									DropdownSelected.Text = "Various"
								end
							else
								DropdownSelected.Text = DropdownSettings.CurrentOption[1]
							end
						else
							if not DropdownSettings.MultipleOptions then
								table.clear(DropdownSettings.CurrentOption)
							end
							table.insert(DropdownSettings.CurrentOption, Option)
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									DropdownSelected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									DropdownSelected.Text = "None"
								else
									DropdownSelected.Text = "Various"
								end
							else
								DropdownSelected.Text = DropdownSettings.CurrentOption[1]
							end
							TweenService:Create(optStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(DropdownOption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownSelected}):Play()
							Debounce = true
						end


						local Success, Response = pcall(function()
							DropdownSettings.Callback(DropdownSettings.CurrentOption)
						end)

						if not Success then
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
							local ddStroke = Dropdown:FindFirstChild("UIStroke")
							if ddStroke then
								TweenService:Create(ddStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							end
							DropdownTitle.Text = "Callback Error"
							print("VeloxLabs | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
							warn('Contact VeloxLabs for help.')
							task.wait(0.5)
							DropdownTitle.Text = DropdownSettings.Name
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							if ddStroke then
								TweenService:Create(ddStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end
						end

						for _, droption in ipairs(DropdownList:GetChildren()) do
							if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" and not table.find(DropdownSettings.CurrentOption, droption.Name) then
								TweenService:Create(droption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownUnselected}):Play()
							end
						end
						if not DropdownSettings.MultipleOptions then
							task.wait(0.1)
							TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 45)}):Play()
							for _, DropdownOpt in ipairs(DropdownList:GetChildren()) do
								if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
									TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
									local optStroke = DropdownOpt:FindFirstChild("UIStroke")
									if optStroke then
										TweenService:Create(optStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									end
									local optTitle = DropdownOpt:FindFirstChild("Title")
									if optTitle then
										TweenService:Create(optTitle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
									end
								end
							end
							TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
							TweenService:Create(DropdownToggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()	
							task.wait(0.35)
							DropdownList.Visible = false
						end
						Debounce = false
						if not DropdownSettings.Ext then
							SaveConfiguration()
						end
					end)

					NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
							optStroke.Color = SelectedTheme.ElementStroke
							optTitle.TextColor3 = SelectedTheme.TextColor
							end)
				end
			end
			SetDropdownOptions()

			for _, droption in ipairs(DropdownList:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end

						NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
							if not table.find(DropdownSettings.CurrentOption, droption.Name) then
								droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
							else
								droption.BackgroundColor3 = SelectedTheme.DropdownSelected
							end
						end)
					end
				end

			function DropdownSettings:Set(NewOption)
				DropdownSettings.CurrentOption = NewOption

				if typeof(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end

				if not DropdownSettings.MultipleOptions then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end

				if DropdownSettings.MultipleOptions then
					if #DropdownSettings.CurrentOption == 1 then
						DropdownSelected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						DropdownSelected.Text = "None"
					else
						DropdownSelected.Text = "Various"
					end
				else
					DropdownSelected.Text = DropdownSettings.CurrentOption[1]
				end


				local Success, Response = pcall(function()
					DropdownSettings.Callback(NewOption)
				end)
				if not Success then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					local ddStroke2 = Dropdown:FindFirstChild("UIStroke")
					if ddStroke2 then
						TweenService:Create(ddStroke2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					end
					DropdownTitle.Text = "Callback Error"
					print("VeloxLabs | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
					task.wait(0.5)
					DropdownTitle.Text = DropdownSettings.Name
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					if ddStroke2 then
						TweenService:Create(ddStroke2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
					end
				end

				for _, droption in ipairs(DropdownList:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end
				--SaveConfiguration()
			end

			function DropdownSettings:Refresh(optionsTable: table) -- updates a dropdown with new options from optionsTable
				DropdownSettings.Options = optionsTable
				for _, option in DropdownList:GetChildren() do
					if option.ClassName == "Frame" and option.Name ~= "Placeholder" then
						option:Destroy()
					end
				end
				SetDropdownOptions()
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and DropdownSettings.Flag then
					NightUILibrary.Flags[DropdownSettings.Flag] = DropdownSettings
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				DropdownToggle.ImageColor3 = SelectedTheme.TextColor
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			return DropdownSettings
		end

		-- Keybind
		function Tab:CreateKeybind(KeybindSettings)
			local CheckingForKey = false
			local Keybind = Elements.Template.Keybind:Clone()
			Keybind.Name = KeybindSettings.Name
			Keybind.Title.Text = KeybindSettings.Name
			Keybind.Visible = true
			Keybind.Parent = TabPage
			
			-- Register for search
			registerElement(Name, KeybindSettings.Name, Keybind)

			Keybind.BackgroundTransparency = 1
			Keybind.UIStroke.Transparency = 1
			Keybind.Title.TextTransparency = 1

			Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Keybind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Keybind.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
			Keybind.KeybindFrame.Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)

			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey = true
				Keybind.KeybindFrame.KeybindBox.Text = ""
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey = false
				if Keybind.KeybindFrame.KeybindBox.Text == nil or Keybind.KeybindFrame.KeybindBox.Text == "" then
					Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
					if not KeybindSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			Keybind.MouseEnter:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Keybind.MouseLeave:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if CheckingForKey then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local SplitMessage = string.split(tostring(input.KeyCode), ".")
						local NewKeyNoEnum = SplitMessage[3]
						Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeyNoEnum)
						KeybindSettings.CurrentKeybind = tostring(NewKeyNoEnum)
						Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
						if not KeybindSettings.Ext then
							SaveConfiguration()
						end

						if KeybindSettings.CallOnChange then
							KeybindSettings.Callback(tostring(NewKeyNoEnum))
						end
					end
				elseif not KeybindSettings.CallOnChange and KeybindSettings.CurrentKeybind ~= nil and (input.KeyCode == Enum.KeyCode[KeybindSettings.CurrentKeybind] and not processed) then -- Test
					local Held = true
					local Connection
					Connection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							Connection:Disconnect()
							Held = false
						end
					end)

					if not KeybindSettings.HoldToInteract then
						local Success, Response = pcall(KeybindSettings.Callback)
						if not Success then
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Keybind.Title.Text = "Callback Error"
							print("NightUI | "..KeybindSettings.Name.." Callback Error " ..tostring(Response))
							warn('Contact VeloxLabs for help.')
							task.wait(0.5)
							Keybind.Title.Text = KeybindSettings.Name
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
						end
					else
						task.wait(0.25)
						if Held then
							local Loop; Loop = RunService.Stepped:Connect(function()
								if not Held then
									KeybindSettings.Callback(false) -- maybe pcall this
									Loop:Disconnect()
								else
									KeybindSettings.Callback(true) -- maybe pcall this
								end
							end)
						end
					end
				end
			end)

			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Keybind.KeybindFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function KeybindSettings:Set(NewKeybind)
				Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeybind)
				KeybindSettings.CurrentKeybind = tostring(NewKeybind)
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindSettings.Ext then
					SaveConfiguration()
				end

				if KeybindSettings.CallOnChange then
					KeybindSettings.Callback(tostring(NewKeybind))
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and KeybindSettings.Flag then
					NightUILibrary.Flags[KeybindSettings.Flag] = KeybindSettings
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return KeybindSettings
		end

		-- Toggle
		function Tab:CreateToggle(ToggleSettings)
			local ToggleValue = {}

			local Toggle = Elements.Template.Toggle:Clone()
			Toggle.Name = ToggleSettings.Name
			Toggle.Visible = true
			Toggle.AnchorPoint = Vector2.new(0, 0)
			Toggle.Position = UDim2.new(0, 0, 0, 0)
			Toggle.Size = UDim2.new(1, 0, 0, 42)
			Toggle.BackgroundColor3 = SelectedTheme.ElementBackground
			Toggle.BackgroundTransparency = 0.3
			
			-- Custom title styling
			Toggle.Title.Text = ToggleSettings.Name
			Toggle.Title.Font = Enum.Font.GothamMedium
			Toggle.Title.TextSize = 13
			Toggle.Title.TextColor3 = SelectedTheme.TextColor
			Toggle.Title.TextXAlignment = Enum.TextXAlignment.Left
			Toggle.Title.Position = UDim2.new(0, 15, 0.5, 0)
			Toggle.Title.AnchorPoint = Vector2.new(0, 0.5)
			Toggle.Title.Size = UDim2.new(1, -70, 1, 0)
			
			-- Remove old stroke
			if Toggle:FindFirstChild('UIStroke') then
				Toggle.UIStroke.Transparency = 1
			end
			local tglCorner = Toggle:FindFirstChild('UICorner') or Instance.new('UICorner')
			tglCorner.CornerRadius = UDim.new(0, 8)
			tglCorner.Parent = Toggle
			
			-- Left accent bar
			local tglAccent = Instance.new("Frame")
			tglAccent.Name = "AccentBar"
			tglAccent.Parent = Toggle
			tglAccent.AnchorPoint = Vector2.new(0, 0.5)
			tglAccent.Position = UDim2.new(0, 0, 0.5, 0)
			tglAccent.Size = UDim2.new(0, 3, 0.6, 0)
			tglAccent.BackgroundColor3 = ToggleSettings.CurrentValue and (SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)) or Color3.fromRGB(100, 100, 100)
			tglAccent.BackgroundTransparency = 0.3
			tglAccent.BorderSizePixel = 0
			tglAccent.ZIndex = 5
			local tglAccentCorner = Instance.new("UICorner")
			tglAccentCorner.CornerRadius = UDim.new(0, 2)
			tglAccentCorner.Parent = tglAccent
			
			-- Custom switch styling - more compact
			Toggle.Switch.AnchorPoint = Vector2.new(1, 0.5)
			Toggle.Switch.Position = UDim2.new(1, -12, 0.5, 0)
			Toggle.Switch.Size = UDim2.new(0, 38, 0, 20)
			Toggle.Switch.BackgroundColor3 = ToggleSettings.CurrentValue and SelectedTheme.ToggleEnabled or SelectedTheme.ToggleBackground
			Toggle.Switch.BackgroundTransparency = 0.2
			if Toggle.Switch:FindFirstChild('Shadow') then
				Toggle.Switch.Shadow.Visible = false
			end
			if Toggle.Switch:FindFirstChild('UIStroke') then
				Toggle.Switch.UIStroke.Transparency = 0.5
				Toggle.Switch.UIStroke.Color = ToggleSettings.CurrentValue and SelectedTheme.ToggleEnabledStroke or SelectedTheme.ToggleDisabledStroke
			end
			
			-- Custom indicator (the dot)
			Toggle.Switch.Indicator.Size = UDim2.new(0, 14, 0, 14)
			Toggle.Switch.Indicator.AnchorPoint = Vector2.new(0, 0.5)
			if Toggle.Switch.Indicator:FindFirstChild('UIStroke') then
				Toggle.Switch.Indicator.UIStroke.Thickness = 1
			end
			
			Toggle.Parent = TabPage
			
			-- Register for search
			registerElement(Name, ToggleSettings.Name, Toggle)

			-- Entrance animation
			local elementCount = #TabPage:GetChildren()
			local staggerDelay = math.min(elementCount * 0.03, 0.3)
			
			Toggle.BackgroundTransparency = 1
			Toggle.Title.TextTransparency = 1
			tglAccent.BackgroundTransparency = 1

			task.delay(staggerDelay, function()
				TweenService:Create(Toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()
				TweenService:Create(Toggle.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
				TweenService:Create(tglAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()
			end)	

			if ToggleSettings.CurrentValue == true then
				Toggle.Switch.Indicator.Position = UDim2.new(1, -17, 0.5, 0)
				Toggle.Switch.Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
			else
				Toggle.Switch.Indicator.Position = UDim2.new(0, 3, 0.5, 0)
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
			end
			Toggle.MouseEnter:Connect(function()
				TweenService:Create(Toggle, AnimationLib.Presets.HoverIn, {
					BackgroundTransparency = 0.1,
					BackgroundColor3 = SelectedTheme.ElementBackgroundHover or SelectedTheme.ElementBackground
				}):Play()
				TweenService:Create(tglAccent, AnimationLib.Presets.HoverIn, {
					Size = UDim2.new(0, 4, 0.8, 0), 
					BackgroundTransparency = 0
				}):Play()
			end)

			Toggle.MouseLeave:Connect(function()
				TweenService:Create(Toggle, AnimationLib.Presets.HoverOut, {
					BackgroundTransparency = 0.3,
					BackgroundColor3 = SelectedTheme.ElementBackground
				}):Play()
				TweenService:Create(tglAccent, AnimationLib.Presets.HoverOut, {
					Size = UDim2.new(0, 3, 0.6, 0), 
					BackgroundTransparency = 0.3
				}):Play()
			end)

			Toggle.Interact.MouseButton1Click:Connect(function()
				if ToggleSettings.CurrentValue == true then
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle.Switch.Indicator, AnimationLib.Presets.ToggleSlide, {
						Position = UDim2.new(0, 3, 0.5, 0)
					}):Play()
					TweenService:Create(Toggle.Switch.Indicator, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = SelectedTheme.ToggleDisabled
					}):Play()
					TweenService:Create(Toggle.Switch, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = SelectedTheme.ToggleBackground
					}):Play()
					TweenService:Create(tglAccent, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = SelectedTheme.ToggleDisabled or Color3.fromRGB(100, 100, 100)
					}):Play()
					if Toggle.Switch:FindFirstChild('UIStroke') then
						TweenService:Create(Toggle.Switch.UIStroke, AnimationLib.Presets.ToggleColor, {
							Color = SelectedTheme.ToggleDisabledStroke
						}):Play()
					end
				else
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle.Switch.Indicator, AnimationLib.Presets.ToggleSlide, {
						Position = UDim2.new(1, -17, 0.5, 0)
					}):Play()
					TweenService:Create(Toggle.Switch.Indicator, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = Color3.new(1, 1, 1)
					}):Play()
					TweenService:Create(Toggle.Switch, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = SelectedTheme.ToggleEnabled
					}):Play()
					TweenService:Create(tglAccent, AnimationLib.Presets.ToggleColor, {
						BackgroundColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
					}):Play()
					if Toggle.Switch:FindFirstChild('UIStroke') then
						TweenService:Create(Toggle.Switch.UIStroke, AnimationLib.Presets.ToggleColor, {
							Color = SelectedTheme.ToggleEnabledStroke
						}):Play()
					end
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (Interact)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("NightUI | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end)

			function ToggleSettings:Set(NewToggleValue)
				if NewToggleValue == true then
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()	
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				else
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (:Set)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("NightUI | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end

			if not ToggleSettings.Ext then
				if Settings.ConfigurationSaving then
					if Settings.ConfigurationSaving.Enabled and ToggleSettings.Flag then
						NightUILibrary.Flags[ToggleSettings.Flag] = ToggleSettings
					end
				end
			end


			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

				if SelectedTheme ~= NightUILibrary.Theme.Default then
					Toggle.Switch.Shadow.Visible = false
				end

				task.wait()

				if not ToggleSettings.CurrentValue then
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
				else
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
				end
			end)

			return ToggleSettings
		end

		-- Slider
		function Tab:CreateSlider(SliderSettings)
			local SLDragging = false
			local Slider = Elements.Template.Slider:Clone()
			
			-- Base slider container
			Slider.Name = SliderSettings.Name
			Slider.Visible = true
			Slider.Parent = TabPage
			Slider.Size = UDim2.new(1, 0, 0, 50)  -- increased height for title + rail
			Slider.BackgroundColor3 = SelectedTheme.ElementBackground
			Slider.BackgroundTransparency = 0.3
			
			-- Main slider bar (bottom)
			if Slider.Main then
				Slider.Main.Size = UDim2.new(1, -24, 0, 8)
				Slider.Main.Position = UDim2.new(0, 12, 1, -8)  -- slightly lower for more space below title
				Slider.Main.AnchorPoint = Vector2.new(0, 1)
				Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground or Color3.fromRGB(40, 40, 45)
				
				if Slider.Main:FindFirstChild('Interact') then
					Slider.Main.Interact.Size = UDim2.new(1, 0, 1, 0)
					Slider.Main.Interact.Position = UDim2.new(0, 0, 0, 0)
				end
			end
			
			-- Register for search
			registerElement(Name, SliderSettings.Name, Slider)
			
			-- Title (top-left)
			Slider.Title.Position = UDim2.new(0, 12, 0, 8)
			Slider.Title.AnchorPoint = Vector2.new(0, 0)
			Slider.Title.Size = UDim2.new(0.6, 0, 0, 20)
			Slider.Title.Text = SliderSettings.Name
			Slider.Title.Font = Enum.Font.GothamBold
			Slider.Title.TextSize = 13
			Slider.Title.TextColor3 = SelectedTheme.TextColor
			Slider.Title.TextXAlignment = Enum.TextXAlignment.Left
			
			-- Information label (top-right, above rail)
			local sliderInfo = Slider:FindFirstChild('Information') or (Slider.Main and Slider.Main:FindFirstChild('Information'))
			if not sliderInfo then
				sliderInfo = Instance.new('TextLabel')
				sliderInfo.Name = 'Information'
				sliderInfo.Parent = Slider
				sliderInfo.Font = Enum.Font.GothamMedium
				sliderInfo.TextSize = 13
				sliderInfo.BackgroundTransparency = 1
			end
			-- Wert oben rechts auf einer Linie mit dem Titel
			sliderInfo.Parent = Slider
			sliderInfo.AnchorPoint = Vector2.new(1, 0)
			sliderInfo.Position = UDim2.new(1, -12, 0, 8)
			sliderInfo.Size = UDim2.new(0, 80, 0, 20)
			sliderInfo.TextColor3 = SelectedTheme.TextColor
			sliderInfo.TextXAlignment = Enum.TextXAlignment.Right
			sliderInfo.TextTransparency = 0
			sliderInfo.ZIndex = (Slider.ZIndex or 1) + 1
			
			-- Hide shadows/strokes to match theme
			if Slider.Main:FindFirstChild('Shadow') then
				Slider.Main.Shadow.Visible = false
			end
			if Slider.Main:FindFirstChild('UIStroke') then
				Slider.Main.UIStroke.Transparency = 1
			end
			if Slider.Main.Progress:FindFirstChild('UIStroke') then
				Slider.Main.Progress.UIStroke.Transparency = 1
			end
			
			-- Initial progress size/color
			local initialProgress = (SliderSettings.CurrentValue - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])
			if Slider.Main and Slider.Main:FindFirstChild('Progress') then
				Slider.Main.Progress.Size = UDim2.new(initialProgress, 0, 1, 0)
				Slider.Main.Progress.BackgroundColor3 = SelectedTheme.ToggleEnabled or Color3.fromRGB(140, 100, 255)
			end
			
			if not SliderSettings.Suffix then
				sliderInfo.Text = tostring(SliderSettings.CurrentValue)
			else
				sliderInfo.Text = tostring(SliderSettings.CurrentValue) .. " " .. SliderSettings.Suffix
			end

			Slider.MouseEnter:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.1}):Play()
			end)

			Slider.MouseLeave:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.3}):Play()
			end)

			Slider.Main.Interact.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SLDragging = true 
				end 
			end)

			Slider.Main.Interact.InputEnded:Connect(function(Input) 
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SLDragging = false 
				end 
			end)

			Slider.Main.Interact.MouseButton1Down:Connect(function(X)
				local Current = Slider.Main.Progress.AbsolutePosition.X + Slider.Main.Progress.AbsoluteSize.X
				local Start = Current
				local Location = X
				local Loop; Loop = RunService.Stepped:Connect(function()
					if SLDragging then
						Location = UserInputService:GetMouseLocation().X
						Current = Current + 0.025 * (Location - Start)

						if Location < Slider.Main.AbsolutePosition.X then
							Location = Slider.Main.AbsolutePosition.X
						elseif Location > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Location = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current < Slider.Main.AbsolutePosition.X + 5 then
							Current = Slider.Main.AbsolutePosition.X + 5
						elseif Current > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Current = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current <= Location and (Location - Start) < 0 then
							Start = Location
						elseif Current >= Location and (Location - Start) > 0 then
							Start = Location
						end
						TweenService:Create(Slider.Main.Progress, AnimationLib.Presets.SliderDrag, {Size = UDim2.new(0, Current - Slider.Main.AbsolutePosition.X, 1, 0)}):Play()
						local NewValue = SliderSettings.Range[1] + (Location - Slider.Main.AbsolutePosition.X) / Slider.Main.AbsoluteSize.X * (SliderSettings.Range[2] - SliderSettings.Range[1])

						NewValue = math.floor(NewValue / SliderSettings.Increment + 0.5) * (SliderSettings.Increment * 10000000) / 10000000
						NewValue = math.clamp(NewValue, SliderSettings.Range[1], SliderSettings.Range[2])

						if not SliderSettings.Suffix then
							sliderInfo.Text = tostring(NewValue)
						else
							sliderInfo.Text = tostring(NewValue) .. " " .. SliderSettings.Suffix
						end

						if SliderSettings.CurrentValue ~= NewValue then
							local Success, Response = pcall(function()
								SliderSettings.Callback(NewValue)
							end)
							if not Success then
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								Slider.Title.Text = "Callback Error"
								print("NightUI | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
								warn('Contact VeloxLabs for help.')
								task.wait(0.5)
								Slider.Title.Text = SliderSettings.Name
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end

							SliderSettings.CurrentValue = NewValue
							if not SliderSettings.Ext then
								SaveConfiguration()
							end
						end
					else
						TweenService:Create(Slider.Main.Progress, AnimationLib.Presets.SliderSnap, {Size = UDim2.new(0, Location - Slider.Main.AbsolutePosition.X > 5 and Location - Slider.Main.AbsolutePosition.X or 5, 1, 0)}):Play()
						Loop:Disconnect()
					end
				end)
			end)

			function SliderSettings:Set(NewVal)
				local NewVal = math.clamp(NewVal, SliderSettings.Range[1], SliderSettings.Range[2])

				TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Slider.Main.AbsoluteSize.X * ((NewVal + SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Main.AbsoluteSize.X * (NewVal / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)}):Play()
				sliderInfo.Text = tostring(NewVal) .. " " .. (SliderSettings.Suffix or "")

				local Success, Response = pcall(function()
					SliderSettings.Callback(NewVal)
				end)

				if not Success then
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = GetThemeColor(SelectedTheme, "ErrorColor")}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Slider.Title.Text = "Callback Error"
					print("NightUI | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
					warn('Contact VeloxLabs for help.')
					task.wait(0.5)
					Slider.Title.Text = SliderSettings.Name
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				SliderSettings.CurrentValue = NewVal
				if not SliderSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and SliderSettings.Flag then
					NightUILibrary.Flags[SliderSettings.Flag] = SliderSettings
				end
			end

			NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				if SelectedTheme ~= NightUILibrary.Theme.Default then
					Slider.Main.Shadow.Visible = false
				end

				Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
				Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress
			end)

			return SliderSettings
		end

		NightUI.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			TabButton.UIStroke.Color = SelectedTheme.TabStroke

			if Elements.UIPageLayout.CurrentPage == TabPage then
				TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
				TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			else
				TabButton.BackgroundColor3 = SelectedTheme.TabBackground
				TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			end
		end)

		return Tab
	end

	Elements.Visible = true
	task.wait(1.5)  -- Wait for loading to complete
	
	-- Just fade out loading elements smoothly
	if LoadingFrame:FindFirstChild('LoadingTitle') then
		TweenService:Create(LoadingFrame.LoadingTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('LoadingSubtitle') then
		TweenService:Create(LoadingFrame.LoadingSubtitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('PlayerAvatar') then
		TweenService:Create(LoadingFrame.PlayerAvatar, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('PlayerName') then
		TweenService:Create(LoadingFrame.PlayerName, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('StatusText') then
		TweenService:Create(LoadingFrame.StatusText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('SpinnerContainer') then
		TweenService:Create(LoadingFrame.SpinnerContainer, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	end
	if LoadingFrame:FindFirstChild('ProgressContainer') then
		TweenService:Create(LoadingFrame.ProgressContainer, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	end
	
	task.wait(0.4)
	
	-- Fade out loading frame background
	TweenService:Create(LoadingFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()

	Topbar.BackgroundTransparency = 1
	Topbar.Divider.Size = UDim2.new(0, 0, 0, 1)
	Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency = 1
	if Topbar:FindFirstChild('Title') then
		Topbar.Title.TextTransparency = 1
	end
	if Topbar:FindFirstChild('Search') then
		Topbar.Search.ImageTransparency = 1
	end
	if Topbar:FindFirstChild('Settings') then
		Topbar.Settings.ImageTransparency = 1
	end
	if Topbar:FindFirstChild('ChangeSize') then
		Topbar.ChangeSize.ImageTransparency = 1
	end
	if Topbar:FindFirstChild('Hide') then
		Topbar.Hide.ImageTransparency = 1
	end


	task.wait(0.5)
	
	-- Create ambient glow orbs (floating around the menu)
	local glowContainer = Main:FindFirstChild("MenuGlows") or Instance.new("Frame")
	glowContainer.Name = "MenuGlows"
	glowContainer.Parent = Main
	glowContainer.Size = UDim2.new(1, 0, 1, 0)
	glowContainer.BackgroundTransparency = 1
	glowContainer.ZIndex = 0
	glowContainer.ClipsDescendants = true
	local glowBaseColor = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected
	local glowR = math.floor(glowBaseColor.R * 255)
	local glowG = math.floor(glowBaseColor.G * 255)
	local glowB = math.floor(glowBaseColor.B * 255)
	
	task.spawn(function()
		for i = 1, 5 do
			local glow = Instance.new("Frame")
			glow.Parent = glowContainer
			glow.Size = UDim2.new(0, math.random(40, 80), 0, math.random(40, 80))
			glow.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.6 + 0.2, 0)
			glow.BackgroundColor3 = Color3.fromRGB(
				math.clamp(glowR + math.random(-30, 30), 0, 255),
				math.clamp(glowG + math.random(-30, 30), 0, 255),
				math.clamp(glowB + math.random(-30, 30), 0, 255)
			)
			glow.BackgroundTransparency = 0.92
			glow.BorderSizePixel = 0
			local glowCorner = Instance.new("UICorner")
			glowCorner.CornerRadius = UDim.new(1, 0)
			glowCorner.Parent = glow
			
			-- Animate glow floating
			task.spawn(function()
				while glow.Parent do
					local newX = math.random() * 0.8 + 0.1
					local newY = math.random() * 0.6 + 0.2
					local moveTween = TweenService:Create(glow, TweenInfo.new(math.random(30, 60) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Position = UDim2.new(newX, 0, newY, 0),
						BackgroundTransparency = math.random(88, 96) / 100
					})
					moveTween:Play()
					moveTween.Completed:Wait()
				end
			end)
		end
	end)
	
	-- ðŸ”¥ HARDCODED WATERMARK - Bottom right corner (hidden, small) ðŸ”¥
	local _w = Instance.new("TextLabel")
	_w.Name = "."
	_w.Parent = NightUI
	_w.AnchorPoint = Vector2.new(1, 1)
	_w.Position = UDim2.new(1, -5, 1, -3)
	_w.Size = UDim2.new(0, 50, 0, 12)
	_w.BackgroundTransparency = 1
	_w.BorderSizePixel = 0
	_w.Font = Enum.Font.Gotham
	_w.Text = "VeloxLabs"
	_w.TextColor3 = Color3.fromRGB(80, 80, 80)
	_w.TextSize = 8
	_w.TextTransparency = 0.7
	_w.TextXAlignment = Enum.TextXAlignment.Right
	_w.ZIndex = 1
	
	-- Animated entrance for Topbar with BOUNCE
	Topbar.Visible = true
	Topbar.Size = UDim2.new(1, 0, 0, 45)  -- Force full width
	Topbar.AnchorPoint = Vector2.new(0, 0) -- Reset anchor to simpler top-left
	Topbar.Position = UDim2.new(0, 0, 0, -50) -- Start above
	
	-- Bounce in from top
	TweenService:Create(Topbar, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	
	task.wait(0.1)
	
	-- ðŸ”¥ ANIMATE SIDEBAR SLIDING IN FROM LEFT ðŸ”¥
	if TabList then
		-- Setup for animation
		TabList.AnchorPoint = Vector2.new(0, 0)
		TabList.Size = UDim2.new(0, 200, 1, -45)
		TabList.Position = UDim2.new(-0.3, 0, 0, 45)  -- Start off-screen left
		TabList.BackgroundTransparency = 1
		TabList.BackgroundColor3 = SelectedTheme.Background
		TabList.AutomaticSize = Enum.AutomaticSize.None
		
		TweenService:Create(TabList, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 45),
			BackgroundTransparency = 0
		}):Play()
		
		print("[VeloxLabs] Sidebar animation started")
	end
	
	-- ðŸ”¥ ANIMATE CONTENT AREA FADING IN ðŸ”¥
	if Elements then
		Elements.BackgroundTransparency = 1
		task.delay(0.3, function()
			TweenService:Create(Elements, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.95
			}):Play()
		end)
	end
	
	-- Divider slides in with glow effect
	Topbar.Divider.BackgroundColor3 = SelectedTheme.ToggleEnabledStroke
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 1)}):Play()
	task.delay(0.5, function()
		TweenService:Create(Topbar.Divider, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundColor3 = SelectedTheme.ElementStroke}):Play()
	end)
	local titleLabel = Topbar:FindFirstChild('Title')
	if titleLabel then
		local titleText = titleLabel.Text
		titleLabel.Text = ""
		titleLabel.TextTransparency = 0
		
		-- Simple typing effect
		task.spawn(function()
			for i = 1, #titleText do
				if titleLabel and titleLabel.Parent then
					titleLabel.Text = string.sub(titleText, 1, i)
				end
				task.wait(0.04)
			end
			local pulseColor = SelectedTheme.TabBackgroundSelected or Color3.fromRGB(200, 170, 255)
			task.spawn(function()
				while titleLabel and titleLabel.Parent do
					pcall(function()
						TweenService:Create(titleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							TextColor3 = pulseColor
						}):Play()
					end)
					task.wait(1.5)
					pcall(function()
						TweenService:Create(titleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							TextColor3 = SelectedTheme.TextColor
						}):Play()
					end)
					task.wait(1.5)
				end
			end)
		end)
	end
	
	-- Stagger topbar buttons with pop effect
	local buttonDelay = 0.1
	task.wait(0.15)
	
	-- ðŸ”¥ ANIMATED TOPBAR BUTTONS WITH HOVER EFFECTS ðŸ”¥
	local function animateButton(button, delay)
		task.delay(delay, function()
			button.ImageTransparency = 1
			button.BackgroundTransparency = 1
			local originalSize = button.Size
			button.Size = UDim2.new(0, originalSize.X.Offset * 0.3, 0, originalSize.Y.Offset * 0.3)
			
			-- Pop in animation
			TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = originalSize,
				ImageTransparency = 0.2,
				BackgroundTransparency = 0.8
			}):Play()
			
			-- Add hover effects
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0.4,
					ImageTransparency = 0,
					Size = UDim2.new(0, originalSize.X.Offset * 1.15, 0, originalSize.Y.Offset * 1.15)
				}):Play()
			end)
			
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0.8,
					ImageTransparency = 0.2,
					Size = originalSize
				}):Play()
			end)
		end)
	end
	
	animateButton(Topbar.Search, 0)
	if Topbar:FindFirstChild('Settings') then
		animateButton(Topbar.Settings, 0.08)
	end
	animateButton(Topbar.ChangeSize, 0.16)
	animateButton(Topbar.Hide, 0.24)
	
	task.wait(0.3)

	if dragBar then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	end

	function Window.ModifyTheme(NewTheme)
		local success = pcall(ChangeTheme, NewTheme, NightUI)
		if not success then
			NightUILibrary:Notify({Title = 'Unable to Change Theme', Content = 'We are unable find a theme on file.', Image = 4400704299})
		else
			NightUILibrary:Notify({Title = 'Theme Changed', Content = 'Successfully changed theme to '..(typeof(NewTheme) == 'string' and NewTheme or 'Custom Theme')..'.', Image = 4483362748})
		end
	end

	local success, result = pcall(function()
		createSettings(Window, Topbar, TabList, Elements)
	end)

	if not success then 
		warn('VeloxLabs had an issue creating settings.')
		warn('Error details:', result)
	end
	-- Minimize/Maximize disabled for multi-window compatibility
	if Topbar and Topbar:FindFirstChild('ChangeSize') then
		Topbar.ChangeSize.Visible = false -- Hide minimize button
		--[[ Minimize functionality disabled - references old globals
		Topbar.ChangeSize.MouseButton1Click:Connect(function()
			if Debounce then return end
			if Minimised then
				Minimised = false
				Maximise()
			else
				Minimised = true
				Minimise()
			end
		end)
		--]]
	end
	
	-- Window-specific keybind handling for K (Main) and L (Live Log)
	local windowKeybind = Settings.ToggleUIKeybind
	if windowKeybind then
		local keybindEnum
		if type(windowKeybind) == "string" then
			keybindEnum = Enum.KeyCode[string.upper(windowKeybind)]
		elseif typeof(windowKeybind) == "EnumItem" then
			keybindEnum = windowKeybind
		end
		
		if keybindEnum then
			UserInputService.InputBegan:Connect(function(input, processed)
				if input.KeyCode == keybindEnum and not processed then
					if NightUI then
						NightUI.Enabled = not NightUI.Enabled
						print("[VeloxLabs] Toggled window '", Settings.Name, "' with key", keybindEnum.Name)
					end
				end
			end)
			print("[VeloxLabs] Window '", Settings.Name, "' keybind set to:", keybindEnum.Name)
		end
	end
	
	if Topbar and Topbar:FindFirstChild('Hide') then
		Topbar.Hide.MouseButton1Click:Connect(function()
			if NightUI then
				NightUI.Enabled = not NightUI.Enabled
			end
		end)
	end
	
	-- Topbar button hover effects
	if Topbar then
		for _, TopbarButton in ipairs(Topbar:GetChildren()) do
			if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
				TopbarButton.MouseEnter:Connect(function()
					TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				end)
				TopbarButton.MouseLeave:Connect(function()
					TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
				end)
			end
		end
	end
	task.delay(1.5, function()
		if LoadingFrame and LoadingFrame.Parent then
			LoadingFrame.Visible = false
		end
	end)
	task.delay(2, function()
		-- Force TabList center alignment
		if TabList then
			local layout = TabList:FindFirstChildOfClass('UIListLayout')
			if layout then
				layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				layout.VerticalAlignment = Enum.VerticalAlignment.Center
				print("[VeloxLabs] FORCED TabList center alignment")
			end
		end
		
		-- Force content pages left alignment with proper padding
		if Elements then
			for _, page in ipairs(Elements:GetChildren()) do
				if page:IsA('ScrollingFrame') and page.Name ~= 'Template' then
					local pageLayout = page:FindFirstChildOfClass('UIListLayout')
					if pageLayout then
						pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
						print("[VeloxLabs] FORCED page '", page.Name, "' left alignment")
					end
					
					-- Ensure all elements are full width
					for _, element in ipairs(page:GetChildren()) do
						if element:IsA('Frame') and element.Name ~= 'Template' and element.Name ~= 'Placeholder' then
							element.Size = UDim2.new(1, 0, 0, element.Size.Y.Offset)
						end
					end
				end
			end
		end
	end)

	return Window
end

local function setVisibility(visibility: boolean, notify: boolean?)
	if Debounce then return end
	if visibility then
		Hidden = false
		Unhide()
	else
		Hidden = true
		Hide(notify)
	end
end

function NightUILibrary:SetVisibility(visibility: boolean)
	setVisibility(visibility, false)
end

function NightUILibrary:IsVisible(): boolean
	return not Hidden
end

local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function NightUILibrary:Destroy()
	nightuiDestroyed = true
	
	-- Disconnect keybind handler
	pcall(function()
		if hideHotkeyConnection then
			hideHotkeyConnection:Disconnect()
			hideHotkeyConnection = nil
		end
	end)
	
	-- Find and destroy the ScreenGui containing our UI
	local success, err = pcall(function()
		local guis = {}
		
		-- Helper function to check if a gui is NightUI
		local function isNightUIGui(gui)
			if not gui:IsA("ScreenGui") then return false end
			if string.match(gui.Name, "^VeloxLabs%-") then return true end
			-- Check by name
			if gui.Name == "NightUI" then return true end
			-- Check if it has Main child with specific structure
			local main = gui:FindFirstChild("Main")
			if main and main:FindFirstChild("Topbar") then return true end
			return false
		end
		
		-- Check CoreGui (via gethui if available)
		pcall(function()
			local parent = gethui and gethui() or game:GetService("CoreGui")
			for _, gui in ipairs(parent:GetChildren()) do
				if isNightUIGui(gui) then
					table.insert(guis, gui)
				end
			end
		end)
		
		-- Check inside RobloxGui if exists
		pcall(function()
			local robloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
			if robloxGui then
				for _, gui in ipairs(robloxGui:GetChildren()) do
					if isNightUIGui(gui) then
						table.insert(guis, gui)
					end
				end
			end
		end)
		
		-- Check PlayerGui
		pcall(function()
			local player = game:GetService("Players").LocalPlayer
			if player and player:FindFirstChild("PlayerGui") then
				for _, gui in ipairs(player.PlayerGui:GetChildren()) do
					if isNightUIGui(gui) then
						table.insert(guis, gui)
					end
				end
			end
		end)
		
		-- Destroy all found NightUI guis
		for _, gui in ipairs(guis) do
			print("[VeloxLabs] Destroying UI:", gui.Name)
			gui:Destroy()
		end
		
		if #guis == 0 then
			warn("[VeloxLabs] No UI found to destroy")
		end
	end)
	
	if not success then
		warn("[VeloxLabs] Failed to destroy UI:", err)
	end
end
--[[
Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then
		Minimised = false
		Maximise()
	else
		Minimised = true
		Minimise()
	end
end)
]]

if Main and Main:FindFirstChild('Search') and Main.Search:FindFirstChild('Input') then
	Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
		if #Main.Search.Input.Text > 0 then
			if not Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks') then 
				local searchTitle = Elements.Template.SectionTitle:Clone()
				searchTitle.Parent = Elements.UIPageLayout.CurrentPage
				searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
				searchTitle.LayoutOrder = -100
				searchTitle.Title.Text = "Results from '"..Elements.UIPageLayout.CurrentPage.Name.."'"
				searchTitle.Title.TextColor3 = SelectedTheme.TextColor
				searchTitle.Visible = true
			end
		else
			local searchTitle = Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')

			if searchTitle then
				searchTitle:Destroy()
			end
		end

		for _, element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
			if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
				if element.Name == 'SectionTitle' then
					if #Main.Search.Input.Text == 0 then
						element.Visible = true
					else
						element.Visible = false
					end
				else
					if string.lower(element.Name):find(string.lower(Main.Search.Input.Text), 1, true) then
						element.Visible = true
					else
						element.Visible = false
					end
				end
			end
		end
	end)
end

-- ðŸ”¥ WINDOW-SPECIFIC SEARCH FUNCTIONS ðŸ”¥
local function windowOpenSearch()
	searchOpen = true
	
	if not Main:FindFirstChild('Search') then 
		warn("[VeloxLabs] windowOpenSearch: Main.Search not found")
		return 
	end
	
	local Search = Main.Search
	
	Search.BackgroundTransparency = 1
	if Search:FindFirstChild('Shadow') then Search.Shadow.ImageTransparency = 1 end
	if Search:FindFirstChild('Input') then Search.Input.TextTransparency = 1 end
	if Search:FindFirstChild('Search') then Search.Search.ImageTransparency = 1 end
	if Search:FindFirstChild('UIStroke') then Search.UIStroke.Transparency = 1 end
	Search.Size = UDim2.new(1, -180, 0, 80)  -- Adjusted for sidebar
	Search.Position = UDim2.new(0.5, 85, 0, 70)
	
	if Search:FindFirstChild('Input') then
		Search.Input.Interactable = true
	end
	Search.Visible = true
	
	-- Hide tabs during search
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" and tabbtn.Name ~= "Template" and tabbtn.Name ~= "AvatarRow" and tabbtn.Name ~= "VeloxLabs_RightBorder" then
			if tabbtn:FindFirstChild('Interact') then tabbtn.Interact.Visible = false end
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			if tabbtn:FindFirstChild('Title') then TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play() end
			if tabbtn:FindFirstChild('Image') then TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play() end
			if tabbtn:FindFirstChild('UIStroke') then TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play() end
		end
	end
	
	if Search:FindFirstChild('Input') then Search.Input:CaptureFocus() end
	if Search:FindFirstChild('Shadow') then TweenService:Create(Search.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 0.95}):Play() end
	TweenService:Create(Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 85, 0, 57), BackgroundTransparency = 0.9}):Play()
	if Search:FindFirstChild('UIStroke') then TweenService:Create(Search.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play() end
	if Search:FindFirstChild('Input') then TweenService:Create(Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play() end
	if Search:FindFirstChild('Search') then TweenService:Create(Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play() end
	TweenService:Create(Search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -190, 0, 35)}):Play()
	
	print("[VeloxLabs] Search opened")
end

local function windowCloseSearch()
	searchOpen = false
	
	if not Main or not Main:FindFirstChild('Search') then 
		-- Silently return if Search doesn't exist
		return 
	end
	
	local Search = Main.Search
	
	TweenService:Create(Search, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(1, -200, 0, 30)}):Play()
	if Search:FindFirstChild('Search') then TweenService:Create(Search.Search, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play() end
	if Search:FindFirstChild('Shadow') then TweenService:Create(Search.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play() end
	if Search:FindFirstChild('UIStroke') then TweenService:Create(Search.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play() end
	if Search:FindFirstChild('Input') then TweenService:Create(Search.Input, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play() end
	
	-- Show tabs again
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" and tabbtn.Name ~= "Template" and tabbtn.Name ~= "AvatarRow" and tabbtn.Name ~= "VeloxLabs_RightBorder" then
			if tabbtn:FindFirstChild('Interact') then tabbtn.Interact.Visible = true end
			local isCurrentPage = Elements.UIPageLayout and tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Name
			if isCurrentPage then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				if tabbtn:FindFirstChild('Image') then TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play() end
				if tabbtn:FindFirstChild('Title') then TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play() end
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				if tabbtn:FindFirstChild('Image') then TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play() end
				if tabbtn:FindFirstChild('Title') then TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play() end
			end
		end
	end
	
	if Search:FindFirstChild('Input') then
		Search.Input.Text = ''
		Search.Input.Interactable = false
	end
	
	print("[VeloxLabs] Search closed")
end

-- Assign to global for compatibility
openSearch = windowOpenSearch
closeSearch = windowCloseSearch

-- Connect Search events only if Search exists
if Main and Main:FindFirstChild('Search') and Main.Search:FindFirstChild('Input') then
	Main.Search.Input.FocusLost:Connect(function(enterPressed)
		if #Main.Search.Input.Text == 0 and searchOpen then
			task.wait(0.12)
			windowCloseSearch()
		end
	end)
	print("[VeloxLabs] Search Input FocusLost connected")
else
	warn("[VeloxLabs] Main.Search or Main.Search.Input not found!")
end

-- Connect Topbar Search button
if Topbar and Topbar:FindFirstChild('Search') then
	Topbar.Search.MouseButton1Click:Connect(function()
		task.spawn(function()
			-- Check if Search UI exists
			if not Main or not Main:FindFirstChild('Search') then
				warn("[VeloxLabs] Search UI not found, creating simple search...")
				NightUILibrary:Notify({Title = "Search", Content = "Search not available in this window", Duration = 2})
				return
			end
			
			if searchOpen then
				windowCloseSearch()
			else
				windowOpenSearch()
			end
		end)
	end)
	print("[VeloxLabs] Topbar.Search button connected")
else
	warn("[VeloxLabs] Topbar.Search button not found!")
end

if Topbar and Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function()
		task.spawn(function()
			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end

			Elements.UIPageLayout:JumpTo(Elements['NightUI Settings'])
		end)
	end)

end


if Topbar and Topbar:FindFirstChild('Hide') then
	Topbar.Hide.MouseButton1Click:Connect(function()
		setVisibility(Hidden, not useMobileSizing)
	end)
end

local lastKeybindTime = 0
hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.RightShift then
		-- Cooldown to prevent spam
		local now = tick()
		if now - lastKeybindTime < 0.5 then return end
		lastKeybindTime = now
		
		if nightuiDestroyed then return end
		
		-- Find all NightUI windows and toggle them
		local guiParent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
		for _, gui in ipairs(guiParent:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Name:match("^VeloxLabs%-") then
				gui.Enabled = not gui.Enabled
			end
		end
	end
end)
--[[
for _, TopbarButton in ipairs(Topbar:GetChildren()) do
	if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
		TopbarButton.MouseEnter:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		end)

		TopbarButton.MouseLeave:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
		end)
	end
end
]]


function NightUILibrary:LoadConfiguration()
	local config

	if debugX then
		warn('Loading Configuration')
	end

	if useStudio then
		config = [[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
	end

	if CEnabled then
		local notified
		local loaded

		local success, result = pcall(function()
			if useStudio and config then
				loaded = LoadConfiguration(config)
				return
			end

			if isfile then 
				if isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
					loaded = LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
				end
			else
				notified = true
				NightUILibrary:Notify({Title = "NightUI Configurations", Content = "We couldn't enable Configuration Saving as you are not using software with filesystem support.", Image = 4384402990})
			end
		end)

		if success and loaded and not notified then
			NightUILibrary:Notify({Title = "NightUI Configurations", Content = "The configuration file for this script has been loaded from a previous session.", Image = 4384403532})
		elseif not success and not notified then
			warn('NightUI Configurations Error | '..tostring(result))
			NightUILibrary:Notify({Title = "NightUI Configurations", Content = "We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.", Image = 4384402990})
		end
	end

	globalLoaded = true
end



if useStudio then
	-- For development testing, create your own window configuration
end

if CEnabled and Main and Main:FindFirstChild('Notice') then
	Main.Notice.BackgroundTransparency = 1
	Main.Notice.Title.TextTransparency = 1
	Main.Notice.Size = UDim2.new(0, 0, 0, 0)
	Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
	Main.Notice.Visible = true


	TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5}):Play()
	TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.1}):Play()
end
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA why :(
--if not useStudio then
--	task.spawn(loadWithTimeout, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua")
--end
--[[
task.delay(4, function()
	NightUILibrary.LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)
]]
local THEME_TWEEN_TIME = 0.3
local THEME_TWEEN_INFO = TweenInfo.new(THEME_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Helper function to safely tween a property
local function SafeTween(instance, property, value)
	if instance and typeof(value) == "Color3" then
		pcall(function()
			TweenService:Create(instance, THEME_TWEEN_INFO, {[property] = value}):Play()
		end)
	end
end

-- NOTE: ApplyThemeToElement is defined earlier in the file (around line 2858)
-- This ChangeTheme function uses the comprehensive version defined there

function NightUILibrary:ChangeTheme(themeName)
	print('[VeloxLabs] NightUILibrary:ChangeTheme called with:', themeName)
	
	if typeof(themeName) ~= 'string' then return false end
	if not NightUILibrary.Theme[themeName] then
		warn('[VeloxLabs] Theme not found:', themeName)
		return false
	end
	
	SelectedTheme = NightUILibrary.Theme[themeName]
	print('[VeloxLabs] Theme loaded:', themeName)
	local parent = (typeof(gethui) == "function" and gethui()) or 
	               (typeof(get_hidden_gui) == "function" and get_hidden_gui()) or 
	               game:GetService("CoreGui")
	
	local windowCount = 0
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name and child.Name:match("^VeloxLabs%-") then
			windowCount = windowCount + 1
			print('[VeloxLabs] Applying theme to window:', child.Name)
			pcall(function()
				-- Apply theme to ALL descendants with smooth tweens (animated = true)
				for _, desc in ipairs(child:GetDescendants()) do
					ApplyThemeToElement(desc, SelectedTheme, true, nil)
					
					-- Special handling for specific elements
					pcall(function()
						-- Tab buttons - check if selected (only in TabList/TabContainer!)
						local parentName = desc.Parent and desc.Parent.Name or ""
						if desc:IsA("Frame") and desc:FindFirstChild("Title") and desc:FindFirstChild("Interact") and (parentName == "TabList" or parentName == "TabContainer") then
							-- This is a TAB button, not a regular button
							if desc.BackgroundTransparency < 0.5 then
								SafeTween(desc, "BackgroundColor3", SelectedTheme.TabBackgroundSelected)
								local title = desc:FindFirstChild("Title")
								if title then SafeTween(title, "TextColor3", SelectedTheme.SelectedTabTextColor) end
							else
								SafeTween(desc, "BackgroundColor3", SelectedTheme.TabBackground)
								local title = desc:FindFirstChild("Title")
								if title then SafeTween(title, "TextColor3", SelectedTheme.TabTextColor) end
							end
						end
						
						-- Dropdown options in List
						if desc:IsA("Frame") and desc.Parent and desc.Parent.Name == "List" and desc.Name ~= "Template" and desc.Name ~= "Placeholder" then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.DropdownUnselected or SelectedTheme.ElementBackground)
						end
						
						-- Topbar elements
						if desc.Name == "CornerRepair" then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.Topbar)
						end
						
						-- Divider
						if desc.Name == "Divider" then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementStroke)
						end
						
						-- Paragraph elements
						if desc.Name == "Paragraph" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local pTitle = desc:FindFirstChild("Title")
							if pTitle then SafeTween(pTitle, "TextColor3", SelectedTheme.TextColor) end
							local pContent = desc:FindFirstChild("Content")
							if pContent then SafeTween(pContent, "TextColor3", SelectedTheme.TextColor) end
							local pStroke = desc:FindFirstChildOfClass("UIStroke")
							if pStroke then SafeTween(pStroke, "Color", SelectedTheme.ElementStroke) end
							-- Update flex gradient if exists
							local pGradient = desc:FindFirstChildOfClass("UIGradient")
							if pGradient then
								pGradient.Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, SelectedTheme.TabBackgroundSelected),
									ColorSequenceKeypoint.new(0.5, SelectedTheme.ElementBackground),
									ColorSequenceKeypoint.new(1, SelectedTheme.TabBackgroundSelected)
								})
							end
						end
						
						-- Toggle elements
						if desc.Name == "Toggle" and desc:IsA("Frame") then
							local indicator = desc:FindFirstChild("Indicator")
							if indicator then
								-- Check toggle state
								if indicator.Position.X.Scale > 0.5 then
									SafeTween(indicator, "BackgroundColor3", SelectedTheme.ToggleEnabled)
								else
									SafeTween(indicator, "BackgroundColor3", SelectedTheme.ToggleDisabled)
								end
							end
						end
						
						-- Slider elements (full update including knob)
						if desc.Name == "Slider" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local sliderStroke = desc:FindFirstChildOfClass("UIStroke")
							if sliderStroke then SafeTween(sliderStroke, "Color", SelectedTheme.ElementStroke) end
							local sliderTitle = desc:FindFirstChild("Title")
							if sliderTitle then SafeTween(sliderTitle, "TextColor3", SelectedTheme.TextColor) end
							local sliderInfo = desc:FindFirstChild("Information")
							if sliderInfo then SafeTween(sliderInfo, "TextColor3", SelectedTheme.TextColor) end
							local sliderMain = desc:FindFirstChild("Main")
							if sliderMain then
								SafeTween(sliderMain, "BackgroundColor3", SelectedTheme.SliderBackground or SelectedTheme.SecondaryElementBackground)
								local progress = sliderMain:FindFirstChild("Progress")
								if progress then SafeTween(progress, "BackgroundColor3", SelectedTheme.SliderProgress or SelectedTheme.ToggleEnabled) end
								local knob = sliderMain:FindFirstChild("Knob")
								if knob then 
									SafeTween(knob, "BackgroundColor3", SelectedTheme.ToggleEnabled)
									local knobStroke = knob:FindFirstChildOfClass("UIStroke")
									if knobStroke then SafeTween(knobStroke, "Color", SelectedTheme.TextColor) end
								end
							end
							local accentBar = desc:FindFirstChild("AccentBar")
							if accentBar then SafeTween(accentBar, "BackgroundColor3", SelectedTheme.ToggleEnabled) end
						end
						
						-- Dropdown elements (full update)
						if desc.Name == "Dropdown" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local dropStroke = desc:FindFirstChildOfClass("UIStroke")
							if dropStroke then SafeTween(dropStroke, "Color", SelectedTheme.ElementStroke) end
							local dropTitle = desc:FindFirstChild("Title")
							if dropTitle then SafeTween(dropTitle, "TextColor3", SelectedTheme.TextColor) end
							local dropSelected = desc:FindFirstChild("Selected")
							if dropSelected then SafeTween(dropSelected, "TextColor3", SelectedTheme.TextColor) end
							local dropList = desc:FindFirstChild("List")
							if dropList then
								SafeTween(dropList, "BackgroundColor3", SelectedTheme.ElementBackground)
								local listStroke = dropList:FindFirstChildOfClass("UIStroke")
								if listStroke then SafeTween(listStroke, "Color", SelectedTheme.ElementStroke) end
								-- Update all dropdown options
								for _, option in ipairs(dropList:GetChildren()) do
									if option:IsA("Frame") and option.Name ~= "Template" and option.Name ~= "Placeholder" then
										SafeTween(option, "BackgroundColor3", SelectedTheme.DropdownUnselected)
										local optTitle = option:FindFirstChild("Title")
										if optTitle then SafeTween(optTitle, "TextColor3", SelectedTheme.TextColor) end
									end
								end
							end
						end
						
						-- Input elements
						if desc.Name == "Input" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local inputStroke = desc:FindFirstChildOfClass("UIStroke")
							if inputStroke then SafeTween(inputStroke, "Color", SelectedTheme.ElementStroke) end
							local inputTitle = desc:FindFirstChild("Title")
							if inputTitle then SafeTween(inputTitle, "TextColor3", SelectedTheme.TextColor) end
							local inputFrame = desc:FindFirstChild("InputFrame")
							if inputFrame then
								SafeTween(inputFrame, "BackgroundColor3", SelectedTheme.InputBackground)
								local inputBox = inputFrame:FindFirstChild("InputBox")
								if inputBox then
									SafeTween(inputBox, "TextColor3", SelectedTheme.TextColor)
									inputBox.PlaceholderColor3 = SelectedTheme.PlaceholderColor or Color3.fromRGB(150, 150, 150)
								end
							end
						end
						
						-- Button elements
						if desc.Name == "Button" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local btnStroke = desc:FindFirstChildOfClass("UIStroke")
							if btnStroke then SafeTween(btnStroke, "Color", SelectedTheme.ElementStroke) end
							local btnTitle = desc:FindFirstChild("Title")
							if btnTitle then SafeTween(btnTitle, "TextColor3", SelectedTheme.TextColor) end
						end
						
						-- Keybind elements
						if desc.Name == "Keybind" and desc:IsA("Frame") then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ElementBackground)
							local kbStroke = desc:FindFirstChildOfClass("UIStroke")
							if kbStroke then SafeTween(kbStroke, "Color", SelectedTheme.ElementStroke) end
							local kbTitle = desc:FindFirstChild("Title")
							if kbTitle then SafeTween(kbTitle, "TextColor3", SelectedTheme.TextColor) end
							local kbContainer = desc:FindFirstChild("KeybindContainer")
							if kbContainer then
								SafeTween(kbContainer, "BackgroundColor3", SelectedTheme.InputBackground)
								local kbFrame = kbContainer:FindFirstChild("KeybindFrame")
								if kbFrame then
									local kbText = kbFrame:FindFirstChild("Input")
									if kbText then SafeTween(kbText, "TextColor3", SelectedTheme.TextColor) end
								end
							end
						end
						
						-- ScrollingFrame scrollbar
						if desc:IsA("ScrollingFrame") then
							desc.ScrollBarImageColor3 = SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected
						end
						
						-- Accent bars
						if desc.Name == "AccentBar" then
							SafeTween(desc, "BackgroundColor3", SelectedTheme.ToggleEnabled or SelectedTheme.TabBackgroundSelected)
						end
						
						-- Section gradients
						if desc:IsA("UIGradient") and desc.Parent and desc.Parent.Name == "SectionLine" then
							local accent = SelectedTheme.TabBackgroundSelected or SelectedTheme.ToggleEnabled
							desc.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),
								ColorSequenceKeypoint.new(0.3, accent),
								ColorSequenceKeypoint.new(0.7, accent),
								ColorSequenceKeypoint.new(1, Color3.new(0.3, 0.3, 0.3))
							})
						end
					end)
				end
				
				-- Trigger dropdown updates by changing Main BackgroundColor3
				if child:FindFirstChild("Main") then
					local main = child.Main
					main.BackgroundColor3 = Color3.new(0, 0, 0)
					task.defer(function()
						SafeTween(main, "BackgroundColor3", SelectedTheme.Background)
					end)
					
					-- Update background image if theme has one
					local bgImage = main:FindFirstChild("ThemeBackgroundImage")
					if SelectedTheme.BackgroundImage then
						if not bgImage then
							bgImage = Instance.new("ImageLabel")
							bgImage.Name = "ThemeBackgroundImage"
							bgImage.Parent = main
							bgImage.AnchorPoint = Vector2.new(0.5, 0.5)
							bgImage.Position = UDim2.new(0.5, 0, 0.5, 0)
							bgImage.Size = UDim2.new(1, 0, 1, 0)
							bgImage.BackgroundTransparency = 1
							bgImage.ZIndex = 0
							bgImage.ScaleType = Enum.ScaleType.Crop
							local bgCorner = Instance.new("UICorner")
							bgCorner.CornerRadius = UDim.new(0, 10)
							bgCorner.Parent = bgImage
						end
						bgImage.Image = SelectedTheme.BackgroundImage
						bgImage.ImageTransparency = SelectedTheme.BackgroundImageTransparency or 0.9
						bgImage.Visible = true
					elseif bgImage then
						bgImage.Visible = false
					end
				end
				
				-- ðŸ”¥ UPDATE JOKE CONTAINER ðŸ”¥
				local jokeContainer = child:FindFirstChild("JokeContainer")
				if jokeContainer then
					SafeTween(jokeContainer, "BackgroundColor3", SelectedTheme.ElementBackground)
					
					-- Update joke gradient
					local jokeGradient = jokeContainer:FindFirstChildOfClass("UIGradient")
					if jokeGradient then
						local themeAccentColor = SelectedTheme.TabBackgroundSelected
						local themeBgColor = SelectedTheme.ElementBackground
						jokeGradient.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, themeAccentColor),
							ColorSequenceKeypoint.new(0.5, themeBgColor),
							ColorSequenceKeypoint.new(1, themeAccentColor)
						})
					end
					
					-- Update joke stroke
					local jokeStroke = jokeContainer:FindFirstChildOfClass("UIStroke")
					if jokeStroke then
						SafeTween(jokeStroke, "Color", SelectedTheme.ToggleEnabledStroke)
					end
					
					-- Update joke text
					local jokeLabel = jokeContainer:FindFirstChild("JokeText")
					if jokeLabel then
						SafeTween(jokeLabel, "TextColor3", SelectedTheme.TextColor)
					end
					
					-- Update emoji
					local jokeEmoji = jokeContainer:FindFirstChild("Emoji")
					if jokeEmoji then
						SafeTween(jokeEmoji, "TextColor3", SelectedTheme.TextColor)
					end
				end
				
				-- ðŸ”¥ UPDATE TOPBAR TITLE & CREDITS ðŸ”¥
				local topbar = main:FindFirstChild("Topbar")
				if topbar then
					SafeTween(topbar, "BackgroundColor3", SelectedTheme.Topbar)
					
					local title = topbar:FindFirstChild("Title")
					if title then
						SafeTween(title, "TextColor3", SelectedTheme.TextColor)
					end
					
					-- Credits container
					local creditsContainer = topbar:FindFirstChild("CreditsContainer")
					if creditsContainer then
						SafeTween(creditsContainer, "BackgroundColor3", SelectedTheme.ElementBackground)
						local creditsStroke = creditsContainer:FindFirstChildOfClass("UIStroke")
						if creditsStroke then
							SafeTween(creditsStroke, "Color", SelectedTheme.ToggleEnabledStroke)
						end
						local creditsGradient = creditsContainer:FindFirstChildOfClass("UIGradient")
						if creditsGradient then
							creditsGradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, SelectedTheme.TabBackgroundSelected),
								ColorSequenceKeypoint.new(0.5, SelectedTheme.ElementBackground),
								ColorSequenceKeypoint.new(1, SelectedTheme.TabBackgroundSelected)
							})
						end
						for _, child2 in ipairs(creditsContainer:GetChildren()) do
							if child2:IsA("TextLabel") then
								SafeTween(child2, "TextColor3", SelectedTheme.TextColor)
							end
						end
					end
				end
			end)
		end
	end
	
	if windowCount > 0 then
		print('[VeloxLabs] Theme applied to', windowCount, 'window(s)')
	end
	
	return true
end

-- â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
-- â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- Get executor compatibility info
function NightUILibrary:GetExecutorInfo()
	local success, result = pcall(function()
		return ExecutorScanner.GetCachedScan()
	end)
	if success and result then
		return result
	end
	-- Return safe default
	return {
		executor = "Unknown",
		score = { percentage = 0, rating = "Unknown", color = Color3.fromRGB(150, 150, 150) },
		apis = { available = {}, unavailable = {} },
		features = {},
		categories = {}
	}
end

-- Show executor scanner popup
function NightUILibrary:ShowExecutorScanner()
	local success, err = pcall(function()
		local parent = nil
		local guiParent = (gethui and gethui()) or CoreGui
		
		for _, gui in ipairs(guiParent:GetChildren()) do
			if gui.Name:match("^VeloxLabs%-") and gui:FindFirstChild('Main') then
				parent = gui.Main
				break
			end
		end
		
		if parent then
			return ExecutorScanner.ShowResultsPopup(parent)
		else
			warn('[VeloxLabs] No active window found for scanner popup')
			return nil
		end
	end)
	
	if not success then
		warn('[VeloxLabs] Scanner error: ' .. tostring(err))
	end
end

-- Get feature probability
function NightUILibrary:GetFeatureProbability(featureName)
	local success, result = pcall(function()
		local scan = ExecutorScanner.GetCachedScan()
		if scan and scan.features and scan.features[featureName] then
			return scan.features[featureName]
		end
		return nil
	end)
	
	if success and result then
		return result
	end
	return { percentage = 0, color = Color3.fromRGB(200, 60, 60) }
end

-- Check if specific API is available
function NightUILibrary:IsAPIAvailable(apiName)
	local success, result = pcall(function()
		local scan = ExecutorScanner.GetCachedScan()
		if scan and scan.apis and scan.apis.available then
			for _, api in ipairs(scan.apis.available) do
				if api.name == apiName then
					return true
				end
			end
		end
		return false
	end)
	return success and result or false
end


return NightUILibrary
 