-- widget variables
jumpButton = nil
jumpWindow = nil

-- button and button position
jb = nil 
curX = 150
curY = 100

-- some constants for button positioning
sideMargin = 12
topMargin = 35
maxY = 260 - 28 - sideMargin
maxX = 280 - 50 - sideMargin

-- event variable
moveTimer = nil

-- moves btn to px, py relative to window position
local function offsetButton(btn, win, px, py)
  local winrect = win:getPosition()
  btn:setPosition({x=winrect.x + px ,y=winrect.y + py})
end

-- resets the button to the right with a random Y position
function resetButton()
  curX = maxX
  curY = math.random(topMargin,maxY)
  offsetButton(jb, jumpWindow, curX, curY)
end

-- function to move window
function moveButton()
  curX = curX - 10
  if(curX < sideMargin) then
    resetButton()
  end
  offsetButton(jb, jumpWindow, curX, curY)
end

-- init function
function init()
  jumpButton = modules.client_topmenu.addRightToggleButton('jumpButton', tr('Jump'), '/jump/jumpico.png', closing)
  jumpButton:setOn(true)
  
  -- create window and button
  jumpWindow = g_ui.displayUI('jump')
  jb = g_ui.createWidget('Button', jumpWindow)
  jb:setText("jump!")
  jb:setSize({width = 50, height = 28})

  -- set click to reset the button to reset button as well
  jb.onClick = function(widget)
    resetButton()
  end

  resetButton()
  moveTimer = g_dispatcher.cycleEvent(moveButton, 200) -- dispatch event to continuously call the moveButton function
end

-- delete window and stop cycling event when unloaded
function terminate()
  jumpButton:destroy()
  jumpWindow:destroy()
  if(moveTimer) then
    moveTimer:cancel()
    moveTimer = nil
  end
end

-- close window with top bar button
function closing()
  if jumpButton:isOn() then
    jumpWindow:setVisible(false)
    jumpButton:setOn(false)
  else
    jumpWindow:setVisible(true)
    jumpButton:setOn(true)
  end
end
