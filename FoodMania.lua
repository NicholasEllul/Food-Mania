-- WARNING: THIS FILE CONTAINS MULTIPLE FILES PACKED INTO ONE. THIS IS BECAUSE THE SOURCE CODE WAS LOST EXCEPT FOR THIS LONG TEXT DOCUMENT


--# HelperClass
-- HelperClass
 
-- Created by: Mr Coxall
-- Created on: Nov 2014
-- Created for: ICS2O
-- This is a collection of classes and a scene management system,
-- to help in the aid of coding.
 
 
-- Button Class
 
-- This class simplifies the process of checking if a sprite button is pressed or not
-- Then you can ask the button if it is being touched or was ended.
-- Works best with vector sprite buttons, since it enlarges them when they are touched
--
-- Parameters to pass in:
--  1. Untouched button image name
--  2. A vector2 that is the location of the button
 
Button = class()
 
function Button:init(buttonImage, buttonPosition)
    -- accepts the button image and location to draw it
   
    self.buttonImage = buttonImage
    self.buttonLocation = buttonPosition
   
    self.buttonTouchScale = 0.85
    self.buttonImageSize = vec2(spriteSize(self.buttonImage))    
    self.currentButtonImage = self.buttonImage
    self.buttonTouchedImage = resizeImage(self.buttonImage, (self.buttonImageSize.x*self.buttonTouchScale ), (self.buttonImageSize.y*self.buttonTouchScale))  
    self.selected = false
end
 
function Button:draw()
    -- Codea does not automatically call this method
 
    pushStyle()  
    pushMatrix()
    noFill()
    noSmooth()
    noStroke()
     
    sprite(self.currentButtonImage, self.buttonLocation.x, self.buttonLocation.y)
   
    popMatrix()
    popStyle()
end
 
function Button:touched(touch)  
    -- local varaibles
    local currentTouchPosition = vec2(touch.x, touch.y)
   
    -- reset touching variable to false
    self.selected = false
   
    if (touch.state == BEGAN) then
         if( (self.buttonLocation.x - self.buttonImageSize.x/2) < currentTouchPosition.x and
            (self.buttonLocation.x + self.buttonImageSize.x/2) > currentTouchPosition.x and
            (self.buttonLocation.y - self.buttonImageSize.y/2) < currentTouchPosition.y and
            (self.buttonLocation.y + self.buttonImageSize.y/2) > currentTouchPosition.y ) then
               
            self.currentButtonImage = self.buttonTouchedImage
            --print("Now touching! - began")
        else          
            self.currentButtonImage = self.buttonImage  
            --print("Not touching - began")
        end            
    end
   
    if (touch.state == MOVING) then
        if( (self.buttonLocation.x - self.buttonImageSize.x/2) < currentTouchPosition.x and
            (self.buttonLocation.x + self.buttonImageSize.x/2) > currentTouchPosition.x and
            (self.buttonLocation.y - self.buttonImageSize.y/2) < currentTouchPosition.y and
            (self.buttonLocation.y + self.buttonImageSize.y/2) > currentTouchPosition.y ) then
       
            self.currentButtonImage = self.buttonTouchedImage
            --print("Now touching! - moving")
        else
            self.currentButtonImage = self.buttonImage  
            --print("Not touching - moving")
        end
    end
   
    if (touch.state == ENDED) then
        if( (self.buttonLocation.x - self.buttonImageSize.x/2) < currentTouchPosition.x and
            (self.buttonLocation.x + self.buttonImageSize.x/2) > currentTouchPosition.x and
            (self.buttonLocation.y - self.buttonImageSize.y/2) < currentTouchPosition.y and
            (self.buttonLocation.y + self.buttonImageSize.y/2) > currentTouchPosition.y ) then
       
            self.selected = true
            --print("Activated button")
        end
         
        self.currentButtonImage = self.buttonImage
    end
end
 
function resizeImage(img, width, height)
    -- function from
    -- http://codea.io/talk/discussion/3490/importing-pics-from-dropbox/p1
   
    local newImg = image(width,height)
    setContext(newImg)
    sprite( img, width/2, height/2, width, height )    
    setContext()
    return newImg
end
 
 
-- Dragging Object Class
-- This class simplifies the process of dragging and dropping objects
-- You can have several objects interacting, but it is not mulit-touch
--
-- Parameters to pass in:
--  1. Object image name
--  2. A vector2 that is the location of the button
--  3. Optional object id
 
 
SpriteObject = class()
 
function SpriteObject:init(objectImage, objectStartPosition, objectID)
 
    self.objectImage = objectImage
    self.objectStartLocation = objectStartPosition
    self.ID = objectID or math.random()
   
    self.objectCurrentLocation = self.objectStartLocation
    self.objectImageSize = vec2(spriteSize(self.objectImage))
    self.selected = false
    self.dragOffset = vec2(0,0)
    self.draggable = true
    -- yes, the following does need to be global to the entire program
    -- this is the only way (easy way!) to move things around and no get
    -- several object "attached" to each other
    -- this way just the top object in the stack moves
    DRAGGING_OBJECT_MOVING = nil or DRAGGING_OBJECT_MOVING    
end
 
function SpriteObject:draw()
    -- Codea does not automatically call this method
   
    pushStyle()  
    pushMatrix()
    noFill()
    noSmooth()
    noStroke()
     
    sprite(self.objectImage, self.objectCurrentLocation.x, self.objectCurrentLocation.y)
     
    popMatrix()
    popStyle()
 
end
 
function SpriteObject:touched(touch)
    -- Codea does not automatically call this method
   
    -- local varaibles
    local currentTouchPosition = vec2(touch.x, touch.y)
   
    -- reset touching variable to false
    self.selected = false
   
    if (touch.state == BEGAN and self.draggable == true) then
        if( (self.objectCurrentLocation.x - self.objectImageSize.x/2) < currentTouchPosition.x and
            (self.objectCurrentLocation.x + self.objectImageSize.x/2) > currentTouchPosition.x and
            (self.objectCurrentLocation.y - self.objectImageSize.y/2) < currentTouchPosition.y and
            (self.objectCurrentLocation.y + self.objectImageSize.y/2) > currentTouchPosition.y ) then
            -- if the touch has began, we need to find delta from touch to center of object
            -- since will need it to reposition the object for draw
            -- subtracting 2 vec2s here
            self.dragOffset = self.objectCurrentLocation - currentTouchPosition
            DRAGGING_OBJECT_MOVING = self.ID
        end        
    end
   
    if (touch.state == MOVING and self.draggable == true) then
        if( (self.objectCurrentLocation.x - self.objectImageSize.x/2) < currentTouchPosition.x and
            (self.objectCurrentLocation.x + self.objectImageSize.x/2) > currentTouchPosition.x and
            (self.objectCurrentLocation.y - self.objectImageSize.y/2) < currentTouchPosition.y and
            (self.objectCurrentLocation.y + self.objectImageSize.y/2) > currentTouchPosition.y ) then
                -- only let it move if self.draggable == true
            if (self.draggable == true) then
                -- add the offset back in for its new position
                if (self.ID == DRAGGING_OBJECT_MOVING) then
                    self.objectCurrentLocation = currentTouchPosition + self.dragOffset
                end
            end
        end      
    end
   
    if (touch.state == ENDED and self.draggable == true) then
        DRAGGING_OBJECT_MOVING = nil  
    end
   
    -- this checks for if you have just touched the image
    -- you will have to release and re-touch for this to be activated again
    if (touch.state == BEGAN) then
        if( (self.objectCurrentLocation.x - self.objectCurrentLocation.x/2) < currentTouchPosition.x and
            (self.objectCurrentLocation.x + self.objectCurrentLocation.x/2) > currentTouchPosition.x and
            (self.objectCurrentLocation.y - self.objectCurrentLocation.y/2) < currentTouchPosition.y and
            (self.objectCurrentLocation.y + self.objectCurrentLocation.y/2) > currentTouchPosition.y ) then
       
            self.selected = true
            --print("Activated button")
        end
    end
end
 
function SpriteObject:isTouching(otherSpriteObject)
    -- this method checks if one dragging object is touching another dragging object
   
    local isItTouching = false
   
    if( (self.objectCurrentLocation.x + self.objectImageSize.x/2) > (otherSpriteObject.objectCurrentLocation.x - otherSpriteObject.objectImageSize.x/2) and
        (self.objectCurrentLocation.x - self.objectImageSize.x/2) < (otherSpriteObject.objectCurrentLocation.x + otherSpriteObject.objectImageSize.x/2) and
        (self.objectCurrentLocation.y - self.objectImageSize.y/2) < (otherSpriteObject.objectCurrentLocation.y + otherSpriteObject.objectImageSize.y/2) and
        (self.objectCurrentLocation.y + self.objectImageSize.y/2) > (otherSpriteObject.objectCurrentLocation.y - otherSpriteObject.objectImageSize.y/2) ) then
        -- if true, then not touching
        isItTouching = true
    end        
   
    return isItTouching
end
 
 
-- SceneManager
-- This file lets you easily manage different scenes
-- Original code from Brainfox, off the Codea forums
 
Scene = {}
local scenes = {}
local sceneNames = {}
local currentScene = nil
 
setmetatable(Scene,{__call = function(_,name,cls)
   if (not currentScene) then
       currentScene = 1
   end
   table.insert(scenes,cls)
   sceneNames[name] = #scenes
   Scene_Select = nil
end})
 
--Change Scene
Scene.Change = function(name)
  currentScene = sceneNames[name]
    scenes[currentScene]:init()
   if (Scene_Select) then
       Scene_Select = currentScene
   end
   
   collectgarbage()
end
 
Scene.Draw = function()
   pushStyle()
   pushMatrix()
   scenes[currentScene]:draw()
   popMatrix()
   popStyle()
end
 
Scene.Touched = function(t)
   if (scenes[currentScene].touched) then
       scenes[currentScene]:touched(t)
   end
end
 
Scene.Keyboard = function()
   if (scenes[currentScene].keyboard) then
       scenes[currentScene]:keyboard(key)
   end
end
 
Scene.OrientationChanged = function()
   if (scenes[currentScene].orientationChanged) then
       scenes[currentScene]:orientationChanged()
   end
end


























--# Main
-- Final App Project
-- Created by: Patrick Nguyen, Nick Ellul, Micheal Balcerzak
-- Created on: November 2014 to January 2015
-- Created for: ISC20, Final App Project
-- This a game made by Micheal, Nick and Patrick is making a healthy lunch by dragging the right food onto your plate. There are multiple levels and the speed and the number of food in each level rises as the levels increase, there are 20 levels. There are also minigames, one of our minigames is where you have to catch raining food and decide which is junk and healthy, the other one is an endless version of the levels. We also have a store for players to buy items such as backgrounds, clothes, more food, more lives etc. 
-- Ideas from our Grade 3 students Zoe, Katie and Riley
-- Food images from: Findicons.com and Clker.com
-- Company Name: Smiley Sandwich
-- App Name: Food Mania

-- Persitent/Global variables
-- Sound
-- volume = 0
-- volumeMove = 625
soundEffects = true
-- Minigame-Food Fall
miniHighscore = nil
miniScore = nil
-- Coins
coins = nil
-- Minigame-Endless
saveScore = nil
-- Background
backgroundSelect = nil
-- Lock Level
lockLevels = 0
-- Global
changeHat = 1
changeShirt = 1
changePants = 1
buyHat = 0
buyShirt = 0
buyPants = 0
--Saving Items for game
saveHat = nil
savePants = nil
saveShirt = nil
-- Store Items
boughtPants = false
boughtPants2 = false
boughtPants3 = false
boughtPants4 = false 
boughtShirt = false
boughtShirt2 = false
boughtShirt3 = false
boughtShirt4 = false
boughtHat = false
boughtHat2 = false
boughtHat3 = false
boughtHat4 = false
-- Shop 
endlessLives = nil
addedLives = nil
moreCoins = nil
-- Food Info
foodPrevious = 0

--firstFalse = false


function setup()
-- Setup
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
noFill()
noSmooth()
noStroke()
pushStyle()

    
-- Different Scenes
Scene("Setup",Setup)
Scene("Trans", Transition)
Scene("Achieve",Achievements)
Scene("Settings",Settings)
Scene("Credits",Credits)
Scene("Help",ButtonGuide)
-- Store
Scene("Store",Store)
Scene("Confirm", Confirmation)
-- Shop
Scene("Shop",Shop)
-- Game
Scene("Level",Level)
Scene("Teach",Tutorial)
Scene("Game",Game)
Scene("Gf",GameOver)
Scene("Gg",GameWin)
-- Minigame
Scene("Foodfall",Foodfall)
Scene("end",EndGame)
Scene("Hf",HowToFoodfall)
Scene("He",HowToEndless)
Scene("Over",EndlessOver)    
-- Food info
Scene("Food",FoodInfo)
Scene("Healthy",Healthy)
Scene("Junk",Junk)
    
-- Changing to first Scene    
Scene.Change("Trans") 
         
-- Highscore-Food fall
miniHighscore = readLocalData("high",0)   
--saveLocalData("high",0)   
    
-- Highscore-Endless
saveScore = readLocalData("score",0) 
--saveLocalData("score",0)
    
-- Coins
coins = readLocalData("coins",0) 
--saveLocalData("coins",0)

-- Locking Levels    
lockLevels = readLocalData("levels",0)
--saveLocalData("levels",0)
  
-- Sound  
volume = readLocalData("volume",0.6) 
--saveLocalData("volume",0)    
volumeMove = readLocalData("move",625) 
--saveLocalData("move",0)   
soundEffects = readLocalData("sound",true)
-- saveLocalData("sound",0)
    
-- Music
music("Game Music One:Sporting Arena", true, volume)        
    
-- Background
backgroundSelect = readLocalData("background",1)
if backgroundSelect == nil then
saveLocalData("background",backgroundSelect)
end
        
-- Store Items
boughtPants = readLocalData("P1",0)   
--saveLocalData("P1",false)
boughtPants2 = readLocalData("P2",0)  
--saveLocalData("P2",false) 
boughtPants3 = readLocalData("P3",0)   
--saveLocalData("P3",false) 
boughtPants4 = readLocalData("P4",0)   
--saveLocalData("P4",false) 
    
boughtShirt = readLocalData("S1",0)   
--saveLocalData("S1",false) 
boughtShirt2 = readLocalData("S2",0)  
--saveLocalData("S2",false) 
boughtShirt3 = readLocalData("S3",0)    
--saveLocalData("S3",false) 
boughtShirt4 = readLocalData("S4",0)   
--saveLocalData("S4",false) 
    
boughtHat = readLocalData("H1",0)   
--saveLocalData("H1",false) 
boughtHat2 = readLocalData("H2",0)   
--saveLocalData("H2",false) 
boughtHat3 = readLocalData("H3",0)   
--saveLocalData("H3",false) 
boughtHat4 = readLocalData("H4",0) 
--saveLocalData("H4",false) 
    
firstFalse = readLocalData("F",false) 
       
-- Saving Clothes
savePants = readLocalData("SP",0)   
saveShirt = readLocalData("SS",0)       
saveHat = readLocalData("SH",0)   
    
-- Shop
endlessLives = readLocalData("endless",0)
--saveLocalData("endless",0) 
addedLives = readLocalData("addedLives",0)
--saveLocalData("addedLives",0) 
moreCoins = readLocalData("moreCoins",0)
--saveLocalData("moreCoins",0) 
    
if firstFalse == false then
saveLocalData("P1",false)
saveLocalData("P2",false) 
saveLocalData("P3",false) 
saveLocalData("P4",false) 
    
saveLocalData("S1",false) 
saveLocalData("S2",false) 
saveLocalData("S3",false) 
saveLocalData("S4",false) 
    
saveLocalData("H1",false) 
saveLocalData("H2",false) 
saveLocalData("H3",false) 
saveLocalData("H4",false) 
saveLocalData("F",true)             
end      
    end
 
function draw()  
Scene.Draw()    
   end
    
function touched(touch)
Scene.Touched(touch) 
end


























--# Transition
-- Beginning Special Effects Scene
-- Made by: Patrick
-- Small portion of the transition code was from Jnv38 on the Codea forums
-- Other part was invented by me 

Transition = class()
-- Global, for use in the next scene
fade = 0
-- Begining Transitions
local timer = 0
local touchScene
local goIsOn = true

function Transition:init(x) 
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- Fading Code
data = {alpha = 255}
next = 0
   
sound("Game Sounds One:1-2-3 Go")  
end


function Transition:draw()    
-- Timer
timer = timer + 1/60  
-- Fading Code    
tint(255,255,255,data.alpha)
sprite("Dropbox:Smiley",WIDTH/2,HEIGHT/2,1024,768)
tint(255,255,255,255-data.alpha)
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
    
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end
      
if math.floor(timer + 1) == 3 then
-- Fading Code   
tween(1,data,{alpha = next})
next = next  
end
    
if math.floor(timer + 1) == 4 then  
-- Switch for switching scenes with touch detection
touchScene = true
end

    
if math.floor(timer + 1) > 2 then  
-- Text Setup
strokeWidth(5)
fill(255, 4, 0, 255)
fontSize(125)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,695)          
fontSize(70)
text("Tap anywhere to continue",WIDTH/2,50)     
end
if firstFalse == false then
boughtPants = false
boughtPants2 = false
boughtPants3 = false
boughtPants4 = false 
boughtShirt = false
boughtShirt2 = false
boughtShirt3 = false
boughtShirt4 = false
boughtHat = false
boughtHat2 = false
boughtHat3 = false
boughtHat4 = false
        
saveLocalData("P1",false)
saveLocalData("P2",false) 
saveLocalData("P3",false) 
saveLocalData("P4",false) 
    
saveLocalData("S1",false) 
saveLocalData("S2",false) 
saveLocalData("S3",false) 
saveLocalData("S4",false) 
    
saveLocalData("H1",false) 
saveLocalData("H2",false) 
saveLocalData("H3",false) 
saveLocalData("H4",false) 
saveLocalData("F",true)     
end 
    end
    



function Transition:touched(touch)
-- Switch for switching scenes with touch detection
if touchScene == true then 
-- Universal screen touch detection               
if touch.state == BEGAN then
fade = 1
-- Change to next scene
Scene.Change("Setup")            
    end
end
    end




























--# Setup
-- Main Menu
-- Made by: Patrick
Setup = class()
-- Buttons
local startButton
local settingsButton
local foodEndless
local foodFall
local storeButton
local shopButton
local helpButton

-- Setup for fading and usage of buttons
local timer = 0

-- Random food generator
local foodSelector = math.random(1,3)
local foodSelector2 = math.random(1,3)
local foodSelector3 = math.random(1,3)
local foodSelector4 = math.random(1,3)
local foodSelector5 = math.random(1,3)
local foodSelector6 = math.random(1,4)

-- Food 1
local myFood = "Dropbox:Food-Apple"
local foodSize = vec2(spriteSize(myFood))
local foodPosition = vec2()
-- Food 2    
local myFood2 = "Dropbox:Food-Apple"  
local foodSize2 = vec2(spriteSize(myFood2))
local foodPosition2 = vec2()
-- Food 3   
local myFood3 = "Dropbox:Food-Apple" 
local foodSize3 = vec2(spriteSize(myFood3))
local foodPosition3 = vec2()
-- Food 4  
local myFood4 = "Dropbox:Food-Apple" 
local foodSize4 = vec2(spriteSize(myFood4))
local  foodPosition4 = vec2()
-- Food 5    
local myFood5 = "Dropbox:Food-Apple"  
local foodSize5 = vec2(spriteSize(myFood5))
local foodPosition5 = vec2()
-- Food 6  
local myFood6 = "Dropbox:Food-Apple"  
local foodSize6 = vec2(spriteSize(myFood6))
local foodPosition6 = vec2()

-- Position of the food and plate
local foodPosition = vec2(-600,230) 
local foodPosition2 = vec2(-1200,230)
local foodPosition3 = vec2(-1800,230)
local foodPosition4 = vec2(-900,595)
local foodPosition5 = vec2(-1500,595)
local foodPosition6 = vec2(-2100,595)
    

function Setup:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN)
-- Setting up position of the buttons    
startButton = Button("Dropbox:Level", vec2(WIDTH/2, HEIGHT/2+90))
settingsButton = Button("Dropbox:Settings Icon", vec2(750,95))
storeButton = Button("Dropbox:Store Icon", vec2(105,95))
shopButton = Button("Dropbox:Bonus Shop", vec2(280,95))
helpButton = Button("Dropbox:Help Icon", vec2(925,95))
foodEndless = Button("Documents:?", vec2(WIDTH/2+163, HEIGHT/2-35))
foodFall = Button("Documents:?", vec2(WIDTH/2-163, HEIGHT/2-35))
    
if lockLevels > 15 then
foodFall = Button("Dropbox:Minigame-Foodfall", vec2(WIDTH/2-180, HEIGHT/2-35))
end        
    
if lockLevels > 20 then
foodEndless = Button("Dropbox:Minigame-Endless", vec2(WIDTH/2+180, HEIGHT/2-35))
end    
    
-- Fading Code
data = {alpha = 255}
next = -200
end

function Setup:draw()
-- Choosing Background 
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end    
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end
    
-- Food position
sprite(myFood, foodPosition.x, foodPosition.y)      
sprite(myFood2,foodPosition2.x, foodPosition2.y)      
sprite(myFood3, foodPosition3.x, foodPosition3.y)     
sprite(myFood4,foodPosition4.x, foodPosition4.y)              
sprite(myFood5, foodPosition5.x, foodPosition5.y)   
sprite(myFood6, foodPosition6.x, foodPosition6.y)   
    
-- Text Setup
strokeWidth(1)
fill(255, 0, 0, 255)
fontSize(125)
font("Copperplate")
    
-- Text
text("Food Mania",WIDTH/2,695)          
fill(255, 0, 0, 255)
fontSize(70)

-- Drawing Buttons    
startButton:draw()
foodEndless:draw()
foodFall:draw()
settingsButton:draw()   
storeButton:draw()  
shopButton:draw()
helpButton:draw()
    
    
if fade == 1 then    
--Timer
timer = timer + 1/30
-- Fading Code    
tint(255,255,255,data.alpha)
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end
    
if math.floor(timer + 1) == 2 then   
-- Fading Code
    tween(1,data,{alpha = next})
    next = next 
end

if math.floor(timer + 1) == 3 then   
-- Switch to make all buttons touchable
touchedOn = true
-- To make sure fade doesn't happen again
fade = fade + 1
end
    end
    
    
if touchedOn == true then
foodPosition.x = foodPosition.x + 10
foodPosition2.x = foodPosition2.x + 10
foodPosition3.x = foodPosition3.x + 10
foodPosition4.x = foodPosition4.x + 10
foodPosition5.x = foodPosition5.x + 10
foodPosition6.x = foodPosition6.x + 10
end
    
-- If food touches edge    
if foodPosition.x > 1100 then
foodPosition.x = -750
foodSelector = math.random(1,3)
end
if foodPosition2.x > 1100 then
foodPosition2.x = -750
foodSelector2 = math.random(1,3)
end
if foodPosition3.x > 1100 then
foodPosition3.x = -750
foodSelector3 = math.random(1,3)
end
if foodPosition4.x > 1100 then
foodPosition4.x = -750
foodSelector4 = math.random(1,3)
end
if foodPosition5.x > 1100 then
foodPosition5.x = -750
foodSelector5 = math.random(1,3)
end
if foodPosition6.x > 1100 then
foodPosition6.x = -750
foodSelector6 = math.random(1,4)
end
    
-- Selecting random food  
sprite()
if foodSelector == 1 then
myFood = "Dropbox:Food-Apple"      
    end
if foodSelector == 2 then
myFood = "Dropbox:Food-Broccoli"               
    end
if foodSelector == 3 then
myFood = "Dropbox:Food-Bread"            
    end
    
-- Second random food selector 
sprite()   
if foodSelector2 == 1 then   
myFood2 = "Dropbox:Food-Potato" 
    end
if foodSelector2 == 2 then    
myFood2  = "Dropbox:Food-Corn" 
    end    
if foodSelector2 == 4 then
myFood2  = "Dropbox:Food-Egg" 
    end 

      
-- Third random food selector   
sprite()     
if foodSelector3 == 1 then   
myFood3  = "Dropbox:Food-Carrot" 
    end
if foodSelector3 == 2 then    
myFood3  = "Dropbox:Food-Muffin" 
    end    
if foodSelector3 == 3 then
myFood3 = "Dropbox:Food-Cookie"  
    end 

        
-- Fourth random food selector    
sprite()
if foodSelector4 == 1 then   
myFood4  = "Dropbox:Food-Strawberry" 
    end
if foodSelector4 == 2 then
myFood4  = "Dropbox:Food-Cucumber" 
    end
if foodSelector4 == 3 then    
myFood4  = "Dropbox:Food-Ham" 
    end    

    
-- Fifth random food selector        
sprite()
if foodSelector5 == 1 then   
myFood5  = "Dropbox:Food-Pumpkin" 
    end
if foodSelector5 == 2 then    
myFood5  = "Dropbox:Food-Steak"   
    end    
if foodSelector5 == 3 then
myFood5  = "Dropbox:Food-Cupcake"        
    end 

-- Sixth random food selector    
if foodSelector6 == 1 then
myFood6 = "Dropbox:Food-Donuts"   
    end
if foodSelector6 == 2 then
myFood6 = "Dropbox:Food-Cake" 
    end
if foodSelector6 == 3 then
myFood6 = "Dropbox:Food-Cheese" 
    end  
if foodSelector6 == 4 then
myFood6  = "Dropbox:Food-Fries"      
    end                
       end

function Setup:touched(touch)    
-- Switch to make all buttons touchable
if touchedOn == true then       
-- Scenes being changed after buttons are selected
startButton:touched(touch)
settingsButton:touched(touch)
storeButton:touched(touch)
shopButton:touched(touch)   
helpButton: touched(touch)

foodFall:touched(touch) 
foodEndless:touched(touch)
   
if lockLevels < 16 then 
if foodFall.selected == true then
alert("You need to finish level 15 to unlock this minigame!")
    end
end
            
if lockLevels < 21 then
if foodEndless.selected == true then       
alert("You need to finish level 20 to unlock this minigame!")
    end
end
                                       
if(startButton.selected== true) then
if soundEffects == true then
sound("A Hero's Quest:Hit 1")
end
Scene.Change("Level")
levelOn = true
    end

if(settingsButton.selected== true) then
if soundEffects == true then
sound("A Hero's Quest:Hit 1")
end
Scene.Change("Settings")
    end

if(storeButton.selected== true) then
if soundEffects == true then
sound("A Hero's Quest:Hit 1")
end
Scene.Change("Store")
    end

if shopButton.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Hit 1")
end
Scene.Change("Shop")
   end

if lockLevels > 15 then        
if foodFall.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
Scene.Change("Foodfall")
    end
end
        
if lockLevels > 20 then
if foodEndless.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
Scene.Change("Game")
foodOn = true
gameOn = true 
lives = 10 + endlessLives
startAll = true
pauseMenu = false
    end
end
        
if helpButton.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Hit 1")
end
Scene.Change("Help")
   end       
       end
           end
        






























--# Settings
-- Settings
-- Made by: Micheal
Settings = class()
-- Buttons
local menuButton
local plusButton
local minusButton
local soundButton
local credits
-- Background
local backgroundOne
local backgroundTwo
local backgroundThree
local backgroundFour
local backgroundFive
local backgroundSix
-- Switchs
local maxSound = true
local minSound = true
--soundOn = true
-- Values
local messure
local switch



    function Settings:init(x)    
    supportedOrientations(LANDSCAPE_ANY)
    displayMode(FULLSCREEN_NO_BUTTONS)
    -- Making Buttons
    sprite()
    menuButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))      
    minusButton = Button("Dropbox:Minus", vec2(WIDTH/2-130,HEIGHT/2 + 173))
    credits = Button("Dropbox:Credits Icon", vec2(WIDTH/2+360, 125))      
    -- Plus and Minus
    plusButton = Button("Dropbox:Plus", vec2(WIDTH/2 + 355,HEIGHT/2 + 173))
    minusButton = Button("Dropbox:Minus", vec2(WIDTH/2-130,HEIGHT/2 + 173))
    -- Background
    backgroundOne = Button("Dropbox:BackgroundSmall1",vec2(WIDTH/2-385, HEIGHT/2-300))
    backgroundTwo = Button("Dropbox:BackgroundSmall6",vec2(WIDTH/2-145, HEIGHT/2-300))
    backgroundThree = Button("Dropbox:BackgroundSmall2",vec2(WIDTH/2+95, HEIGHT/2-300))
    backgroundFour = Button("Dropbox:BackgroundSmall3",vec2(WIDTH/2-385, HEIGHT/2-135))
    backgroundFive = Button("Dropbox:BackgroundSmall4",vec2(WIDTH/2-145, HEIGHT/2-135))
    backgroundSix = Button("Dropbox:BackgroundSmall5",vec2(WIDTH/2+95, HEIGHT/2-135))
    
    if soundEffects == false then
        soundButton = Button("Dropbox:Mute Icon", vec2(WIDTH/2 + 200, HEIGHT/2+65))      
    end
    
    if soundEffects == true then
        soundButton = Button("Dropbox:Sound Icon", vec2(WIDTH/2 + 200, HEIGHT/2+65))      
    end
end


function Settings:draw()
-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)
fill(255, 0, 0, 255)         
end
    
                 
-- Text Setup
strokeWidth(5)
fontSize(75)
font("Copperplate")  

-- Text    
text("Food Mania",WIDTH/2,725)  
fontSize(60)
text("Settings",WIDTH/2,675)        

    -- Text
    fontSize(65)
    text("Music:",WIDTH/2 - 300, HEIGHT/2 + 175)
    text("Sound Effects:",WIDTH/2 - 135, HEIGHT/2+75)
    text("Background:",WIDTH/2-145 , HEIGHT/2-25)
    text("Credits",WIDTH/2+365 , 265)

     -- Buttons/Volume
    fill(0, 0, 0, 255)
    messure = line(WIDTH/2-75, HEIGHT/2 + 173, WIDTH/2 + 295, HEIGHT/2 + 173)
    switch = ellipse(volumeMove, HEIGHT/2 + 173, 35)
    plusButton:draw()
    minusButton:draw()
    menuButton:draw()
    credits:draw()
    soundButton: draw()

    -- Background
    backgroundOne:draw()
    backgroundTwo:draw()
    backgroundThree:draw()
    backgroundFour:draw()
    backgroundFive: draw()
    backgroundSix :draw()
    end


function Settings:touched(touch)  
-- Menu button
menuButton: touched(touch)
if menuButton.selected == true then
    if soundEffects == true then
    sound("Game Sounds One:Pistol",    5)
    end
    Scene.Change("Setup")
    end

        -- Plus and minus buttons
        if (maxSound == true) then
        plusButton:touched(touch)
    if (plusButton.selected == true) then
    volume = volume + 0.05
    volumeMove = volumeMove + 15
    music("Hero's Triumph", true, volume)
    saveLocalData("volume",volume)
    saveLocalData("move",volumeMove)
    end
end
    
        if (minSound == true) then
        minusButton:touched(touch)
    if (minusButton.selected == true) then
    volume = volume - 0.05
    volumeMove = volumeMove - 15
    music("Hero's Triumph", true, volume)
    saveLocalData("volume",volume)
    saveLocalData("move",volumeMove)
    end
end

        -- If volume is at its minimum
        if (volumeMove == 445) then
        minSound = false
        maxSound = true
        else
        minSound = true
        end
    
        -- If volume is at its maximum 
        if (volumeMove == 805) then
        minSound = true
        maxSound = false
        else 
        maxSound = true
        end
    
    -- Putting in the backgrounds
    backgroundOne:touched(touch)
    if (backgroundOne.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
       backgroundSelect = 1
       saveLocalData("background",backgroundSelect)
       end
    
    backgroundTwo:touched(touch)
    if (backgroundTwo.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
        backgroundSelect = 2
        saveLocalData("background",backgroundSelect)
        end
    
    backgroundThree:touched(touch)
    if (backgroundThree.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
        backgroundSelect = 3
        saveLocalData("background",backgroundSelect)
        end
    
    backgroundFour:touched(touch)
    if (backgroundFour.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
        backgroundSelect = 4
        saveLocalData("background",backgroundSelect)
        end
    
    backgroundFive:touched(touch)
    if (backgroundFive.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
        backgroundSelect = 5
        saveLocalData("background",backgroundSelect)
        end
    
    backgroundSix:touched(touch)
    if (backgroundSix.selected == true) then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
        backgroundSelect = 6
        saveLocalData("background",backgroundSelect)
        end

soundButton:touched(touch)
    
if soundEffects == true then
    if soundButton.selected == true then
    soundButton = Button("Dropbox:Mute Icon", vec2(WIDTH/2 + 200, HEIGHT/2+65))      
        soundEffects = false
        saveLocalData("sound",false)
        end
    end
    
if soundEffects == false then
    if soundButton.selected == true then
    soundButton = Button("Dropbox:Sound Icon", vec2(WIDTH/2 + 200, HEIGHT/2+65))      
        soundEffects = true
        saveLocalData("sound",true)
        end
    end
    -- Credits
    credits:touched(touch)
    if credits.selected == true then
if soundEffects == true then
sound("Game Sounds One:Land", 5)
end
Scene.Change("Credits")
end
    end






























--# Credits
Credits = class()

local backbutton
local scrolling = 720
local scrolling1 = 610
local scrolling2 = 530
local scrolling3 = 500
local scrolling4 = 420
local scrolling5 = 390
local scrolling6 = 320
local scrolling7 = 240
local scrolling8 = 160
local scrolling9 = 80
local scrolling10 = 0

local stopScroll
local scroll = true

function Credits:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
   stopScroll = Button("Dropbox:Background-FoodGroups",vec2(WIDTH/2 - 410, 720))
   backbutton = Button("Dropbox:Back Icon",vec2(WIDTH/2 - 410, 675))   
   end

function Credits:draw()
  if scroll == true then
       scrolling = scrolling + 1
       scrolling1 = scrolling1 + 1
       scrolling2 = scrolling2 + 1
       scrolling3 = scrolling3 + 1
       scrolling4 = scrolling4 + 1
       scrolling5 = scrolling5 + 1
       scrolling6 = scrolling6 + 1
       scrolling7 = scrolling7 + 1
       scrolling8 = scrolling8 + 1
       scrolling9 = scrolling9 + 1
       scrolling10 = scrolling10 + 1
       end
       
    
-- Text Setup
strokeWidth(5)
fill(255, 55, 0, 255)
fontSize(75)

   spriteMode(CORNER)
   sprite("SpaceCute:Background",0,0,WIDTH,HEIGHT) 

   spriteMode(CENTER) 
   font("CourierNewPS-BoldItalicMT")  
   font("Baskerville-SemiBoldItalic")  
   text("Food Mania-Credits", WIDTH/2+30, scrolling)
   fontSize(36)
   textMode(CORNER)

   text("Michael: Avatar Creator, Settings, Help, Credits",WIDTH/2-WIDTH/4*1.2,scrolling1)
   text("Nick: Food Fall, Food Catalogue, Bonus Store, ",WIDTH/2-WIDTH/4*1.2,scrolling2)
   text("App Icon, Screenshots, Credits, How to Play ",WIDTH/2-WIDTH/4*1.2,scrolling3)
   text("Patrick: Levels, Tutorial, Endless Mode,",WIDTH/2-WIDTH/4*1.2, scrolling4)
   text("Avatar Creator, Icons, UI Design ",WIDTH/2-WIDTH/4*1.2, scrolling5)
   text("Teachers: Mr.Coxall, Mr.Jewett",WIDTH/2-WIDTH/4*1.2, scrolling6)
   text("App Idea & Company Logo: Riley, Zoe, Katie",WIDTH/2-WIDTH/4*1.2, scrolling7)
   text("Icons: Clker.com & Findicons.com",WIDTH/2-WIDTH/4*1.2, scrolling8)
   text("Buttons: Dabuttonfactory.com & Erikmoberg.com",WIDTH/2-WIDTH/4*1.2,scrolling9)
   text("Background: 7640 Food Wallpapers",WIDTH/2-WIDTH/4*1.2,scrolling10)
   if scrolling == HEIGHT + 20 then
       scrolling = - 20
   end
   if scrolling1 == HEIGHT + 20 then
       scrolling1 = - 20
   end
   if scrolling2 == HEIGHT + 20 then
       scrolling2 = - 20
   end
   if scrolling3 == HEIGHT + 20 then
       scrolling3 = - 20
   end
   if scrolling4 == HEIGHT + 20 then
       scrolling4 = - 20
   end
   if scrolling5 == HEIGHT + 20 then
       scrolling5 = - 20
   end
   if scrolling6 == HEIGHT + 20 then
       scrolling6 = - 20
   end
   if scrolling7 == HEIGHT + 20 then
       scrolling7 = - 20
   end
   if scrolling8 == HEIGHT + 20 then
       scrolling8 = - 20
   end
   if scrolling9 == HEIGHT + 20 then
       scrolling9 = - 20
   end
    if scrolling10 == HEIGHT + 20 then
       scrolling10 = - 20
   end
 
backbutton:draw()       
       end


function Credits:touched(touch)
   -- Codea does not automatically call this method
   backbutton:touched(touch)
   stopScroll:touched(touch)
   if stopScroll.selected == true then
   scroll = true
       else 
       scroll = false
       end

if backbutton.selected == true then
    Scene.Change("Settings")
    end
end



























--# Store
-- Store
-- Made by: Micheal/Patrick
Store = class()
-- Clothes
local hat 
local shirt 
local pants 

-- Locks
local lockPants
local lockShirt
local lockHat

-- Buttons
local backButton
local saveButton
local right
local right1
local right2
local left
local left1
local left2


function Store:init(x)
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- Switching clothes
right = Button("Dropbox:Move Right Icon",vec2(WIDTH/2 - 125,HEIGHT/2 - 300))
left = Button("Dropbox:Move Left Icon",vec2(WIDTH/2 - 425,HEIGHT/2 - 300))
right1 = Button("Dropbox:Move Right Icon",vec2(WIDTH/2 - 125,HEIGHT/2-100))
left1 = Button("Dropbox:Move Left Icon",vec2(WIDTH/2 - 425,HEIGHT/2 -100))
right2 = Button("Dropbox:Move Right Icon",vec2(WIDTH/2 - 125,HEIGHT/2 + 100))
left2 = Button("Dropbox:Move Left Icon",vec2(WIDTH/2 - 425,HEIGHT/2 + 100))
-- Pants
pants = SpriteObject("Dropbox:Store-Knight shield", vec2(WIDTH/2 - 275,HEIGHT/2 - 300))
lockPants = Button("Dropbox:Lock Icon", vec2(WIDTH/2 - 275,HEIGHT/2 - 300))   
-- Shirt
shirt = SpriteObject("Dropbox:Store-Knight sword", vec2(WIDTH/2 - 275,HEIGHT/2 - 100))
lockShirt = Button("Dropbox:Lock Icon", vec2(WIDTH/2 - 275,HEIGHT/2 - 100))
-- Hat
hat = SpriteObject("Dropbox:Store-Knight Head",vec2(WIDTH/2 - 275,HEIGHT/2 + 100))
lockHat = Button("Dropbox:Lock Icon", vec2(WIDTH/2 - 275,HEIGHT/2 + 100))
-- Buttons
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))   
saveButton = Button("Dropbox:Save Icon",vec2(935,HEIGHT/2 - 300))
end


function Store:draw()
-- Background/Character       
sprite("SpaceCute:Background",512, 384, 1024, 768)
sprite("Dropbox:Boy", 750,375,135,300)
-- Switching buttons
right:draw()
left:draw()
right1:draw()
left1:draw()
right2:draw()
left2:draw()
backButton:draw()
saveButton:draw()
    
-- Text Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,725)
fontSize(60)
text("Avatar Creator",WIDTH/2,675)    
text("Save",935,HEIGHT/2 - 200)    
    
-- Coins
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2+410,690)
text(coins,WIDTH/2+410,600)   
--sprite("Dropbox:Coins",WIDTH/2+35,115)
--text(coins,WIDTH/2+35,25)   


-- Text
fontSize(45)
fill(255, 0, 0, 255)
text("Helm",WIDTH/2-275,HEIGHT/2 + 190)
text("Weapon",WIDTH/2-275,HEIGHT/2-10)
text("Special",WIDTH/2-275,HEIGHT/2 - 210)
fill(255, 255, 255, 255)

    -- Hat
    if (changeHat == 2) then
       if boughtHat == false then
       lockHat:draw()
       text("2500", WIDTH/2 - 275,HEIGHT/2 + 100)
       else
          if boughtHat == true then
          sprite("Dropbox:Store-Knight Head",WIDTH/2 - 275,HEIGHT/2 + 100)
          hat = SpriteObject("Dropbox:Store-Knight Head", vec2(740, 475))
          hat:draw()
          end
      end
  end

    if (changeHat == 3) then
       if boughtHat2 == false then
       lockHat:draw()
       text("5000", WIDTH/2 - 275,HEIGHT/2 + 100)
       else
          if boughtHat2 == true then
          sprite("Dropbox:Store-Cowboy hat",WIDTH/2 - 275,HEIGHT/2 + 100)
          hat = SpriteObject("Dropbox:Store-Cowboy hat",vec2(750, 520))
          hat:draw()
          end
      end
  end
    
    if (changeHat == 4) then
       if boughtHat3 == false then
       lockHat:draw()
       text("7500", WIDTH/2 - 275,HEIGHT/2 + 100)
       else
          if boughtHat3 == true then
          sprite("Documents:Store-Starwars hat",WIDTH/2 - 275,HEIGHT/2 + 100)
          hat = SpriteObject("Documents:Store-Starwars hat",vec2(748, 475))
          hat:draw()
          end
      end
  end
    
    
    if (changeHat == 5) then
       if boughtHat4 == false then
       lockHat:draw()
       text("12500", WIDTH/2 - 275,HEIGHT/2 + 100)
       else
          if boughtHat4 == true then
          sprite("Dropbox:Store-Avenger ironman",WIDTH/2 - 275,HEIGHT/2 + 100)
          hat = SpriteObject("Dropbox:Store-Avenger ironman",vec2(750, 480))
          hat:draw()
          end
      end
  end


       
    -- Shirts
    if (changeShirt == 2) then
       if boughtShirt == false then
       lockShirt:draw()
       text("2500", WIDTH/2 - 275,HEIGHT/2 - 100)
       else
          if boughtShirt == true then
          sprite("Dropbox:Store-Knight sword",WIDTH/2 - 275,HEIGHT/2 - 100)
          shirt = SpriteObject("Dropbox:Store-Knight sword", vec2(650, 345))
          shirt:draw()
          end
      end
  end

    if (changeShirt == 3) then
       if boughtShirt2 == false then
       lockShirt:draw()
       text("5000", WIDTH/2 - 275,HEIGHT/2 - 100)
       else
          if boughtShirt2 == true then
          sprite("Dropbox:Store-Cowboy whip",WIDTH/2 - 275,HEIGHT/2 - 100)
          shirt = SpriteObject("Dropbox:Store-Cowboy whip", vec2(650,400))
          shirt:draw()
          end
      end
  end
    
    if (changeShirt == 4) then
       if boughtShirt3 == false then
       lockShirt:draw()
       text("7500", WIDTH/2 - 275,HEIGHT/2 - 100)
       else
          if boughtShirt3 == true then
          sprite("Documents:Store-Starwars lightsaber",WIDTH/2 - 275,HEIGHT/2 - 100)
          shirt = SpriteObject("Documents:Store-Starwars lightsaber", vec2(650,425))
          shirt:draw()
          end
      end
  end
    
    if (changeShirt == 5) then
       if boughtShirt4 == false then
       lockShirt:draw()
       text("12500", WIDTH/2 - 275,HEIGHT/2 - 100)
       else
          if boughtShirt4 == true then
          sprite("Dropbox:Store-Avenger thor",WIDTH/2 - 275,HEIGHT/2 - 100)
          shirt = SpriteObject("Dropbox:Store-Avenger thor", vec2(665,415))
          shirt:draw()
          end
      end
  end


   -- Pants    
   if (changePants == 2) then
       if boughtPants == false then
       lockPants:draw()
       text("2500", WIDTH/2 - 275,HEIGHT/2 - 300)
       else
          if boughtPants == true then
          sprite("Dropbox:Store-Knight shield",WIDTH/2 - 275,HEIGHT/2 - 300)
          pants = SpriteObject("Dropbox:Store-Knight shield", vec2(820,385))
          pants:draw()
          end
      end
  end

    if (changePants == 3) then
       if boughtPants2 == false then
       lockPants:draw()
       text("5000", WIDTH/2 - 275,HEIGHT/2 - 300)
       else
          if boughtPants2 == true then
          sprite("Dropbox:Store-Cowboy book",WIDTH/2 - 275,HEIGHT/2 - 300)
          pants = SpriteObject("Dropbox:Store-Cowboy book", vec2(818,392))
          pants:draw()
          end
      end
  end

    if (changePants == 4) then
       if boughtPants3 == false then
       lockPants:draw()
       text("7500", WIDTH/2 - 275,HEIGHT/2 - 300)
       else
          if boughtPants3 == true then
          sprite("Documents:Store-Starwars lightning",WIDTH/2 - 275,HEIGHT/2 - 300)
          pants = SpriteObject("Documents:Store-Starwars lightning", vec2(875,320))
          pants:draw()
          end
      end
  end

    if (changePants == 5) then
       if boughtPants4 == false then
       lockPants:draw()
       text("12500", WIDTH/2 - 275,HEIGHT/2 - 300)
       else
          if boughtPants4 == true then
          sprite("Dropbox:Store-Avenger captain",WIDTH/2 - 275,HEIGHT/2 - 300)
          pants = SpriteObject("Dropbox:Store-Avenger captain", vec2(800,375))
          pants:draw()
          end
      end
  end
      end
 



function Store:touched(touch)
-- Switching buttons
right2:touched(touch)
left2:touched(touch)
right1:touched(touch)
left1:touched(touch)
right:touched(touch)
left:touched(touch)
saveButton:touched(touch)

      
       -- Preparing to buy pants
       if (changePants == 2) then
           if boughtPants == false then
           lockPants:touched(touch)
           if (lockPants.selected == true) then
               if (coins >= 2500) then
               buyPants = 1
               Scene.Change("Confirm")
          else
         alert("Not enough coins! You need "..2500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end


       if (changePants == 3) then
           if boughtPants2 == false then
           lockPants:touched(touch)
           if (lockPants.selected == true) then
               if (coins >= 5000) then
               buyPants = 2
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..5000-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end
    
    
    if (changePants == 4) then
           if boughtPants3 == false then
           lockPants:touched(touch)
           if (lockPants.selected == true) then
               if (coins >= 7500) then
               buyPants = 3
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..7500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end
 
       
    if (changePants == 5) then
           if boughtPants4 == false then
           lockPants:touched(touch)

           if (lockPants.selected == true) then
               if (coins >= 12500) then
               buyPants = 4
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..12500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
    end
    
       
       -- Changing to view different pants
       if (right.selected == true) then
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
           changePants = changePants + 1
           end

       if (left.selected == true) then
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1")
     end
           changePants = changePants - 1
           end

       if (changePants == 6) then
           changePants = 1
           end

        if (changePants == 0) then
           changePants = 5
           end

       -- Preparing to buy shirts
       if (changeShirt == 2) then
           if boughtShirt == false then
           lockShirt:touched(touch)
           if (lockShirt.selected == true) then
               if (coins >= 2500) then
               buyShirt= 1
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..2500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
      end
  end

       if (changeShirt == 3) then
           if boughtShirt2 == false then
           lockShirt:touched(touch)
           if (lockShirt.selected == true) then
               if (coins >= 5000) then
               buyShirt = 2
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..5000-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end
    
        if (changeShirt == 4) then
           if boughtShirt3 == false then
           lockShirt:touched(touch)
           if (lockShirt.selected == true) then
               if (coins >= 7500) then
               buyShirt = 3
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..7500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end

    if (changeShirt == 5) then
           if boughtShirt4 == false then
           lockShirt:touched(touch)
           if (lockShirt.selected == true) then
               if (coins >= 12500) then
               buyShirt = 4
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..12500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end

        
       -- Changing to view different shirts
       if (right1.selected == true) then
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
           changeShirt = changeShirt + 1
           end

       if (left1.selected == true) then
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1",   5)
     end
           changeShirt = changeShirt - 1
           end

       if (changeShirt == 6) then
           changeShirt = 1
           end

       if (changeShirt == 0) then
           changeShirt = 5
           end


       -- Preparing to buy hats
       if (changeHat == 2) then
           if boughtHat == false then
           lockHat:touched(touch)
           if (lockHat.selected == true) then
               if (coins >= 2500) then
               buyHat = 1
               Scene.Change("Confirm")
           else
         alert("Not enough coins! You need "..2500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
      
               end
           end
       end
   end


       if (changeHat == 3) then
           if boughtHat2 == false then
           lockHat:touched(touch)
           if (lockHat.selected == true) then
               if (coins >= 5000) then
               buyHat = 2
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..5000-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end

        if (changeHat == 4) then
           if boughtHat3 == false then
           lockHat:touched(touch)
           if (lockHat.selected == true) then
               if (coins >= 7500) then
               buyHat = 3
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..7500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end
    
    if (changeHat == 5) then
           if boughtHat4 == false then
           lockHat:touched(touch)

           if (lockHat.selected == true) then
               if (coins >= 12500) then
               buyHat = 4
               Scene.Change("Confirm")
            else
         alert("Not enough coins! You need "..12500-coins.." more coins!")
         if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         end
               end
           end
       end
   end
    
    
       -- Changing to view different hats
       if (right2.selected == true) then
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
           changeHat = changeHat + 1
           end

       if (left2.selected == true) then
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1",   5)
     end
           changeHat = changeHat - 1
           end

       if (changeHat == 6) then
           changeHat = 1
           end

       if (changeHat == 0) then
           changeHat = 5
           end


    -- Saving Costume
    if saveButton.selected == true then
        if soundEffects == true then
        sound("A Hero's Quest:Defensive Cast 3",  5)
        end
        alert("Avatar Saved!")
        saveHat = changeHat
        saveLocalData("SH",saveHat) 
        savePants = changePants
        saveLocalData("SP",savePants) 
        saveShirt = changeShirt
        saveLocalData("SS",saveShirt) 
        end

    -- back button
    backButton:touched(touch)
    if (backButton.selected == true) then
    if soundEffects == true then
     sound("Game Sounds One:Pistol",5)
     end
        Scene.Change("Setup")
        end
    end
 




























--# Confirmation


-- Confirmation
-- Made by Micheal
Confirmation = class()

-- local to this file
local yes
local no

function Confirmation:init(x)
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
yes = Button("Dropbox:Buy Icon",vec2(WIDTH/2 - 150, HEIGHT/2-200))
no = Button("Dropbox:Cancel Icon",vec2(WIDTH/2 + 150, HEIGHT/2-200))
end
function Confirmation:draw()
sprite("SpaceCute:Background",512, 384, 1024, 768)
-- Text Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,725)
fontSize(60)
text("Avatar Creator",WIDTH/2,675)

   fontSize(55)
   text("Do you want to buy this", 500, 550)


   -- Showing Hats
   if (buyHat == 1) then
       text("item for 2500 coins? ", 500,500)
       sprite("Dropbox:Store-Knight Head",WIDTH/2,350)
       end

   if (buyHat == 2) then
       text("item for 5000 coins? ", 500,500)
       sprite("Dropbox:Store-Cowboy hat",WIDTH/2,350)
       end
    
    if (buyHat == 3) then
       text("item for 7500 coins? ", 500,500)
       sprite("Documents:Store-Starwars hat",WIDTH/2,350)
       end

    if (buyHat == 4) then
       text("item for 12500 coins? ", 500,500)
       sprite("Dropbox:Store-Avenger ironman",WIDTH/2,350)
       end
    
    
    -- Showinf shirts
    if (buyShirt == 1) then
       text("item for 2500 coins? ", 500,500)
       sprite("Dropbox:Store-Knight sword",WIDTH/2,350)
       end

   if (buyShirt == 2) then
       text("item for 5000 coins? ", 500,500)
       sprite("Dropbox:Store-Cowboy whip",WIDTH/2,350)
       end
    
    if (buyShirt == 3) then
       text("item for 7500 coins? ", 500,500)
       sprite("Documents:Store-Starwars lightsaber",WIDTH/2,350)
       end

    if (buyShirt == 4) then
       text("item for 12500 coins? ", 500,500)
       sprite("Dropbox:Store-Avenger thor",WIDTH/2,350)
       end
    
    
      
   -- Showing Pants
   if (buyPants == 1) then
       text("item for 2500 coins? ", 500,500)
       sprite("Dropbox:Store-Knight shield",WIDTH/2,350)
       end

   if (buyPants == 2) then
       text("item for 5000 coins? ", 500,500)
       sprite("Dropbox:Store-Cowboy book",WIDTH/2,350)
       end
    
    if (buyPants == 3) then
       text("item for 7500 coins? ", 500,500)
       sprite("Documents:Store-Starwars lightning",WIDTH/2,350)
       end

    if (buyPants == 4) then
       text("item for 12500 coins? ", 500,500)
       sprite("Dropbox:Store-Avenger captain",WIDTH/2,350)
       end
    
yes:draw()
no:draw()
end

function Confirmation:touched(touch)
-- Yes and No
yes: touched(touch)
no: touched(touch)

   -- Buying Hats
   -- First Hat
   if (buyHat == 1) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 2500
           boughtHat = true
           saveLocalData("H1",true)
           end
               end

   -- Second Hat
   if (buyHat == 2) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 5000
           boughtHat2 = true
           saveLocalData("H2",true)
           end
               end
    
       -- Third Hat
   if (buyHat == 3) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 7500
           boughtHat3 = true
           saveLocalData("H3",true)
           end
               end    
    
        -- Fourth Hat
    if (buyHat == 4) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 12500
           boughtHat4 = true
           saveLocalData("H4",true)
           end
               end
    
    
    
   -- Buying Shirts
   -- First Shirt
   if (buyShirt == 1) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 2500
           boughtShirt = true
           saveLocalData("S1",true)
           end
               end

   -- Second Shirt
   if (buyShirt == 2) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 5000
           boughtShirt2 = true
           saveLocalData("S2",true)
           end
               end

    -- Third Shirt
    if (buyShirt == 3) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 7500
           boughtShirt3 = true
           saveLocalData("S3",true)
           end
               end
    
    -- Fourth Shirt
    if (buyShirt == 4) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 12500
           boughtShirt4 = true
           saveLocalData("S4",true)
           end
               end
    
    
   -- Buying Pants
   -- First pants
   if (buyPants == 1) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 2500
           boughtPants = true
           saveLocalData("P1",true)
           end
               end

   -- Second pants
   if (buyPants == 2) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 5000
           boughtPants2 = true
           saveLocalData("P2",true)
           end
               end
    
    -- Third pants
   if (buyPants == 3) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 7500
           boughtPants3 = true
           saveLocalData("P3",true)
           end
               end
        
    -- Fourth pants
    if (buyPants == 4) then
       if (yes.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Bell 2")
           end
           Scene.Change("Store")
           coins = coins - 12500
           boughtPants4 = true
           saveLocalData("P4",true)
           end
               end
      
       -- Yes button
       if (yes.selected == true) then
           buyHat = 0
           buyShirt = 0
           buyPants = 0
       end
    
       -- No button
       if (no.selected == true) then
           if soundEffects == true then
           sound("Game Sounds One:Pistol")
           end
           Scene.Change("Store")
           buyHat = 0
           buyShirt = 0
           buyPants = 0
       end
   end


























--# Shop

-- Made by: Nick
Shop = class()

local plus
local plus1
local plus2
local minus
local minus1
local minus2

local buy
local buy1
local buy2

local cost
local cost1
local cost2

local backButton

function Shop:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
    
-- Once you buy a value, you shouldn't be able to buy lower values.
endlessLimit = endlessLives
addedLimit = addedLives
coinsLimit = moreCoins

-- Adding and subtracting buttons
plus = Button("Dropbox:Plus",vec2(WIDTH/2+35,HEIGHT - 275))
minus = Button("Dropbox:Minus",vec2(WIDTH/2 - 235,HEIGHT - 275))
plus1 = Button("Dropbox:Plus",vec2(WIDTH/2+35 ,HEIGHT - 475))
minus1 = Button("Dropbox:Minus",vec2(WIDTH/2 - 235,HEIGHT - 475 ))
plus2 = Button("Dropbox:Plus",vec2(WIDTH/2+35,HEIGHT - 675))
minus2 = Button("Dropbox:Minus",vec2(WIDTH/2 - 235,HEIGHT - 675))
-- Buy buttons
buy = Button("Dropbox:Shop Icon",vec2(WIDTH/2 + 175,HEIGHT - 275))
buy1 = Button("Dropbox:Shop Icon",vec2(WIDTH/2 + 175,HEIGHT - 475))
buy2 = Button("Dropbox:Shop Icon",vec2(WIDTH/2 + 175,HEIGHT - 675))    
-- Back buttons
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))   
end

function Shop:draw()
-- Background
sprite("SpaceCute:Background",512, 384, 1024, 768)
    
plus:draw()
minus:draw()
plus1:draw()
minus1:draw()
plus2:draw()
minus2:draw()

buy:draw()
buy1:draw()
buy2:draw()
    
backButton:draw()    

strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,725)  
fontSize(60)
text("Bonus Store",WIDTH/2,675)        

-- Coins
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2+410,690)
text(coins,WIDTH/2+410,600)   
fontSize(50)   


   -- calculating the cost
   cost = endlessLives * 2500 - endlessLimit * 2500 
   cost1 = addedLives * 2500 - addedLimit * 2500 
   cost2 = moreCoins/50 * 3000 - coinsLimit/50 * 3000 
   
   -- Lives or Coins
text("Lives",WIDTH/2-375, HEIGHT - 275)
text("Lives",WIDTH/2-375, HEIGHT - 475)
text("Coin",WIDTH/2-375, HEIGHT - 650)
text("Bonus",WIDTH/2-375, HEIGHT - 700)
    
   -- when to display you bought the MAX value  
   if endlessLimit == 5 then
   text("MAX",WIDTH/2+325, HEIGHT - 275)
           else
           if cost == 0 then
           text("Cost: "..cost,WIDTH/2+350, HEIGHT - 275)    
           else
           text("Cost:",WIDTH/2+325, HEIGHT - 250)    
           text(cost,WIDTH/2+320, HEIGHT - 300)    
           end
       end
 
   if addedLimit == 5 then
   text("MAX",WIDTH/2+325, HEIGHT - 475)
            else
            if cost1 == 0 then
            text("Cost: "..cost1,WIDTH/2+350, HEIGHT - 475)    
            else
            text("Cost:",WIDTH/2+325, HEIGHT - 450)    
            text(cost1,WIDTH/2+320, HEIGHT - 500)    
            end
        end

   if coinsLimit == 250 then 
  text("MAX",WIDTH/2 + 325, HEIGHT - 675)
          else
          if cost2 == 0 then
            text("Cost: "..cost2,WIDTH/2+350, HEIGHT - 675)    
            else
            text("Cost:",WIDTH/2+325, HEIGHT - 650)    
            text(cost2,WIDTH/2+320, HEIGHT - 700)     
            end
        end
   

   -- Other text
   text("Endless",WIDTH/2-165,HEIGHT - 200)      
   text("Food Fall",WIDTH/2-145,HEIGHT - 400)       
   text("Level Play",WIDTH/2-135,HEIGHT - 600) 

   -- Display values
   fontSize(100)
   text(endlessLives, WIDTH/2-100,HEIGHT-275)
   text(addedLives, WIDTH/2-100,HEIGHT- 475)    
   text(moreCoins, WIDTH/2-100,HEIGHT- 675)
   end

function Shop:touched(touch)
plus2:touched(touch)
minus2:touched(touch)
plus1:touched(touch)
minus1:touched(touch)
plus:touched(touch)
minus:touched(touch)

buy:touched(touch)
buy1:touched(touch)
buy2:touched(touch)  
    
backButton:touched(touch)  

   -- Touch events for the endless lives bonus
   if minus.selected == true then 
    if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1",   5)
     end
           if endlessLives > endlessLimit then
               endlessLives = endlessLives - 1
           end
       end
    
   if plus.selected == true then 
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
       if endlessLives < 5 then
           endlessLives = endlessLives + 1
       end
   end

  if buy.selected == true and endlessLives > endlessLimit and coins >= cost then 
if soundEffects == true then
sound("Game Sounds One:Bell 2")
end
  saveLocalData("endless",endlessLives)
       endlessLimit = endlessLives
           coins = coins - cost    
            end
            

  if buy.selected == true and endlessLives > endlessLimit and coins < cost then 
     if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("Not enough coins! You need "..cost-coins.." more coins!")
         end
             end
    
  if buy.selected == true and endlessLimit == 5 then   
    if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("You have the maximum amount of endless lives!")
         end
             end

   -- Touch events for the FoodFall minigame lives
   if minus1.selected == true then 
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1",   5)
     end
        if addedLives > addedLimit then
               addedLives = addedLives-1
           end
       end
    
   if plus1.selected == true then 
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
        if addedLives < 5 then
           addedLives = addedLives + 1
       end
   end

  if buy1.selected == true and addedLives > addedLimit and coins >= cost1 then 
if soundEffects == true then
sound("Game Sounds One:Bell 2")
end
  saveLocalData("addedLives",addedLives)
       addedLimit = addedLives
       coins = coins - cost1 
       end
    
if buy1.selected == true and addedLives > addedLimit and coins < cost1 then 
     if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("Not enough coins! You need "..cost1-coins.." more coins!")
         end
             end
    
if buy1.selected == true and addedLimit == 5 then 
  if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("You have the maximum amount of foodfall lives!")
         end
             end
    
   -- Touch events for the bonus coins 
   if minus2.selected == true then 
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 1",   5)
     end
        if moreCoins > coinsLimit then
               moreCoins = moreCoins - 50
           end
       end 
    
    if plus2.selected == true then 
     if soundEffects == true then
     sound("A Hero's Quest:Arrow Shoot 2",  5)
     end
        if moreCoins < 250 then
           moreCoins = moreCoins + 50
       end
   end
    
   if buy2.selected == true and moreCoins > coinsLimit and coins >= cost2 then
if soundEffects == true then
sound("Game Sounds One:Bell 2")
end
    saveLocalData("moreCoins",moreCoins)
       coinsLimit = moreCoins
               coins  = coins - cost2 
               end
    
if buy2.selected == true and moreCoins > coinsLimit and coins < cost2 then
     if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("Not enough coins! You need "..cost2-coins.." more coins!")
         end
               end
    
    
    if buy2.selected == true and coinsLimit == 250 then
     if soundEffects == true then
         sound("Game Sounds One:Wrong", 5)
         alert("You have the maximum level play coin bonus!")
         end
               end
    
    if backButton.selected == true then
        if soundEffects == true then
        sound("Game Sounds One:Pistol",    5)
        end
        Scene.Change("Setup")
endlessLives = endlessLimit
addedLives = addedLimit
moreCoins = coinsLimit
        end
           end



























--# Level
-- Level Setup
-- Made by: Patrick
Level = class()
-- Global 
levelSetup = 0
lives = 0
tutorialOn = 0

-- Buttons
local levelOne
local levelTwo
local levelThree
local levelFour
local levelFive
local levelSix
local levelSeven
local levelEight
local levelNine
local levelTen
local levelEleven
local levelTwelve
local levelThirteen
local levelFourteen
local levelFiveteen
local levelSixteen
local levelSeventeen
local levelEighteen
local levelNineteen
local levelTwenty
local backButton
local foodInfo



function Level:init(x)  
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- Buttons 
levelOne = Button("Dropbox:Unlocking",vec2(WIDTH/2-375,475))
levelTwo = Button("Dropbox:Unlocking", vec2(WIDTH/2-125,475))
levelThree = Button("Dropbox:Unlocking", vec2(WIDTH/2+125,475))
levelFour = Button("Dropbox:Unlocking", vec2(WIDTH/2+375,475))
levelFive = Button("Dropbox:Unlocking", vec2(WIDTH/2-375,375))
levelSix = Button("Dropbox:Unlocking",vec2(WIDTH/2-125,375))
levelSeven = Button("Dropbox:Unlocking", vec2(WIDTH/2+125,375))
levelEight = Button("Dropbox:Unlocking", vec2(WIDTH/2+375,375))
levelNine = Button("Dropbox:Unlocking", vec2(WIDTH/2-375,275))
levelTen = Button("Dropbox:Unlocking", vec2(WIDTH/2-125,275))
levelEleven = Button("Dropbox:Unlocking", vec2(WIDTH/2+125,275))
levelTwelve = Button("Dropbox:Unlocking", vec2(WIDTH/2+375,275))
levelThirteen = Button("Dropbox:Unlocking", vec2(WIDTH/2-375,175))
levelFourteen = Button("Dropbox:Unlocking", vec2(WIDTH/2-125,175))
levelFiveteen = Button("Dropbox:Unlocking", vec2(WIDTH/2+125,175))
levelSixteen = Button("Dropbox:Unlocking", vec2(WIDTH/2+375,175))
levelSeventeen = Button("Dropbox:Unlocking", vec2(WIDTH/2-375,75))
levelEighteen = Button("Dropbox:Unlocking", vec2(WIDTH/2-125,75))
levelNineteen = Button("Dropbox:Unlocking", vec2(WIDTH/2+125,75))
levelTwenty = Button("Dropbox:Unlocking", vec2(WIDTH/2+375,75))
tutorial = Button("Dropbox:Tutorial",vec2(WIDTH/2,575))
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))        
foodInfo = Button("Dropbox:Food Info Icon", vec2(WIDTH/2+410, 675))        
    
-- Unlocking levels
if lockLevels > 0 then
levelOne = Button("Dropbox:Level 01",vec2(WIDTH/2-375,475))
end
    
if lockLevels > 1 then
levelTwo = Button("Dropbox:Level 02", vec2(WIDTH/2-125,475))
end
    
if lockLevels > 2 then
levelThree = Button("Dropbox:Level 03", vec2(WIDTH/2+125,475))
end
    
if lockLevels > 3 then
levelFour = Button("Dropbox:Level 04", vec2(WIDTH/2+375,475))
end
    
if lockLevels > 4 then
levelFive = Button("Dropbox:Level 05", vec2(WIDTH/2-375,375))
end
    
if lockLevels > 5 then
levelSix = Button("Dropbox:Level 06",vec2(WIDTH/2-125,375))
end
    
if lockLevels > 6 then
levelSeven = Button("Dropbox:Level 07", vec2(WIDTH/2+125,375))
end
        
if lockLevels > 7 then
levelEight = Button("Dropbox:Level 08", vec2(WIDTH/2+375,375))
end
            
if lockLevels > 8 then
levelNine = Button("Dropbox:Level 09", vec2(WIDTH/2-375,275))
end
                
if lockLevels > 9 then
levelTen = Button("Dropbox:Level 10", vec2(WIDTH/2-125,275))
end            
                    
if lockLevels > 10 then
levelEleven = Button("Dropbox:Level 11", vec2(WIDTH/2+125,275))
end
                        
if lockLevels > 11 then
levelTwelve = Button("Dropbox:Level 12", vec2(WIDTH/2+375,275))
end
                            
if lockLevels > 12 then
levelThirteen = Button("Dropbox:Level 13", vec2(WIDTH/2-375,175))
end
                                
if lockLevels > 13 then
levelFourteen = Button("Dropbox:Level 14", vec2(WIDTH/2-125,175))
end                            
                                    
if lockLevels > 14 then
levelFiveteen = Button("Dropbox:Level 15", vec2(WIDTH/2+125,175))
end
                                        
if lockLevels > 15 then
levelSixteen = Button("Dropbox:Level 16", vec2(WIDTH/2+375,175))
end                                    
                                            
if lockLevels > 16 then
levelSeventeen = Button("Dropbox:Level 17", vec2(WIDTH/2-375,75))
end                                        
                                                
if lockLevels > 17 then
levelEighteen = Button("Dropbox:Level 18", vec2(WIDTH/2-125,75))
end
                                                
if lockLevels > 18 then
levelNineteen = Button("Dropbox:Level 19", vec2(WIDTH/2+125,75))
end 
                                                                                                       
if lockLevels > 19 then
levelTwenty = Button("Dropbox:Level 20", vec2(WIDTH/2+375,75))
end  
    end  



function Level:draw()
-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end

-- Level Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")  
-- Text    
text("Food Mania",WIDTH/2,725)  
fontSize(60)
text("Level Play",WIDTH/2,675)       
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2+410,690)
text(coins,WIDTH/2+410,600)   
    
      

-- Drawing Buttons    
levelOne:draw()
levelTwo:draw()
levelThree:draw()
levelFour:draw()
levelFive:draw()
levelSix:draw()
levelSeven:draw()
levelEight:draw()
levelNine:draw()
levelTen:draw()
levelEleven:draw()
levelTwelve:draw()
levelThirteen:draw()
levelFourteen:draw()
levelFiveteen:draw()
levelSixteen:draw()
levelSeventeen:draw()
levelEighteen:draw()
levelNineteen:draw()
levelTwenty:draw()
tutorial:draw()
backButton:draw()      
tutorial:draw()
backButton:draw()     
--foodInfo:draw()  
end


function Level:touched(touch)
-- Level Buttons
tutorial: touched(touch)
    if tutorial.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Teach")
        tutorialOn = 1
        end
 

levelOne:touched(touch)
if lockLevels == 0 then
if levelOne.selected == true then
alert("You must complete the tutorial!")
        end
    end

if lockLevels > 0 then   
    if levelOne.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 1
        lives = 3
        end
    end

levelTwo:touched(touch)
if lockLevels < 2 then
if levelTwo.selected == true then
alert("You must finish level 1!")
        end
    end   
    

if lockLevels > 1 then    
    if levelTwo.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 2
        lives = 3
        end
            end
    
levelThree:touched(touch)
if lockLevels < 3 then
if levelThree.selected == true then
alert("You must finish level 2!")
        end
    end   
if lockLevels > 2 then    
    if levelThree.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 3
        lives = 4
        end
            end



levelFour:touched(touch)
if lockLevels < 4 then
if levelFour.selected == true then
alert("You must finish level 3!")
        end
    end   
        
if lockLevels > 3 then
    if levelFour.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 4  
        lives = 5
        end
    end
  

levelFive:touched(touch)
if lockLevels < 5 then
if levelFive.selected == true then
alert("You must finish level 4!")
        end
    end   
        
if lockLevels > 4 then  
    if levelFive.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 5
        lives = 5
        end
    end

levelSix:touched(touch)
if lockLevels < 6 then
if levelSix.selected == true then
alert("You must finish level 5!")
        end
    end   
        
if lockLevels > 5 then
    if levelSix.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 6
        lives = 6
        end
    end
 

levelSeven:touched(touch)
if lockLevels < 7 then
if levelSeven.selected == true then
alert("You must finish level 6!")
        end
    end   
    
if lockLevels > 6 then   
    if levelSeven.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 7
        lives = 6
        end
    end


levelEight:touched(touch)
if lockLevels < 8 then
if levelEight.selected == true then
alert("You must finish level 7!")
        end
    end   
    
if lockLevels > 7 then
   if levelEight.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 8
        lives = 7
        end
    end


levelNine:touched(touch)
if lockLevels < 9 then
if levelNine.selected == true then
alert("You must finish level 8!")
        end
    end   
    
if lockLevels > 8 then    
    if levelNine.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 9
        lives = 7
        end
    end


levelTen:touched(touch)
if lockLevels < 10 then
if levelTen.selected == true then
alert("You must finish level 9!")
        end
    end   
        
if lockLevels > 9 then
    if levelTen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 10
        lives = 8
        end
    end


levelEleven:touched(touch)
if lockLevels < 11 then
if levelEleven.selected == true then
alert("You must finish level 10!")
        end
    end 
      
if lockLevels > 10 then
    if levelEleven.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 11
        lives = 8
        end
    end
 
 
levelTwelve:touched(touch)
if lockLevels < 12 then
if levelTwelve.selected == true then
alert("You must finish level 11!")
        end
    end   
    
if lockLevels > 11 then  
    if levelTwelve.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 12
        lives = 9
        end
    end


levelThirteen:touched(touch)
if lockLevels < 13 then
if levelThirteen.selected == true then
alert("You must finish level 12!")
        end
    end   
    
if lockLevels > 12 then
    if levelThirteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 13
        lives = 9
        end
   end


levelFourteen:touched(touch)
if lockLevels < 14 then
if levelFourteen.selected == true then
alert("You must finish level 13!")
        end
    end   
    
if lockLevels > 13 then            
    if levelFourteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 14    
        lives = 10
        end
    end
 

levelFiveteen:touched(touch)
if lockLevels < 15 then
if levelFiveteen.selected == true then
alert("You must finish level 14!")
        end
    end   
    
if lockLevels > 14 then
    if levelFiveteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 15
        lives = 10
        end
    end

 
levelSixteen:touched(touch)
if lockLevels < 16 then
if levelSixteen.selected == true then
alert("You must finish level 15!")
        end
    end   
    
if lockLevels > 15 then   
    if levelSixteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 16
        lives = 11
        end
    end


levelSeventeen:touched(touch)
if lockLevels < 17 then
if levelSeventeen.selected == true then
alert("You must finish level 16!")
        end
    end   
    
if lockLevels > 16 then
    if levelSeventeen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 17
        lives = 12
        end
    end


levelEighteen:touched(touch)
if lockLevels < 18 then
if levelEighteen.selected == true then
alert("You must finish level 17!")
        end
    end   
    
if lockLevels > 17 then
    if levelEighteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 18
        lives = 13
        end
    end


levelNineteen:touched(touch)
if lockLevels < 19 then
if levelNineteen.selected == true then
alert("You must finish level 18!")
        end
    end   
    
if lockLevels > 18 then
    if levelNineteen.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 19
        lives = 14
        end
    end


levelTwenty:touched(touch)
if lockLevels < 20 then
if levelTwenty.selected == true then
alert("You must finish level 19!")
        end
    end   
    
if lockLevels > 19 then
    if levelTwenty.selected == true then
if soundEffects == true then
sound("A Hero's Quest:Attack Cast 1")
end
        Scene.Change("Game")
        levelSetup = 20
        lives = 15
        end
    end
    
-- Back Button        
backButton:touched(touch)
    if backButton.selected == true then
if soundEffects == true then
     sound("Game Sounds One:Pistol",    5)
     end
        Scene.Change("Setup")
        levelOn = false
        end
    
-- Food Info
-- foodInfo:touched(touch)
    if foodInfo.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pillar Hit")
end
        foodPrevious = 1
        Scene.Change("Food")
        end
    end   




























--# Tutorial

-- Made by: Patrick
Tutorial = class()

-- Button/Switches
local startButton

-- Moving food 
local moveFood = true
local moveFood2 = true

-- Timers
local startsTimer 
local nextTimer 
local moreTimer 
local almostTimer 
local endTimer
local timer 

-- Text
local allText = 1
local indicator = 0

function Tutorial:init(x)
-- Start Button
startButton = Button("Dropbox:Play Icon", vec2(WIDTH/2,HEIGHT/2))
hiddenButton = Button("Dropbox:Background-1", vec2(WIDTH/2,HEIGHT/2))

-- Food 1
myFood = "Dropbox:Food-Apple"  
foodSize = vec2(spriteSize(myFood))
foodPosition = vec2()
-- Food 2    
myFood2 = "Dropbox:Food-Cookie"
foodSize2 = vec2(spriteSize(myFood2))
foodPosition2 = vec2()
-- Plate
plate = "Dropbox:Plate"
plateSize = vec2(spriteSize(plate))
platePosition = vec2()
       
-- Position of the food and plate
platePosition = vec4(WIDTH/2+75,225)
foodPosition = vec2(-800,600)
foodPosition2 = vec2(-800,600)   
    
-- Timers
 startTimer = 0
 nextTimer = 0
 moreTimer = 0
 almostTimer = 0
 closeTimer = 0
 endTimer = 0
 timer = 0
end

function Tutorial:draw()    
-- Background       
sprite("Documents:Picnic",512, 320, 1024, 900)
-- Text Setup
strokeWidth(5)
fill(255, 24, 0, 255)
fontSize(40)
font("Copperplate")
    
if allText >3 and allText < 8 or allText > 18 then        
sprite(plate, platePosition.x, platePosition.y)   
sprite(myFood, foodPosition.x, foodPosition.y)      
sprite(myFood2,foodPosition2.x, foodPosition2.y)
end
         

-- All the text    
if allText == 1 then
    text("Welcome to Food Mania!",WIDTH/2,740)
    text("Food Mania is a fun food matching game!",WIDTH/2,700)
    text("Tap anywhere to continue!", WIDTH/2,660)
    end
if allText == 2 then
    text("This tutorial will be showing you", WIDTH/2,740)
    text("how to play levels in level play!", WIDTH/2,700)
    end
    
if allText == 3 then
    text("Click the start button to begin",WIDTH/2,740)    
    text("your step by step tutorial!", WIDTH/2,700)        
    end
     
if allText == 4  then
    text("Your goal is to drag the healthy foods", WIDTH/2,740)
    text("onto your plate, try that now!", WIDTH/2,700)
    end
if allText == 5 then
    text("But be careful, you must leave the", WIDTH/2,740)
    text("junk food behind, try that now!", WIDTH/2,700)
    end
    
if allText == 6  then    
    text("Good job! But be aware of your lives! You lose", WIDTH/2,740)
    text("1 life everytime you miss a healthy food or", WIDTH/2,700)
    text("when you put a junk food onto your plate. ", WIDTH/2,660)
    end   
    
if allText == 7 then
    text("You win the level when you make your points ", WIDTH/2,740)
    text("equal to your Winscore. You get 10 points  ", WIDTH/2,700)
    text("everytime you miss a junk food or when you ", WIDTH/2,660)
    text("put a healthy food onto your plate.", WIDTH/2,620)
    end  
    
if allText == 8 then 
    text("If you get the chance, check out the Food",WIDTH/2,740)
    text("Catalogue to see which foods are healthy or",WIDTH/2,700)
    text("unhealthy and why they're that way!",WIDTH/2,660)
    end   
    
if allText == 9 then 
    text("Congratulations! You completed the tutorial!",WIDTH/2,740)
    text("Click the start button to play level 1!",WIDTH/2,700)
    text("Complete levels to unlock new levels!",WIDTH/2,660)
    end
    
if allText == 20 then
    text("Oops, you let the healthy food pass by!", WIDTH/2,740)
    text("Tap anywhere to try again!", WIDTH/2,700)
    end
    
if allText == 21  then
    text("Oops, you shouldn't pick up junk food!", WIDTH/2,740)
    text("Tap anywhere to try again!", WIDTH/2,700)
    end 
    
-- Drawing points    
if allText == 7 then
sprite("Dropbox:Comic Textbox", 265,400,380,180)
sprite("Dropbox:Boy", WIDTH/2-200,175,135,300)
text ("Points: 100",265,450)   
text ("Winscore: 100",265,400)    
end
        
-- Drawing lives
if allText == 6 then
sprite("Text", 140,95,210,200)
sprite("Dropbox:Boy", WIDTH/2-200,175,135,300)
fontSize(60)
text("x10",135,40)     
sprite("Dropbox:Sprite-Heart",135,110)
end

if allText == 6 or allText == 7 then        
-- Narnia
if boughtHat == true then
if saveHat == 2 then            
sprite("Dropbox:Store-Knight Head",WIDTH/2-210,290) 
end
    end        
if boughtShirt == true then
if saveShirt == 2 then
sprite("Dropbox:Store-Knight sword",WIDTH/2 - 300,145)
end
    end
if boughtPants == true then
if savePants == 2 then
sprite("Dropbox:Store-Knight shield",WIDTH/2 - 140,175)
end
    end
    
-- Jones
if boughtHat2 == true then
if saveHat == 3 then
sprite("Dropbox:Store-Cowboy hat",WIDTH/2-200,320) 
end
    end
if boughtShirt2 == true then
if saveShirt == 3 then
sprite("Dropbox:Store-Cowboy whip",WIDTH/2 - 300,200)
end
    end
if boughtPants2 == true then
if savePants == 3 then
sprite("Dropbox:Store-Cowboy book",WIDTH/2 - 130,190)
end
    end

 
-- Star Wars
if boughtHat3 == true then
if saveHat == 4 then            
sprite("Documents:Store-Starwars hat",WIDTH/2-200,280) 
end
    end        
if boughtShirt3 == true then
if saveShirt == 4 then
sprite("Documents:Store-Starwars lightsaber",WIDTH/2 - 300,225)
end
    end
if boughtPants3 == true then
if savePants == 4 then
sprite("Documents:Store-Starwars lightning",WIDTH/2 - 70,115)
end
    end
      
-- Avengers
if boughtHat4 == true then
if saveHat == 5 then
sprite("Dropbox:Store-Avenger ironman",WIDTH/2-200,280) 
end
    end
if boughtShirt4 == true then
if saveShirt == 5 then
sprite("Dropbox:Store-Avenger thor",WIDTH/2 - 285,215)
end
    end
if boughtPants4 == true then
if savePants == 5 then
sprite("Dropbox:Store-Avenger captain",WIDTH/2 - 140,175)
end
    end
        end
    
  
if allText == 8 then  
--sprite("Dropbox:Healthy", WIDTH/2,HEIGHT/2-225)
--sprite("Dropbox:Junk", WIDTH/2,HEIGHT/2-50)
sprite("Dropbox:Food Info Icon", WIDTH/2,HEIGHT/2+100)
    end

     
-- Drawing start button    
if allText == 3 or allText == 9 then
    startButton:draw()
    end
     
-- Moving first food across screen
if allText == 4 then
if moveFood == true then
foodPosition.x = foodPosition.x + 8
end
    end
    
-- Moving second food across screen  
if allText == 5 then
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + 8
end          
    end
    
--If touching edge
-- First food
if foodPosition.x > 1100 then
foodPosition.x = -600
allText = 20
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end  
      
-- Second food
if foodPosition2.x > 1100 then
allText = 6
foodPosition2.x = -600
    end
     
-- Timed text
if allText == 1 then
startTimer = startTimer + 1/60       
if math.floor(startTimer + 1) > 2 then
indicator = -1
        end
    end
    
if indicator == -1 then
nextTimer = nextTimer + 1/60       
if math.floor(nextTimer + 1) > 2 then
indicator = -2
        end
    end

if allText == 6 then
moreTimer = moreTimer + 1/60       
if math.floor(moreTimer + 1) > 3 then
indicator = -3
        end
    end 
    
if allText == 7 then
almostTimer = almostTimer + 1/60       
if math.floor(almostTimer + 1) > 3 then
indicator = -4
        end
    end 
    
if allText == 8 then
closeTimer = closeTimer + 1/60       
if math.floor(closeTimer + 1) > 2 then
indicator = -5
        end
    end

if allText == 9 then
endTimer = endTimer + 1/60       
if math.floor(endTimer + 1) > 1 then
indicator = -6
        end
    end     
         
    
if allText == 3 then  
timer = timer + 1/60       
if math.floor(timer + 1) > 1 then
indicator = 2
        end
    end
    
        end




function Tutorial:touched(touch)
hiddenButton:touched(touch)   
-- Making start button touched
if indicator == -6 or indicator == 2 then
    startButton:touched(touch)
    end
    
-- Starting new text    
if indicator == 2 then
if startButton.selected == true then
allText = 4
indicator = 0
end
    end
            

-- Retrying to drag healthy food
if allText == 20 then
if (touch.state == BEGAN) then 
allText = 4
    end
end

-- Retrying to drag junk food
if allText == 21 then
if (touch.state == BEGAN) then 
allText = 5
    end
end
    
    

-- Text
if allText == 1 then 
if indicator == -1 then
if hiddenButton.selected == true then 
allText = 2
        end
    end
end
          
--if allText == 2 then
if indicator == -2 then 
if hiddenButton.selected == true then 
allText = 3
        end
    end
--end
            
if allText == 6 then 
if indicator == -3 then 
if hiddenButton.selected == true then 
allText = 7
        end 
    end
end
                 
if allText == 7 then 
if indicator == -4 then 
if (touch.state == BEGAN) then 
allText = 8
        end
    end
end
    
if allText == 8 then 
if indicator == -5 then 
if hiddenButton.selected == true then 
allText = 9
        end
    end
end
        
    -- Level one
    if indicator == -6 then
if startButton.selected == true then
Scene.Change("Game")   
-- Deciding what level to choose
levelSetup = 1
lives = 3   
allText = 1
indicator = 0
end
    end
            
-- Unlocking level 1
if lockLevels == 0 then
lockLevels = 1
saveLocalData("levels",lockLevels)
end
    
    -- Touch position
    local currentTouchPosition = vec2(touch.x,touch.y)
    local currentTouchPosition2 = vec2(touch.x,touch.y)
    
     -- Moving Food 1
        if (touch.state == MOVING) then
           if( (foodPosition.x - foodSize.x/2) < currentTouchPosition.x and
             (foodPosition.x + foodSize.x/2) > currentTouchPosition.x and
             (foodPosition.y - foodSize.y/2) < currentTouchPosition.y and
             (foodPosition.y + foodSize.y/2) > currentTouchPosition.y ) then
                            
            foodPosition= currentTouchPosition
            moveFood = false
            end
                end
    
     -- Moving Food 2
        if (touch.state == MOVING) then
           if( (foodPosition2.x - foodSize2.x/2) < currentTouchPosition2.x and
             (foodPosition2.x + foodSize2.x/2) > currentTouchPosition2.x and
             (foodPosition2.y - foodSize2.y/2) < currentTouchPosition2.y and
             (foodPosition2.y + foodSize2.y/2) > currentTouchPosition2.y ) then
            
            foodPosition2= currentTouchPosition2
            moveFood2 = false
            end
                end

if (touch.state == ENDED) then
-- Food 1 detection with plate
if( foodPosition.x - foodSize.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition.x + foodSize.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition.y - foodSize.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition.y + foodSize.y/2 > platePosition.y-65)then
allText = 5
foodPosition.x = -1000
foodPosition.y = 600     
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end          
    else
moveFood = true
foodPosition.y = 600
end
    end
    
       
if (touch.state == ENDED) then 
-- Food 2 detection with plate
if( foodPosition2.x - foodSize2.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition2.x + foodSize2.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition2.y - foodSize2.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition2.y + foodSize2.y/2 > platePosition.y-65)then
allText = 21
foodPosition2.x = -600
foodPosition2.y = 600    
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    else
moveFood2 = true
foodPosition2.y = 600
end
    end
end



























--# Game


-- Level Play/Endless
-- Made by: Patrick
Game = class()

-- Timer
local startTimer = 0
local timer = 0

-- Buttons
local startButton
local pauseButton
local homeButton
local howToButton 
local foodInfo
local backButton

-- Pause
local pauseBegins = false 
-- Game control
local scoreOn = true
local endlessSpeed = 6
buttonDraw = 1

-- Moving food 
local moveFood = true
local moveFood2 = true
local moveFood3 = true
local moveFood4 = true
local moveFood5 = true

-- Random food generator
local foodSelector = math.random(1,5)
local foodSelector2 = math.random(1,5)
local foodSelector3 = math.random(1,5)
local foodSelector4 = math.random(1,5)
local foodSelector5 = math.random(1,5)

-- Points
local winScore = 80
score = 0
winningScore = 0
endlessScore = 0

-- Next Scene
giveCoins = false
newScore = false
gameOver = false

-- Food Sprites
local myFood = "Dropbox:Food-Apple"
local myFood2 = "Dropbox:Food-Apple"
local myFood3 = "Dropbox:Food-Apple"
local myFood4 = "Dropbox:Food-Apple"
local myFood5 = "Dropbox:Food-Apple"

-- Food Position
local foodPosition = vec2()
local foodPosition2 = vec2()
local foodPosition3 = vec2()
local foodPosition4 = vec2()
local foodPosition5 = vec2()



function Game:init(x)   
 supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
    
-- Food Size
foodSize = vec2(spriteSize(myFood))
foodSize2 = vec2(spriteSize(myFood2))
foodSize3 = vec2(spriteSize(myFood3))
foodSize4 = vec2(spriteSize(myFood4))
foodSize5 = vec2(spriteSize(myFood5))
    
-- Plate 
plate = "Dropbox:Plate"
plateSize = vec2(spriteSize(plate))
platePosition = vec2()
  
-- Buttons
startButton = Button("Dropbox:Play Icon", vec2(WIDTH/2,HEIGHT/2))
homeButton = Button("Dropbox:Home Icon", vec2(WIDTH/2+200, HEIGHT/2))
pauseButton = Button("Dropbox:Pause Icon", vec2(WIDTH/2+430, HEIGHT/2-310))

howToButton = Button("Dropbox:Help Icon", vec2(WIDTH/2+410, 100))   
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))     
foodInfo = Button("Dropbox:Food Info Icon", vec2(WIDTH/2-410, 100))     
    
-- Position of the food and plate
platePosition = vec2(WIDTH/2+75,225)
foodPosition = vec2(-100,600)
foodPosition2 = vec2(-600,600)
foodPosition3 = vec2(-1100,600)
foodPosition4 = vec2(-1600,600)
foodPosition5 = vec2(-2100,600)
end


function Game:draw() 
-- Choosing Background 
if buttonDraw == 1 then      
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end
    end
     
if buttonDraw == 2 or buttonDraw == 3 then      
sprite("Documents:Picnic",512, 320, 1024, 900)
sprite("Dropbox:Comic Textbox", 265,400,380,180)
sprite("Documents:Text", 140,95,210,200)
sprite("Dropbox:Boy", WIDTH/2-200,175,135,300)
        
-- Narnia
if boughtHat == true then
if saveHat == 2 then            
sprite("Dropbox:Store-Knight Head",WIDTH/2-210,290) 
end
    end        
if boughtShirt == true then
if saveShirt == 2 then
sprite("Dropbox:Store-Knight sword",WIDTH/2 - 300,145)
end
    end
if boughtPants == true then
if savePants == 2 then
sprite("Dropbox:Store-Knight shield",WIDTH/2 - 140,175)
end
    end
    
-- Jones
if boughtHat2 == true then
if saveHat == 3 then
sprite("Dropbox:Store-Cowboy hat",WIDTH/2-200,320) 
end
    end
if boughtShirt2 == true then
if saveShirt == 3 then
sprite("Dropbox:Store-Cowboy whip",WIDTH/2 - 300,200)
end
    end
        
               
if boughtPants2 == true then
if savePants == 3 then
sprite("Dropbox:Store-Cowboy book",WIDTH/2 - 130,190)
end
    end
 
-- Star Wars
if boughtHat3 == true then
if saveHat == 4 then            
sprite("Documents:Store-Starwars hat",WIDTH/2-200,280) 
end
    end        
if boughtShirt3 == true then
if saveShirt == 4 then
sprite("Documents:Store-Starwars lightsaber",WIDTH/2 - 300,225)
end
    end
if boughtPants3 == true then
if savePants == 4 then
sprite("Documents:Store-Starwars lightning",WIDTH/2 - 70,115)
end
    end
        
-- Avengers
if boughtHat4 == true then
if saveHat == 5 then
sprite("Dropbox:Store-Avenger ironman",WIDTH/2-200,280) 
end
    end
if boughtShirt4 == true then
if saveShirt == 5 then
sprite("Dropbox:Store-Avenger thor",WIDTH/2 - 285,215)
end
    end
if boughtPants4 == true then
if savePants == 5 then
sprite("Dropbox:Store-Avenger captain",WIDTH/2 - 140,175)
end
    end
        end

-- Food position
if buttonDraw == 2 or buttonDraw == 3 then
sprite(plate, platePosition.x, platePosition.y)  
sprite(myFood, foodPosition.x, foodPosition.y)      
sprite(myFood2,foodPosition2.x, foodPosition2.y)      
sprite(myFood3, foodPosition3.x, foodPosition3.y)     
sprite(myFood4,foodPosition4.x, foodPosition4.y)              
sprite(myFood5, foodPosition5.x, foodPosition5.y)      
end
     

-- Selecting the different levels to play and choosing their difficulty    
-- Winscore for levels 1-19
if levelSetup > 0 and levelSetup < 20 then  
    if scoreOn == true then
    winScore = winScore + (levelSetup * 20) 
    scoreOn = false
    end
        end
-- Winscore for level 20
if levelSetup == 20 then  
    winScore = 500
    end
 
-- Food speed for levels 1-3   
if levelSetup > 0 and levelSetup < 4 then      
    if buttonDraw == 2 then            
if moveFood == true then
foodPosition.x = foodPosition.x + (5 + (levelSetup * 0.5))
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + (5 + (levelSetup * 0.5))
end
    end   
end    
        

-- Food speed for levels 4-7
if levelSetup > 3 and levelSetup < 8 then
    if buttonDraw == 2 then             
if moveFood == true then
foodPosition.x = foodPosition.x + (3 + (levelSetup * 0.5))
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + (3 + (levelSetup * 0.5))
end
if moveFood3 == true then
foodPosition3.x = foodPosition3.x + (3 + (levelSetup * 0.5))
end
    end
end
    
-- Food speed for levels 8-12
if levelSetup > 7 and levelSetup < 13 then
    if buttonDraw == 2 then        
if moveFood == true then
foodPosition.x = foodPosition.x + (1 + (levelSetup * 0.5))
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + (1 + (levelSetup * 0.5))
end
if moveFood3 == true then
foodPosition3.x = foodPosition3.x + (1 + (levelSetup * 0.5))
end
if moveFood4 == true then
foodPosition4.x = foodPosition4.x + (1 + (levelSetup * 0.5))
end
    end
end
    

-- Food speed for levels 13-18
if levelSetup > 12 and levelSetup < 19 then
    if buttonDraw == 2 then         
if moveFood == true then
foodPosition.x = foodPosition.x + (-1 + (levelSetup * 0.5))
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + (-1 + (levelSetup * 0.5))
end
if moveFood3 == true then
foodPosition3.x = foodPosition3.x + (-1 + (levelSetup * 0.5))
end
if moveFood4 == true then
foodPosition4.x = foodPosition4.x + (-1 + (levelSetup * 0.5))
end
if moveFood5 == true then
foodPosition5.x = foodPosition5.x + (-1 + (levelSetup * 0.5))
end
    end   
end
    
    
-- Food speed for levels 19-20
if levelSetup > 18 and levelSetup < 21 then
    if buttonDraw == 2 then         
if moveFood == true then
foodPosition.x = foodPosition.x + (-10 + (levelSetup * 1))
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + (-10 + (levelSetup * 1))
end
if moveFood3 == true then
foodPosition3.x = foodPosition3.x + (-10 + (levelSetup * 1))
end
if moveFood4 == true then
foodPosition4.x = foodPosition4.x + (-10 + (levelSetup * 1))
end
if moveFood5 == true then
foodPosition5.x = foodPosition5.x + (-10 + (levelSetup * 1))
end
    end   
end
    
        
-- Minigame Endless   
if foodOn == true then
    if buttonDraw == 3 then     
     -- Timer
    timer = timer + 1/60
    if math.floor(timer + 1) > 5 then
        endlessSpeed = 7
        end      
    if math.floor(timer + 1) > 15 then
        endlessSpeed = 8
        end  
    if math.floor(timer + 1) > 25 then
        endlessSpeed =  9
        end
    if math.floor(timer + 1) > 35 then
        endlessSpeed = 10
        end
    if math.floor(timer + 1) > 45 then
        endlessSpeed = 11
        end
    if math.floor(timer + 1) > 60 then
        endlessSpeed = 12
        end
       if math.floor(timer + 1) > 100 then
        endlessSpeed = 14
        end

   
if moveFood == true then
foodPosition.x = foodPosition.x + endlessSpeed
end
if moveFood2 == true then
foodPosition2.x = foodPosition2.x + endlessSpeed
end
if moveFood3 == true then
foodPosition3.x = foodPosition3.x + endlessSpeed
end
if moveFood4 == true then
foodPosition4.x = foodPosition4.x + endlessSpeed
end
if moveFood5 == true then
foodPosition5.x = foodPosition5.x + endlessSpeed
end
    end
        end

        
-- When food reaches the edge
-- First food
if foodPosition.x > 1100 then
foodPosition.x = -750
foodSelector = math.random(1,5)
-- Bad Food
if myFood == "Dropbox:Food-Apple" or myFood == "Dropbox:Food-Broccoli" or myFood == "Dropbox:Food-Bread" or    myFood == "Dropbox:Food-Egg" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end
-- Good Food
if myFood == "Dropbox:Food-Fries"  then          
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end    
        end

-- Second food    
if foodPosition2.x > 1100 then
foodPosition2.x = -750
foodSelector2 = math.random(1,5)
-- Bad Food
if myFood2  == "Dropbox:Food-Banana" or myFood2 == "Dropbox:Food-Potato" or myFood2  == "Dropbox:Food-Corn" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end
-- Good Food
if myFood2  == "Dropbox:Food-Hotdog" or myFood2 == "Dropbox:Food-Donuts" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end 
        end        

-- Third food
if foodPosition3.x > 1100 then
foodPosition3.x = -750
foodSelector3 = math.random(1,5)
-- Bad Food
if myFood3  == "Dropbox:Food-Grapes" or myFood3  == "Dropbox:Food-Carrot" or myFood3  == "Dropbox:Food-Muffin" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end 
-- Good Food         
if myFood3 == "Dropbox:Food-Hamburger" or myFood3 == "Dropbox:Food-Cake" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end 
        end
        
-- Fourth food
if foodPosition4.x > 1100 then
foodPosition4.x = -750
foodSelector4 = math.random(1,5)
-- Bad Food
if myFood4 =="Dropbox:Food-Strawberry" or myFood4 == "Dropbox:Food-Cucumber" or myFood4  == "Dropbox:Food-Ham" or myFood4  == "Dropbox:Food-Cheese" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end
-- Good Food
if myFood4  == "Dropbox:Food-Cookie" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end   
        end  
    
-- Fifth food      
if foodPosition5.x > 1100 then
foodPosition5.x = -750
foodSelector5 = math.random(1,5)
-- Bad Food
if myFood5  == "Dropbox:Food-Pumpkin" or myFood5  == "Dropbox:Food-Eggplant" or myFood5  == "Dropbox:Food-Steak" or myFood5  == "Dropbox:Food-Milk" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
    end
-- Good Food
if myFood5  == "Dropbox:Food-Cupcake" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end 
        end
        
if buttonDraw == 1 then
startButton:draw() 
 end
    
-- Drawing Buttons  
if buttonDraw == 1 then
if levelOn == true then
backButton:draw()
foodInfo:draw()
-- Coins
strokeWidth(5)
fill(255, 24, 0, 255)
font("Copperplate")    
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2,130)
text(coins,WIDTH/2,40)    
end
    end


if foodOn == true then
if gameOn == true then
if buttonDraw == 1 then
howToButton:draw()
backButton:draw()
foodInfo:draw()
-- Coins
strokeWidth(5)
fill(255, 24, 0, 255)
font("Copperplate")    
fontSize(50)
text("How", WIDTH/2+275,140)
text("to", WIDTH/2+275,100)
text("play", WIDTH/2+279,60)
-- Coins
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2,130)
text(coins,WIDTH/2,40)    
end
    end
        end
    
if buttonDraw == 2 or buttonDraw == 3 then
pauseButton:draw()
end   
if pauseBegins == true then
homeButton:draw()
end

  
-- Selecting random food  
if foodSelector == 1 then
myFood = "Dropbox:Food-Apple"      
    end
if foodSelector == 2 then
myFood = "Dropbox:Food-Broccoli"               
    end
if foodSelector == 3 then
myFood = "Dropbox:Food-Bread"            
    end
if foodSelector == 4 then
myFood = "Dropbox:Food-Egg"               
    end
if foodSelector == 5 then
myFood = "Dropbox:Food-Fries"            
    end      
    
-- Second random food selector 
sprite()   
if foodSelector2 == 1 then   
myFood2  = "Dropbox:Food-Banana"   
    end
if foodSelector2 == 2 then
myFood2 = "Dropbox:Food-Potato" 
    end
if foodSelector2 == 3 then    
myFood2  = "Dropbox:Food-Corn" 
    end    
if foodSelector2 == 4 then
myFood2  = "Dropbox:Food-Hotdog" 
    end 
if foodSelector2 == 5 then
myFood2 = "Dropbox:Food-Donuts"   
    end
      
-- Third random food selector   
sprite()     
if foodSelector3 == 1 then   
myFood3  = "Dropbox:Food-Grapes" 
    end
if foodSelector3 == 2 then
myFood3  = "Dropbox:Food-Carrot" 
    end
if foodSelector3 == 3 then    
myFood3  = "Dropbox:Food-Muffin" 
    end    
if foodSelector3 == 4 then
myFood3 = "Dropbox:Food-Hamburger"  
    end 
if foodSelector3 == 5 then
myFood3  = "Dropbox:Food-Cake" 
    end
        
-- Fourth random food selector    
sprite()
if foodSelector4 == 1 then   
myFood4  = "Dropbox:Food-Strawberry" 
    end
if foodSelector4 == 2 then
myFood4  = "Dropbox:Food-Cucumber" 
    end
if foodSelector4 == 3 then    
myFood4  = "Dropbox:Food-Ham" 
    end    
if foodSelector4 == 4 then
myFood4  = "Dropbox:Food-Cookie"  
    end 
if foodSelector4 == 5 then
myFood4  = "Dropbox:Food-Cheese" 
    end       
    
-- Fifth random food selector        
sprite()
if foodSelector5 == 1 then   
myFood5  = "Dropbox:Food-Pumpkin" 
    end
if foodSelector5 == 2 then
myFood5  = "Dropbox:Food-Eggplant"
    end
if foodSelector5 == 3 then    
myFood5  = "Dropbox:Food-Steak"   
    end    
if foodSelector5 == 4 then
myFood5  = "Dropbox:Food-Cupcake"        
    end 
if foodSelector5 == 5 then
myFood5  = "Dropbox:Food-Milk" 
    end    


-- Text Setup
strokeWidth(5)
fill(255, 24, 0, 255)
fontSize(60)
font("Copperplate")
    
   if buttonDraw == 2 or buttonDraw == 3 then
sprite("Dropbox:Sprite-Heart",135,110) 
if lives < 10 then           
text("x"..lives,135,40)       
else
if lives >= 10 then
text("x"..lives,135,40)       
end
    end
        
fontSize(42)    
   if levelSetup > 0 then
if buttonDraw == 2 then
-- Score  
text ("Points: "..score,265,450)   
text ("Winscore: "..winScore,265,400)
end
    end
        end
    
   if foodOn == true then
if buttonDraw == 3 then
-- Score 
text ("Points: "..score,265,450)   
text ("Highscore: "..saveScore, 265,400) 
end
    end
        

-- Level Play Controls
  if buttonDraw == 2 then    
-- Win the level            
if winScore == score then
winningScore = winScore
score = 0
winScore = 80
scoreOn = true
buttonDraw = 1            
giveCoins = true           
Scene.Change("Gg")
        
-- Unlocking new levels            
if levelSetup == lockLevels then
lockLevels = levelSetup + 1
saveLocalData("levels",lockLevels)
end
    end

-- Game Over                
if lives == 0 then
score = 0
winScore = 80
buttonDraw = 1
foodOn = false
levelOn = false
scoreOn = true
gameOver = true
Scene.Change("Gf")
end
    end
        

   if buttonDraw == 3 then
-- Saving New Highscore
if score > saveScore then
saveScore = score
saveLocalData("score",saveScore)
   end
                
if lives == 0 then
-- Game Over
timer = 0
endlessSpeed = 5
buttonDraw = 1
newScore = true
giveCoins = true
endlessScore = score
Scene.Change("Over")
end
    end
         
            
strokeWidth(5)
fill(255, 55, 0, 255)
fontSize(50)
font("Copperplate")  
if levelSetup > 0 then
if buttonDraw == 1 or 2 then    
text("Level Play - Level "..levelSetup,WIDTH/2,725)  
    end
        end
    
if foodOn == true then    
if buttonDraw == 1 or 3 then
text("Minigame - Endless",WIDTH/2,725)  
    end
        end   
            end



function Game:touched(touch)
-- Start Screen          
if buttonDraw == 1 then   
startButton: touched(touch)   
pauseBegins = false  
if levelOn == true then
backButton:touched(touch)
foodInfo:touched(touch)
                                                  
-- Food Info
    if foodInfo.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pillar Hit")
end
        Scene.Change("Food")
        buttonDraw = 1
        foodPrevious = 2
        end    

   if backButton.selected == true then
if soundEffects == true then
     sound("Game Sounds One:Pistol",    5)
     end
score = 0
winScore = 80
scoreOn = true
levelSetup = 0
endlessSpeed = 5
timer = 0
pauseBegins = false
gameOn = true
levelOn = true
foodOn = false
Scene.Change("Level")
        end    
end
    end

if foodOn == true then
if gameOn == true then
if buttonDraw == 1 then
howToButton:touched(touch)
backButton:touched(touch)
foodInfo:touched(touch)
                    
-- Food Info
    if foodInfo.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pillar Hit")
end
        Scene.Change("Food")
        foodOn = false
        buttonDraw = 1
        foodPrevious = 2
        end 
                   
-- Intructions
if howToButton.selected == true then
       Scene.Change("He")
       foodOn = false
       buttonDraw = 1
       end
    
   if backButton.selected == true then
if soundEffects == true then
     sound("Game Sounds One:Pistol",    5)
     end
        foodOn = false
        buttonDraw = 1
        Scene.Change("Setup")
        end
end
    end
        end
    
-- Game On/ Pause button activated
if startButton.selected == true then
if foodOn == true then
buttonDraw = 3
gameOn = false
pauseButton: touched(touch)                
   else 
buttonDraw = 2  
pauseButton: touched(touch)
levelOn = false
end
    end
    
-- Pause     
if pauseButton.selected == true then
buttonDraw = 1
pauseBegins = true
startButton = Button("Dropbox:Play Icon", vec2(WIDTH/2 - 200,HEIGHT/2))
startButton:touched(touch)
homeButton:touched(touch)
end
 
-- Home Button          
if homeButton.selected == true then
score = 0
winScore = 80
scoreOn = true
levelSetup = 0
foodOn = false
endlessSpeed = 5
timer = 0
pauseBegins = false
gameOn = true
levelOn = false
Scene.Change("Setup")
end 
    
-- Touch position of food, not all are one current touch position to avoid glitches
if buttonDraw == 2 or buttonDraw == 3  then            
local currentTouchPosition = vec2(touch.x,touch.y)
local currentTouchPosition2 = vec2(touch.x,touch.y)
local currentTouchPosition3 = vec2(touch.x,touch.y)
local currentTouchPosition4 = vec2(touch.x,touch.y)
local currentTouchPosition5 = vec2(touch.x,touch.y)

        
-- Dragging the food only when actually touching the sprite itself.    
        -- Dragginf Food 1
        if (touch.state == MOVING) then
           if( (foodPosition.x - foodSize.x/2) < currentTouchPosition.x and
             (foodPosition.x + foodSize.x/2) > currentTouchPosition.x and
             (foodPosition.y - foodSize.y/2) < currentTouchPosition.y and
             (foodPosition.y + foodSize.y/2) > currentTouchPosition.y ) then
                            
            foodPosition= currentTouchPosition
            moveFood = false
            moveFood2 = true
            moveFood3 = true
            moveFood4 = true
            moveFood5 = true
        end
    end
        -- Dragging Food 2
        if (touch.state == MOVING) then
           if( (foodPosition2.x - foodSize2.x/2) < currentTouchPosition2.x and
             (foodPosition2.x + foodSize2.x/2) > currentTouchPosition2.x and
             (foodPosition2.y - foodSize2.y/2) < currentTouchPosition2.y and
             (foodPosition2.y + foodSize2.y/2) > currentTouchPosition2.y ) then
            
            foodPosition2= currentTouchPosition2
            moveFood2 = false
            moveFood = true
            moveFood3 = true
            moveFood4 = true
            moveFood5 = true
        end
    end

       -- Dragging Food 3
        if (touch.state == MOVING) then
           if( (foodPosition3.x - foodSize3.x/2) < currentTouchPosition3.x and
             (foodPosition3.x + foodSize3.x/2) > currentTouchPosition3.x and
             (foodPosition3.y - foodSize3.y/2) < currentTouchPosition3.y and
             (foodPosition3.y + foodSize3.y/2) > currentTouchPosition3.y ) then
            
            foodPosition3= currentTouchPosition3
            moveFood3 = false
            moveFood1 = true
            moveFood2 = true
            moveFood4 = true
            moveFood5 = true
        end
    end
        
        -- Dragging Food 4
        if (touch.state == MOVING) then
           if( (foodPosition4.x - foodSize4.x/2) < currentTouchPosition4.x and
             (foodPosition4.x + foodSize4.x/2) > currentTouchPosition4.x and
             (foodPosition4.y - foodSize4.y/2) < currentTouchPosition4.y and
             (foodPosition4.y + foodSize4.y/2) > currentTouchPosition4.y ) then
            
            foodPosition4= currentTouchPosition4
            moveFood4 = false
            moveFood1 = true
            moveFood2 = true
            moveFood3 = true
            moveFood5 = true            
        end
    end
        
         -- Dragging Food 5
        if (touch.state == MOVING) then
           if( (foodPosition5.x - foodSize5.x/2) < currentTouchPosition5.x and
             (foodPosition5.x + foodSize5.x/2) > currentTouchPosition5.x and
             (foodPosition5.y - foodSize5.y/2) < currentTouchPosition5.y and
             (foodPosition5.y + foodSize5.y/2) > currentTouchPosition5.y ) then
            
            foodPosition5= currentTouchPosition5
            moveFood5 = false
            moveFood1 = true
            moveFood2 = true
            moveFood3 = true
            moveFood4 = true
        end
    end
     
          
        
-- All Food detetcion with plate to decide whether or not it's good or bad food
if (touch.state == ENDED) then
-- Food 1 detection with plate
if( foodPosition.x - foodSize.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition.x + foodSize.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition.y - foodSize.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition.y + foodSize.y/2 > platePosition.y-65)then
if myFood == "Dropbox:Food-Apple" or myFood == "Dropbox:Food-Broccoli" or myFood == "Dropbox:Food-Bread" or     myFood == "Dropbox:Food-Egg" then
    score = score + 10                    
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
    end
if myFood == "Dropbox:Food-Fries"  then          
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",  5)
end
    end   
                                  
foodSelector = math.random(1,5) 
moveFood = true   
foodPosition.x = -750
foodPosition.y = 600                
    else
moveFood = true
foodPosition.y = 600
end
    end
  
              
if (touch.state == ENDED) then 
-- Food 2 detection with plate
if( foodPosition2.x - foodSize2.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition2.x + foodSize2.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition2.y - foodSize2.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition2.y + foodSize2.y/2 > platePosition.y-65 )then
if myFood2  == "Dropbox:Food-Banana" or myFood2 == "Dropbox:Food-Potato" or myFood2  == "Dropbox:Food-Corn" then
    score = score + 10    
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
    end
if myFood2  == "Dropbox:Food-Hotdog" or myFood2 == "Dropbox:Food-Donuts"  then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",  5)
end
    end 
                
foodSelector2 = math.random(1,5) 
moveFood2 = true   
foodPosition2.x = -750
foodPosition2.y = 600                             
    else
moveFood2 = true
foodPosition2.y = 600
end
    end
        end
    
            
if (touch.state == ENDED) then
-- Food 3 detection with plate
if( foodPosition3.x - foodSize3.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition3.x + foodSize3.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition3.y - foodSize3.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition3.y + foodSize3.y/2 > platePosition.y-65)then            
if myFood3  == "Dropbox:Food-Grapes" or myFood3  == "Dropbox:Food-Carrot" or myFood3  == "Dropbox:Food-Muffin" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
    end
if myFood3 == "Dropbox:Food-Hamburger" or myFood3 == "Dropbox:Food-Cake" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",  5)
end    
    end 
        
foodSelector3 = math.random(1,5) 
moveFood3 = true   
foodPosition3.x = -750
foodPosition3.y = 600   
    else
moveFood3 = true
foodPosition3.y = 600
end
    end
 
           
    if (touch.state == ENDED) then   
-- Food 4 detection with plate
if( foodPosition4.x - foodSize4.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition4.x + foodSize4.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition4.y - foodSize4.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition4.y + foodSize4.y/2 > platePosition.y-65)then

if myFood4  == "Dropbox:Food-Strawberry" or myFood4  == "Dropbox:Food-Cucumber" or myFood4  == "Dropbox:Food-Ham" or myFood4  == "Dropbox:Food-Cheese" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
    end
if myFood4  == "Dropbox:Food-Cookie" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",  5)
end 
    end      
                        
foodSelector4 = math.random(1,5) 
moveFood4 = true   
foodPosition4.x = -750
foodPosition4.y = 600                
    else      
moveFood4 = true
foodPosition4.y = 600
end
    end
 
       
if (touch.state == ENDED) then
-- Food 5 detection with plate
if( foodPosition5.x - foodSize5.x/2) < platePosition.x + plateSize.x/2-10 and
(foodPosition5.x + foodSize5.x/2) > platePosition.x - plateSize.x/2+20 and
(foodPosition5.y - foodSize5.y/2) < platePosition.y + plateSize.y/2-10 and
(foodPosition5.y + foodSize5.y/2 > platePosition.y-65)then
if myFood5  == "Dropbox:Food-Pumpkin" or myFood5  == "Dropbox:Food-Eggplant" or myFood5  == "Dropbox:Food-Steak" or myFood5  == "Dropbox:Food-Milk" then
    score = score + 10
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
   end
            
if myFood5  == "Dropbox:Food-Cupcake" then
    lives = lives - 1
if soundEffects == true then
sound("A Hero's Quest:Drop",  5)
end 
    end 

foodSelector5 = math.random(1,5) 
moveFood5 = true   
foodPosition5.x = -750
foodPosition5.y = 600
    else
moveFood5 = true
foodPosition5.y = 600            
end
    end
    
-- Food detection with each other to make sure the user can't pick two or more different types of food at the same time and get things wrong.
    
-- Food 1 and 2 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition2.x - foodSize2.x/2) < foodPosition.x + foodSize.x/2 and
(foodPosition2.x + foodSize2.x/2) > foodPosition.x - foodSize.x/2 and
(foodPosition2.y - foodSize2.y/2) < foodPosition.y + foodSize.y/2 and
(foodPosition2.y + foodSize2.y/2 > foodPosition.y )then
if foodPosition2.x > foodPosition.x or foodPosition2.x == foodPosition.x  then
foodPosition.x = foodPosition.x - 65
foodPosition2.x = foodPosition2.x + 65
end
if foodPosition2.x < foodPosition.x then
foodPosition.x = foodPosition.x + 65
foodPosition2.x = foodPosition2.x - 65
end

    end 
        end 
                
-- Food 1 and 3 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition.x - foodSize.x/2) < foodPosition3.x + foodSize3.x/2 and
(foodPosition.x + foodSize.x/2) > foodPosition3.x - foodSize3.x/2 and
(foodPosition.y - foodSize.y/2) < foodPosition3.y + foodSize3.y/2 and
(foodPosition.y + foodSize.y/2 > foodPosition3.y )then
if foodPosition3.x > foodPosition.x or foodPosition3.x == foodPosition.x then
foodPosition.x = foodPosition.x - 65
foodPosition3.x = foodPosition3.x + 65
end
if foodPosition3.x < foodPosition.x then
foodPosition.x = foodPosition.x + 65
foodPosition3.x = foodPosition3.x - 65
end
    end
        end  
    
-- Food 1 and 4 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition4.x - foodSize4.x/2) < foodPosition.x + foodSize.x/2 and
(foodPosition4.x + foodSize4.x/2) > foodPosition.x - foodSize.x/2 and
(foodPosition4.y - foodSize4.y/2) < foodPosition.y + foodSize.y/2 and
(foodPosition4.y + foodSize4.y/2 > foodPosition.y )then
if foodPosition4.x > foodPosition.x or foodPosition4.x == foodPosition.x then
foodPosition.x = foodPosition.x - 65
foodPosition4.x = foodPosition4.x + 65
end
if foodPosition4.x < foodPosition.x then
foodPosition.x = foodPosition.x + 65
foodPosition4.x = foodPosition4.x - 65
end
    end  
        end
    
-- Food 1 and 5 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition.x - foodSize.x/2) < foodPosition5.x + foodSize5.x/2 and
(foodPosition.x + foodSize.x/2) > foodPosition5.x - foodSize5.x/2 and
(foodPosition.y - foodSize.y/2) < foodPosition5.y + foodSize5.y/2 and
(foodPosition.y + foodSize.y/2 > foodPosition5.y )then
if foodPosition5.x > foodPosition.x or foodPosition5.x == foodPosition.x  then
foodPosition.x = foodPosition.x - 65
foodPosition5.x = foodPosition5.x + 65
end
if foodPosition5.x < foodPosition.x then
foodPosition.x = foodPosition.x + 65
foodPosition5.x = foodPosition5.x - 65
end
    end
        end
    
-- Food 2 and 3 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition3.x - foodSize3.x/2) < foodPosition2.x + foodSize2.x/2 and
(foodPosition3.x + foodSize3.x/2) > foodPosition2.x - foodSize2.x/2 and
(foodPosition3.y - foodSize3.y/2) < foodPosition2.y + foodSize2.y/2 and
(foodPosition3.y + foodSize3.y/2 > foodPosition2.y )then
if foodPosition3.x > foodPosition2.x or foodPosition3.x == foodPosition2.x  then
foodPosition2.x = foodPosition2.x - 65
foodPosition3.x = foodPosition3.x + 65
end
if foodPosition3.x < foodPosition2.x then
foodPosition2.x = foodPosition2.x + 65
foodPosition3.x = foodPosition3.x - 65
end
    end 
        end 
    
-- Food 2 and 4 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition4.x - foodSize4.x/2) < foodPosition2.x + foodSize2.x/2 and
(foodPosition4.x + foodSize4.x/2) > foodPosition2.x - foodSize2.x/2 and
(foodPosition4.y - foodSize4.y/2) < foodPosition2.y + foodSize2.y/2 and
(foodPosition4.y + foodSize4.y/2 > foodPosition2.y )then
if foodPosition4.x > foodPosition2.x or foodPosition4.x == foodPosition2.x then
foodPosition2.x = foodPosition2.x - 65
foodPosition4.x = foodPosition4.x + 65
end
if foodPosition4.x < foodPosition2.x then
foodPosition2.x = foodPosition2.x + 65
foodPosition4.x = foodPosition4.x - 65
end
    end 
        end     
    
-- Food 2 and 5 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition5.x - foodSize5.x/2) < foodPosition2.x + foodSize2.x/2 and
(foodPosition5.x + foodSize5.x/2) > foodPosition2.x - foodSize2.x/2 and
(foodPosition5.y - foodSize5.y/2) < foodPosition2.y + foodSize2.y/2 and
(foodPosition5.y + foodSize5.y/2 > foodPosition2.y )then
if foodPosition5.x > foodPosition2.x or foodPosition5.x == foodPosition2.x then
foodPosition2.x = foodPosition2.x - 65
foodPosition5.x = foodPosition5.x + 65
end
if foodPosition5.x < foodPosition2.x then
foodPosition2.x = foodPosition2.x + 65
foodPosition5.x = foodPosition5.x - 65
end
    end
        end
    
-- Food 3 and 4 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition4.x - foodSize4.x/2) < foodPosition3.x + foodSize3.x/2 and
(foodPosition4.x + foodSize5.x/2) > foodPosition3.x - foodSize3.x/2 and
(foodPosition4.y - foodSize4.y/2) < foodPosition3.y + foodSize3.y/2 and
(foodPosition4.y + foodSize4.y/2 > foodPosition3.y )then
if foodPosition4.x > foodPosition3.x or foodPosition4.x == foodPosition3.x then
foodPosition3.x = foodPosition3.x - 65
foodPosition4.x = foodPosition4.x + 65
end
if foodPosition4.x < foodPosition3.x then
foodPosition3.x = foodPosition3.x - 65
foodPosition4.x = foodPosition4.x + 65
end
    end
        end
    
-- Food 3 and 5 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition5.x - foodSize5.x/2) < foodPosition3.x + foodSize3.x/2 and
(foodPosition5.x + foodSize5.x/2) > foodPosition3.x - foodSize3.x/2 and
(foodPosition5.y - foodSize5.y/2) < foodPosition3.y + foodSize3.y/2 and
(foodPosition5.y + foodSize5.y/2 > foodPosition3.y )then
if foodPosition5.x > foodPosition3.x or foodPosition5.x == foodPosition3.x then 
foodPosition3.x = foodPosition3.x - 65
foodPosition5.x = foodPosition5.x + 65
end
if foodPosition5.x < foodPosition3.x then
foodPosition3.x = foodPosition3.x + 65
foodPosition5.x = foodPosition5.x - 65
end
    end
        end
    
-- Food 4 and 5 detection with each other
if touch.state == ENDED or touch.state == MOVING then
if( foodPosition5.x - foodSize5.x/2) < foodPosition4.x + foodSize4.x/2 and
(foodPosition5.x + foodSize5.x/2) > foodPosition4.x - foodSize4.x/2 and
(foodPosition5.y - foodSize5.y/2) < foodPosition4.y + foodSize4.y/2 and
(foodPosition5.y + foodSize5.y/2 > foodPosition4.y )then
if foodPosition5.x > foodPosition4.x or foodPosition5.x == foodPosition4.x then 
foodPosition4.x = foodPosition4.x - 65
foodPosition5.x = foodPosition5.x + 65
end
if foodPosition5.x < foodPosition4.x then
foodPosition4.x = foodPosition4.x + 65
foodPosition5.x = foodPosition5.x - 65
end
   end
       end
           end



























--# GameWin
-- Made by: Patrick
GameWin = class()

local nextButton
local backButton

function GameWin:init(x)
    supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
nextButton = Button("Dropbox:Next Icon",vec2(WIDTH/2+350,150))  
backButton = Button("Dropbox:Home Icon", vec2(WIDTH/2-350, 150))      
end

function GameWin:draw()
-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
    
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)
fill(255, 0, 0, 255)         
end
    
backButton: draw()
nextButton: draw()
  
-- Level Setup
strokeWidth(5)
fontSize(100)
font("Copperplate")  
-- Text    
text("You win!",WIDTH/2,700)  
fontSize(60)
if moreCoins > 0 then
text("You earned "..winningScore.."+"..moreCoins.." coins!",WIDTH/2,550)    
else
text("You earned "..winningScore.." coins!",WIDTH/2,550)    
end
    
if lockLevels == levelSetup  then    
text("You unlocked level "..levelSetup.."!",WIDTH/2,490)     
end
    
    
-- Minigames
if lockLevels == 16 then
text("You unlocked Foodfall!",WIDTH/2,430)     
end        
   
if lockLevels == 25 then
text("You unlocked Endless!",WIDTH/2,490)     
--levelSetup = 22
end    

-- Coins
sprite("Dropbox:Coins",WIDTH/2-100,140)
text(coins,WIDTH/2-100,50)   
    
fontSize(65)   
text("Next", WIDTH/2+150,HEIGHT/2 - 200)  
text("level", WIDTH/2+150,HEIGHT/2 - 265)  



if giveCoins == true then    
levelSetup = levelSetup + 1

if lockLevels == 21 then
lockLevels = 25
end        
coins = coins + winningScore + moreCoins
saveLocalData("coins",coins)
if soundEffects == true then
sound("A Hero's Quest:Level Up")
end
giveCoins = false
end
    end

function GameWin:touched(touch)
    
nextButton:touched(touch)
if nextButton.selected == true then
levelOn = true   
    if levelSetup == 2 then 
        lives = 3
        Scene.Change("Game")
    end
    if levelSetup == 3 then 
        lives = 4
        Scene.Change("Game")
    end    
    if levelSetup == 4 then 
        lives = 5
        Scene.Change("Game")
    end    
    if levelSetup == 5 then 
        lives = 5
        Scene.Change("Game")
    end    
    if levelSetup == 6 then 
        lives = 6
        Scene.Change("Game")
    end    
    if levelSetup == 7 then 
        lives = 6
        Scene.Change("Game")
    end    
    if levelSetup == 8 then 
        lives = 7
        Scene.Change("Game")
    end    
    if levelSetup == 9 then 
        lives = 7
        Scene.Change("Game")
    end  
    if levelSetup == 10 then 
        lives = 8
        Scene.Change("Game")
    end 
    if levelSetup == 11 then 
        lives = 8
        Scene.Change("Game")
    end      
    if levelSetup == 12 then 
        lives = 9
        Scene.Change("Game")
    end
    if levelSetup == 13 then 
        lives = 9 
        Scene.Change("Game")
    end    
    if levelSetup == 14 then 
        lives = 10
        Scene.Change("Game")
    end    
    if levelSetup == 15 then 
        lives = 10
        Scene.Change("Game")
    end    
    if levelSetup == 16 then 
        lives = 11
        Scene.Change("Game")
    end    
    if levelSetup == 17 then 
        lives = 12
        Scene.Change("Game")
    end    
    if levelSetup == 18 then 
        lives = 13
        Scene.Change("Game")
    end    
    if levelSetup == 19 then 
        lives = 14
        Scene.Change("Game")
    end   
    if levelSetup == 20 then 
        lives = 15
        Scene.Change("Game")
    end
        
    if lockLevels  == 25 then 
        Scene.Change("Setup") 
        lockLevels = 30
        levelSetup = 0
        saveLocalData("levels",lockLevels)
    end                  
end
    
backButton:touched(touch)
if backButton.selected == true then
    Scene.Change("Setup")
    levelSetup = 0
if lockLevels == 25 then         
    lockLevels = 30
    saveLocalData("levels",lockLevels)
    end
end
    end


































--# GameOver
-- Made by: Patrick
GameOver = class()

local retryButton
local backButton

function GameOver:init(x)
    supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
retryButton = Button("Dropbox:Retry Icon",vec2(WIDTH/2+350,150))  
backButton = Button("Dropbox:Home Icon", vec2(WIDTH/2-350, 150))  
end

function GameOver:draw()
-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end    
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)
fill(255, 0, 0, 255)         
end
-- Buttons    
backButton: draw()
retryButton:draw()

      
-- Level Setup
strokeWidth(5)
fontSize(100)
font("Copperplate")  
-- fill(255, 155, 0, 255)
-- Text    
text("Game Over!",WIDTH/2,700)  
fontSize(60)
text("You lost all your lives!",WIDTH/2,550)        
text("You didn't earn any coins!",WIDTH/2,490)     

-- Coins
sprite("Dropbox:Coins",WIDTH/2-100,140)
text(coins,WIDTH/2-100,50)   


fontSize(65)   
text("Retry", WIDTH/2+140,HEIGHT/2 - 200)  
text("Level", WIDTH/2+140,HEIGHT/2 - 265)  

    
if gameOver == true then  
if soundEffects == true then
sound("A Hero's Quest:Curse")
end
gameOver = false
end
    end

function GameOver:touched(touch)
    
retryButton:touched(touch)
if retryButton.selected == true then
levelOn = true 
    levelSetup = levelSetup 
    Scene.Change("Game") 
    if levelSetup == 1 then 
        lives = 3
    end
    if levelSetup == 2 then 
        lives = 3 
    end
    if levelSetup == 3 then 
        lives = 4
    end    
    if levelSetup == 4 then 
        lives = 5
    end    
    if levelSetup == 5 then 
        lives = 5
    end
    if levelSetup == 6 then 
        lives = 6
    end    
    if levelSetup == 7 then 
        lives = 6
    end    
    if levelSetup == 8 then 
        lives = 7 
    end    
    if levelSetup == 9 then 
        lives = 7
    end  
    if levelSetup == 10 then 
        lives = 8
    end 
    if levelSetup == 11 then 
        lives = 8
    end      
      if levelSetup == 12 then 
        lives = 9
    end
    if levelSetup == 13 then 
        lives = 10
    end    
    if levelSetup == 14 then 
        lives = 11
    end    
    if levelSetup == 15 then 
        lives = 11
    end    
    if levelSetup == 16 then 
        lives = 12
    end    
    if levelSetup == 17 then 
        lives = 14 
    end    
    if levelSetup == 18 then 
        lives = 16
    end    
    if levelSetup == 19 then 
        lives = 18
    end   
    if levelSetup == 20 then 
        lives = 20
    end   
end
    
backButton:touched(touch)
    if backButton.selected == true then
        Scene.Change("Setup") 
        levelSetup = 0
        end
    end



































--# EndlessOver
-- Made by: Patrick
EndlessOver = class()
local backButton
local retryButton

function EndlessOver:init(x)
    supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
retryButton = Button("Dropbox:Retry Icon",vec2(WIDTH/2+350,150))  
backButton = Button("Dropbox:Home Icon", vec2(WIDTH/2-350, 150))  
end

function EndlessOver:draw()
-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)
fill(255, 0, 0, 255)         
end
    
-- Buttons    
backButton: draw()
retryButton:draw()
      
-- Level Setup
strokeWidth(5)
fill(255, 0, 0, 255)    
font("Copperplate")  

fontSize(60)
text("Score: "..endlessScore, WIDTH/2, 550)  
text ("Highscore: "..saveScore, WIDTH/2, 490)

fontSize(100)    
text("Game Over!",WIDTH/2,700)  
-- Coins
fontSize(60)
sprite("Dropbox:Coins",WIDTH/2-100,140)
text(coins,WIDTH/2-100,50)   

fontSize(65)   
text("Retry", WIDTH/2+140,HEIGHT/2 - 200)  
text("Game", WIDTH/2+140,HEIGHT/2 - 265)  
    
if endlessScore == 0 then
text("You didn't earn any coins!",WIDTH/2,430)    
else
text("You earned "..endlessScore.." coins!",WIDTH/2,430)    
end
    
if newScore == true then    
if score > saveScore then
saveScore = score
saveLocalData("score",saveScore)
score = 0
foodOn = false
newScore = false
else
score = 0
foodOn = false
newScore = false
end
    end
  
        
    
if giveCoins == true then 
coins = coins + endlessScore
if soundEffects == true then
sound("A Hero's Quest:Curse")
end
saveLocalData("coins",coins)
giveCoins = false
end
    end
        

function EndlessOver:touched(touch)
backButton:touched(touch)
if backButton.selected == true then
Scene.Change("Setup")
end
            
retryButton:touched(touch)
if retryButton.selected == true then
Scene.Change("Game")     
buttonDraw = 1
foodOn = true
gameOn = true 
lives = 10+endlessLives  
    end
end



























--# FoodFall
Foodfall = class()
-- Made by: Nick

-- Plate and Heart
local miniPlate
local miniPlatePos= vec2()
local heartSize = vec2(spriteSize("Dropbox:Sprite-Heart"))
local heart

-- Random Food Generator
badSprite =  math.random(1,7)
goodSprite =  math.random(1,17)

-- Bad/Good food
local goodFood
local badFood

local badSprite
local goodSprite
local mySize
local badSize

local goodFoodPos = vec2()
local badFoodPos= vec2()
local heartPos = vec2()
local droppos = vec2()

-- Timer
local timer = 0

-- Buttons
local backButton
local pauseButton
local startButton
local homeButton

local miniStartButton
local howToButton 
local foodInfo

local foodDrop = 5
local speed = 0

-- Switches
local switch = 0
local switch1 = 0
local switch2 = false
local switch6 = true
local switch5 = true
local switch3 = false
local switch4 = false
local pauseMenu = false
 startAll = true

-- Score
miniScore = 0
fallScore = 0


function Foodfall:init()
    supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- Button
homeButton = Button("Dropbox:Home Icon", vec2(WIDTH/2+200, HEIGHT/2))
pauseButton = Button("Dropbox:Pause Icon", vec2(WIDTH/2+430, HEIGHT/2+310))
startButton = Button("Dropbox:Play Icon", vec2(WIDTH/2 - 200,HEIGHT/2))
    
miniStartButton = Button("Dropbox:Play Icon", vec2(WIDTH/2,HEIGHT/2))
howToButton = Button("Dropbox:Help Icon", vec2(WIDTH/2+410, 100))   
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))     
foodInfo = Button("Dropbox:Food Info Icon", vec2(WIDTH/2-410, 100))        

-- Sprite position
badFoodPos = vec2(math.random(0,WIDTH-50),HEIGHT+70)
goodFoodPos = vec2(math.random(0,WIDTH-50),HEIGHT+70)
miniPlatePos = vec2(CurrentTouch.x, HEIGHT/2-100)
heartPos = vec2(math.random(0,WIDTH-50),HEIGHT)
droppos = vec2()
droppos.x = goodFoodPos.x
end


function Foodfall:draw()
-- Choosing Background 
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end    
       
if startAll == true then
strokeWidth(5)
fill(255, 55, 0, 255)
fontSize(50)
font("Copperplate")  
text("Minigame - Foodfall",WIDTH/2,725)  
text("How", WIDTH/2+275,140)
text("to", WIDTH/2+275,100)
text("play", WIDTH/2+279,60)

-- Coins
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2,130)
text(coins,WIDTH/2,40)    
        
miniStartButton:draw()
howToButton:draw()
backButton:draw()
foodInfo:draw()
end
    
if startAll == false then
if pauseMenu == false then

 -- Text Setup
strokeWidth(5)
fill(255, 55, 0, 255)
fontSize(50)
font("Copperplate")
text("Minigame - Foodfall",WIDTH/2,725)
-- Pause
pauseButton:draw()
       
-- RANDOMIZE JUNKFOOD
   if switch5 == true then
   badSprite =  math.random(1,7)

          if badSprite == 1 then
         badSprite = "Dropbox:Food-Hotdog"
     end
             if badSprite == 2 then
         badSprite = "Dropbox:Food-Hamburger"
     end
             if badSprite == 3 then
         badSprite = "Dropbox:Food-Cake"
     end
             if badSprite == 4 then
         badSprite = "Dropbox:Food-Cookie"
     end
             if badSprite == 5 then
         badSprite = "Dropbox:Food-Cupcake"
     end
             if badSprite == 6 then
         badSprite = "Dropbox:Food-Donuts"
     end
                     if badSprite == 7 then
         badSprite = "Dropbox:Food-Fries"
     end

switch5 = false
badSize = vec2(spriteSize(badSprite))
end

-- RANDOMIZE HEALTHY FOOD
if switch6 == true then
goodSprite =  math.random(1,17)

            if goodSprite == 1 then
         goodSprite = "Dropbox:Food-Apple"
     end
             if goodSprite == 2 then
         goodSprite = "Dropbox:Food-Banana"
     end
             if goodSprite == 3 then
         goodSprite = "Dropbox:Food-Bread"
     end
             if goodSprite == 4 then
         goodSprite = "Dropbox:Food-Broccoli"
     end
             if goodSprite == 5 then
         goodSprite = "Dropbox:Food-Carrot"
     end
             if goodSprite == 6 then
         goodSprite = "Dropbox:Food-Corn"
     end
             if goodSprite == 7 then
         goodSprite = "Dropbox:Food-Cucumber"
     end
             if goodSprite == 8 then
         goodSprite = "Dropbox:Food-Egg"
     end
             if goodSprite == 9 then
         goodSprite = "Dropbox:Food-Eggplant"
     end
             if goodSprite == 10 then
         goodSprite = "Dropbox:Food-Grapes"
     end
             if goodSprite == 11 then
         goodSprite = "Dropbox:Food-Ham"
     end
             if goodSprite == 12 then
         goodSprite = "Dropbox:Food-Milk"
     end
             if goodSprite == 13 then
         goodSprite = "Dropbox:Food-Muffin"
     end
             if goodSprite == 14 then
         goodSprite = "Dropbox:Food-Pumpkin"
     end
             if goodSprite == 15 then
         goodSprite = "Dropbox:Food-Potato"
     end
             if goodSprite == 16 then
         goodSprite = "Dropbox:Food-Steak"
     end
             if goodSprite == 17 then
         goodSprite = "Dropbox:Food-Strawberry"
     end

switch6 = false
mySize = vec2(spriteSize(goodSprite))
end

        
 -- INCREASE THE SPEED OF FOOD EVERY 10 PTS
if speed == 10 and foodDrop < 15 then
speed = 0
foodDrop = foodDrop+1
end


-- DELAY BADFOOD STARTING
if timer == 65 then
switch3 = true
end

-- VARIABLE TIMER
timer = timer + 1   
        
-- HEART AND LUNCHBAG POSITION
if (CurrentTouch.y > 100) and (CurrentTouch.y < 350) then
miniPlatePos.x = CurrentTouch.x
end
        
-- LUNCHBAG/HEART POSITION
miniPlatePos = vec2(miniPlatePos.x, HEIGHT/2-180)
miniPlate = SpriteObject("Dropbox:Sprite-Lunchbag",vec2(miniPlatePos.x,miniPlatePos.y))
heart = SpriteObject("Dropbox:Sprite-Heart",vec2(heartPos.x,heartPos.y))


-- ASSIGN CREATED FOOD ITS POSITIONS
goodFood = SpriteObject(goodSprite,vec2(goodFoodPos.x,goodFoodPos.y))
badFood = SpriteObject(badSprite,vec2(badFoodPos.x,badFoodPos.y))

badFood:draw()
goodFood:draw()

-- Plate
miniPlate:draw()


-- ONCE BADFOOD IS DRAWN MOVE RED DROPPER OVER IT
if timer == 66 then
droppos.x = badFoodPos.x
end

goodFoodPos.y = goodFoodPos.y - foodDrop

 -- BRINGS FOOD BACK TO TOP
 if switch == 1 then
 goodFoodPos.x = math.random(0,WIDTH-50)
            
  -- GENERATES FOOD IN POSITION WHERE IT WONT OVERLAP
   while goodFoodPos.x < badFoodPos.x + 150 and
      goodFoodPos.x > badFoodPos.x - 150 do
      goodFoodPos.x = math.random(0,WIDTH-50)
      end

     droppos.x = goodFoodPos.x
     switch=0
     goodFoodPos.y = HEIGHT
     switch6 = true
 end


   -- BRINGS JUNK FOOD BACK TO TOP
 if switch1== 1 then
                          badFoodPos.x = math.random(0,WIDTH-50)
     droppos.x = badFoodPos.x

        -- GENERATES FOOD IN POSITION WHERE IT WONT OVERLAP
 while badFoodPos.x < goodFoodPos.x + 100 and
       badFoodPos.x > goodFoodPos.x - 100 do

       badFoodPos.x = math.random(0,WIDTH-50)

     end
     switch1=0
     badFoodPos.y = HEIGHT
     switch5 = true
 end


 -- DRAW HEART
 if switch2 == true then

     -- BRING HEART BACK TO TOP ONCE EXITING SCREEN
     if heartPos.y > -20 then
         heart:draw()
         heartPos.y = heartPos.y - 10

     else
     switch2 = false
         heartPos.y = HEIGHT+20
         end
 end


     -- ONCE 65 FRAMES PASSES, THIS WILL ALLOW FOOD TO START FALLING
     if switch3==true then
 badFoodPos.y= badFoodPos.y - foodDrop
     end

 -- BRING HEART TO TOP
     if switch4==true then
     heartPos.y = HEIGHT + 700
 end

 -- EVERY 900 FRAMES DRAW HEART
 if timer%900==0 then
     switch2=true
 end

 -- IF GOOD FOOD FALLS OFF SCREEN
 if goodFoodPos.y < -50 then
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
      switch=1
     miniLives=miniLives-1
 end
            
 -- IF GOOD FOOD FALLS OFF SCREEN
 if badFoodPos.y < -50 then
if soundEffects == true then
sound("A Hero's Quest:Pick Up", 5)
end
    end

 -- RESETS JUNK FOOD POSITION ONCE IT FALLS OF SCREEN
 if badFoodPos.y < -50 then
  switch1=1
     end

 -- WHEN LUNCHBAG TOUCHES JUNK FOOD
if(badFoodPos.x - badSize.x/2) < miniPlatePos.x + 89/2 and
(badFoodPos.x + badSize.x/2) > miniPlatePos.x - 89/2 and
(badFoodPos.y - badSize.y/2) < miniPlatePos.y + 119/2 and
(badFoodPos.y + badFoodPos.y/2 > miniPlatePos.y+50 )then
if soundEffects == true then
sound("A Hero's Quest:Drop",5)
end
 switch1=1
 miniLives=miniLives-1
end

 -- WHEN LUNCH BAG TOUCHES HEART
if(heartPos.x - 128/2) < miniPlatePos.x + 89/2 and
(heartPos.x + 128/2) > miniPlatePos.x - 89/2 and
(heartPos.y - 128/2) < miniPlatePos.y + 119/2 and
(heartPos.y + 128/2 > miniPlatePos.y - 119/2 )then
     miniLives=miniLives+1
if soundEffects == true then
sound("A Hero's Quest:Defensive Cast 1")
end
     switch2 = false
     heartPos.y = HEIGHT+20
 end

 -- WHEN HEALTHY FOOD TOUCHES LUNCH BAG
if(goodFoodPos.x - mySize.x/2) < miniPlatePos.x + 89/2 and
(goodFoodPos.x + mySize.x/2) > miniPlatePos.x - 89/2 and
(goodFoodPos.y - mySize.y/2) < miniPlatePos.y + 119/2 and
(goodFoodPos.y + mySize.y/2 > miniPlatePos.y )then
if soundEffects == true then
sound("A Hero's Quest:Eat 1", 5)
end
 switch=1
     miniScore = miniScore + 10
     speed=speed+1
 end

 if miniLives == 0 then
 Scene.Change("end")
 giveCoins = true
 foodDrop = 5
 fallScore = miniScore
 startAll = true
 end
 
 -- DRAW SCORE
 text("Score: ".. miniScore,600,90)
 text("Highscore: ".. miniHighscore,600,40)
 -- Saving New Highscore
if miniScore > miniHighscore then
miniHighscore = miniScore
saveLocalData("high",miniHighscore)
end 
                           
 -- LIVES COUNTER
 fontSize(60)
  if miniLives >= 10 then
 text("x"..miniLives,175,35)
 sprite("Dropbox:Sprite-Heart",75,50)       
 else
 text("x"..miniLives,150,35)
 sprite("Dropbox:Sprite-Heart",75,50)         
 end       
-- if the pause menu is activated
else
startButton:draw()
homeButton:draw()
        
-- Text Setup
strokeWidth(5)
fill(255, 55, 0, 255)
fontSize(50)
font("Copperplate")
text("Minigame - Food Fall",WIDTH/2,725)
end
   end
       end

function Foodfall:touched(touch)
backButton:touched(touch)
pauseButton:touched(touch)
startButton:touched(touch)

if pauseMenu == true then
    homeButton:touched(touch)
   if homeButton.selected == true then
   Scene.Change("Setup")
   pauseMenu = false
   miniScore = 0
   foodDrop = 5
   startAll = true
   end
end

if pauseButton.selected == true then
pauseMenu = true
end

if startButton.selected == true then
pauseMenu = false
    end
    
if startAll == true then
miniStartButton:touched(touch)
howToButton:touched(touch)
backButton:touched(touch)
        
-- Food Info
foodInfo:touched(touch)
    if foodInfo.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pillar Hit")
end
        foodPrevious = 3
        Scene.Change("Food")
        end    
-- Minigame Start
if miniStartButton.selected == true then
       miniLives = 5 + addedLives
       miniScore = 0
       startAll = false
       pauseMenu = false
       end
-- Intructiona
   if howToButton.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pillar Hit")
end
       Scene.Change("Hf")
       end
    
   if backButton.selected == true then
if soundEffects == true then
     sound("Game Sounds One:Pistol")
     end
        Scene.Change("Setup")
        end
    end
end



























--# EndGame
-- Made by: Nick
EndGame = class()
local backButton
local retryButton

function EndGame:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
backButton = Button("Dropbox:Home Icon", vec2(WIDTH/2-350, 150))  
retryButton = Button("Dropbox:Retry Icon",vec2(WIDTH/2+350,150))  
    
local switchend = false    
        if miniScore > miniHighscore then
       miniHighscore = miniScore
       saveLocalData("high",miniHighscore)
       switchend = true
   end
end

function EndGame:draw()

-- Choosing the background
if backgroundSelect == nil then
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
fill(255, 175, 0, 255)    
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768)
fill(255, 0, 0, 255)    
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)
fill(255, 0, 0, 255)         
end
    
-- Buttons    
backButton: draw()
retryButton:draw()
    
-- Level Setup
strokeWidth(5)
fontSize(100)
font("Copperplate")  

-- Text    
text("Game Over!",WIDTH/2,700)  
fontSize(60)
text("Score: "..miniScore, WIDTH/2, 550)  
text ("Highscore: "..miniHighscore, WIDTH/2, 490)
    
if miniScore == 0 then 
text("You didn't earn any coins!",WIDTH/2,430)    
else
text("You earned "..miniScore.." coins! ", WIDTH/2, 430)    
end


-- Coins
sprite("Dropbox:Coins",WIDTH/2-100,140)
text(coins,WIDTH/2-100,50)   

fontSize(65)   
text("Retry", WIDTH/2+140,HEIGHT/2 - 200)  
text("Game", WIDTH/2+140,HEIGHT/2 - 265)  
        
if giveCoins == true then    
if soundEffects == true then
sound("A Hero's Quest:Curse")
end
coins = coins + fallScore
saveLocalData("coins",coins)
giveCoins = false
end
    end


function EndGame:touched(touch)
backButton:touched(touch)
if backButton.selected == true then
Scene.Change("Setup")
foodDrop = 5    
miniLives = 5 + addedLives 
miniScore = 0
end
    
retryButton:touched(touch)
if retryButton.selected == true then
Scene.Change("Foodfall")  
foodDrop = 5    
miniLives = 5 + addedLives 
miniScore = 0
    end
end


























--# HowToEndless
HowToEndless = class()

local health 
local healthY = HEIGHT/2-100
local healthX = -600
local frame = 0
local junk
local junky= HEIGHT/2-100
local junkx = -1000

function HowToEndless:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))     
end

function HowToEndless:draw()
   health = SpriteObject("Dropbox:Food-Broccoli",vec2(healthX,healthY))
   junk = SpriteObject("Dropbox:Food-Cake",vec2(junkx,junky))
     frame = frame + 1
   spriteMode(CORNER)
   sprite("SpaceCute:Background",0,0,WIDTH,HEIGHT)
   spriteMode(CENTER)
   fill(255, 20, 0, 255) 
   
font("Copperplate")
fontSize(75)
    
-- Text
text("Endless",WIDTH/2,725)  
fontSize(60)
text("How to Play",WIDTH/2,675)        


   -- INSTRUCTIONS
   fontSize(50)
   fill(252, 255, 0, 255) 
   text("Drag the healthy food to your plate ",WIDTH/2,HEIGHT/2+180)
   text("before it goes off the screen!",WIDTH/2,HEIGHT/2+130) 
   fontSize(50)
   fill(0, 6, 255, 255)
   text("But watch out!", WIDTH/2,HEIGHT/2+75)
   text("Avoid grabbing the junk food!", WIDTH/2,HEIGHT/2+35)
   fill(76, 255, 0, 255)
   text("How long can you last?",WIDTH/2-10,HEIGHT/2-20)

   -- ON SCREEN SPRTITES
   sprite("Dropbox:Plate",800,125)
  -- sprite("Dropbox:Food-Broccoli",WIDTH/2-300,280)
  -- sprite("Dropbox:Food-Cake",WIDTH/2+300,280)
   sprite("Dropbox:Plate",400,125)
backButton:draw()
health:draw()
junk:draw()

         if healthX < 800 then
       healthX = healthX + 5
       end
       
       if healthX == 800 then
       healthY = healthY - 5
       end
       
       if healthY <= 150 then
       healthY = healthY + 5
       end
    
    
         if junkx < 400 then
       junkx = junkx + 5
       end
       
       if junkx == 400 then
       junky = junky - 5
       end
       
       if junky <= 150 then
       junky = junky + 5
       end
    

   if frame%500 == 0 then 
       healthY = HEIGHT/2-100
       healthX = -600
       junky= HEIGHT/2-100
       junkx = -1000
    end
    
sprite("Dropbox:Sprite-Check",800,160, 1536/9,2048/9)
sprite("Dropbox:Sprite-X",400,160,1536/9,2049/9)
end

function HowToEndless:touched(touch)
backButton:touched(touch)

-- BACK TO MENU
   if backButton.selected == true then
       Scene.Change("Game")
       foodOn = true
   end

end



























--# HowToFoodfall
-- Made by: Nick
HowToFoodfall = class()

local backButton
local health 
local healthY = HEIGHT + 20
local frame = 0
local junk
local junky= HEIGHT+20
local lunchbagX = WIDTH/2-300
local lunchbagX2 = WIDTH/2+300

local switch = true
local goodSprite
local badSprite
local heartY = 250
local switch2

function HowToFoodfall:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2 - 410, 675))
end

function HowToFoodfall:draw()
   frame = frame + 1
   background(0, 87, 255, 255)
   spriteMode(CORNER)
   sprite("SpaceCute:Background",0,0,WIDTH,HEIGHT)
   spriteMode(CENTER)
     fill(255, 20, 0, 255) 
   
font("Copperplate")
fontSize(75)
    
-- Text
text("Foodfall",WIDTH/2,725)  
fontSize(60)
text("How to Play",WIDTH/2,675)        


   -- INSTRUCTIONS
   fontSize(50)
   fill(252, 255, 0, 255) 
   text("Move your lunchbag to catch the",WIDTH/2,HEIGHT/2+180)
   text("healthy food for your lunch!!",WIDTH/2,HEIGHT/2+130) 
   fontSize(50)
   fill(0, 6, 255, 255)
   text("But watch out!", WIDTH/2,HEIGHT/2+75)
   text("Avoid catching the junk food!", WIDTH/2,HEIGHT/2+35)
   fill(76, 255, 0, 255)
   text("Catch hearts for extra lives!",WIDTH/2-10,HEIGHT/2-20)
   text("How long can you last?",WIDTH/2-10,HEIGHT/2-69)


   health = SpriteObject("Dropbox:Food-Corn",vec2(WIDTH/2-300,healthY))
   junk = SpriteObject("Dropbox:Food-Cupcake",vec2(WIDTH/2+300,junky))


backButton:draw()
junk:draw()

         if healthY > 170 then
       health:draw()
       healthY = healthY - 5
       end

           junky = junky - 5

   if frame == 300 then 
       healthY = HEIGHT+20    
       junky = HEIGHT +20
       switch = true
       frame = 0

   end


   -- ON SCREEN SPRTITES
   sprite("Dropbox:Sprite-Lunchbag",lunchbagX,120)
   sprite("Dropbox:Sprite-Lunchbag",lunchbagX2,120)
--   sprite("Dropbox:Sprite-Check",WIDTH/2-300,160, 1536/9,2048/9)
  -- sprite("Dropbox:Sprite-Check",WIDTH/2+300,160,1536/9,2049/9)
   sprite("Dropbox:Sprite-Heart",WIDTH/2,heartY,90,90)
   sprite("Dropbox:Sprite-Lunchbag",WIDTH/2,120)

       -- Moving lunchbag on the left
       if frame < 60 then
           lunchbagX = lunchbagX + 3
           end
       if frame >60 and frame < 80 then
       lunchbagX = lunchbagX -20
           end
       if frame > 80 and lunchbagX < WIDTH/2-300 then
       lunchbagX = lunchbagX +4
           end
-- moving lunchbag on the right

if frame%5 == 0 and frame < 100 then 
       lunchbagX2 = lunchbagX2 -3
   end
if frame%10 == 0 and frame < 100 then 
       lunchbagX2 = lunchbagX2 + 6
   end
if frame > 100 and frame < 150 and lunchbagX2 > WIDTH/2+130 then
       lunchbagX2 = lunchbagX2 -17
   end
if  frame > 150 and lunchbagX2 < WIDTH/2 + 300 then
       lunchbagX2 = lunchbagX2 + 3
   end

   --moving heart
   if frame < 125 then
       heartY = heartY - 0.7
   end
   if frame > 125 and frame < 250 then
       heartY = heartY + 0.7
   end
   end
function HowToFoodfall:touched(touch)
backButton:touched(touch)
-- BACK TO MENU
   if backButton.selected == true then
       Scene.Change("Foodfall")
   end

end



























--# ButtonGuide
-- By Micheal and Nick
ButtonGuide = class()
local button1
local button2
local button3
local button4
local button5
local button6
local button7
local button8
local button9
local button10
local button11
local info = true
local noTouch
local backButton


function ButtonGuide:init()
 supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- Buttons
button1 = Button("Dropbox:Back Icon",vec2(WIDTH/2,HEIGHT/2+50))
button2 = Button("Dropbox:Food Info Icon",vec2(WIDTH/2 -75,HEIGHT/2 + 190))
button3 = Button("Dropbox:Home Icon",vec2(WIDTH/2 + 350,HEIGHT/2 -120))
button4 = Button("Dropbox:Minigame-Endless",vec2(WIDTH/2 - 285,HEIGHT/2 + 50))
button5 = Button("Dropbox:Minigame-Foodfall",vec2(WIDTH/2 + 285,HEIGHT/2 + 50))
button6 = Button("Dropbox:Level",vec2(WIDTH/2,HEIGHT/2 - 100))
button7 = Button("Dropbox:Play Icon",vec2(WIDTH/2 - 350,HEIGHT/2 - 120))
button8 = Button("Dropbox:Settings Icon",vec2(WIDTH/2 - 225,HEIGHT/2 + 190))
button9 = Button("Dropbox:Store Icon",vec2(WIDTH/2 + 75,HEIGHT/2 + 190))
button10 = Button("Dropbox:Bonus Shop",vec2(WIDTH/2 + 225,HEIGHT/2 + 190))
button11 = Button("Dropbox:Shop Icon",vec2(WIDTH/2 + 375,HEIGHT/2 + 190))
noTouch = Button("Dropbox:Background-FoodGroups",vec2(0,0))
backButton = Button("Dropbox:Back Icon", vec2(100,HEIGHT-100))
end

function ButtonGuide:draw()
sprite("SpaceCute:Background",512, 384, 1024, 768)
-- Text Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")  
-- Text    
text("Food Mania",WIDTH/2,725)  
fontSize(60)
text("Button Guide",WIDTH/2,675)  
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2+410,690)
text(coins,WIDTH/2+410,600)   
fontSize(40)  
     

-- Buttons
button1:draw()
button2:draw()
button3:draw()
button4:draw()
button5:draw()
button6:draw()
button7:draw()
button8:draw()
button9:draw()
button10:draw()
backButton:draw()



     -- BUTTON INFORMATION
      if switch == 1 then
      fontSize(60)  
      text("Back button",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you back to the",WIDTH/2,130)
      text("previous scene.",WIDTH/2,95)
      end
    
    
      if switch == 2 then
      fontSize(60)
      text("Food Catalogue",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a detailed  ",WIDTH/2,130)
      text("food catalogue that will show you the ",WIDTH/2,95)
      text("difference between healthy and junk food but ",WIDTH/2,60)
      text("also some interesting facts about the foods.",WIDTH/2,25)
      end

      if switch == 3 then
      fontSize(60)
      text("Home button",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to the home",WIDTH/2,130)
      text("screen of the game.",WIDTH/2,95)
      end

      if switch == 4 then
      fontSize(60)
      text("Endless",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a challenging",WIDTH/2,130)
      text("endless version of level play where you must",WIDTH/2,95)
      text("survive as long as you can. This minigame",WIDTH/2,60)     
      text("is unlocked when you beat level 20.",WIDTH/2,25)       
      end

      if switch == 5 then
      fontSize(60)
      text("Foodfall",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a inverted",WIDTH/2,130)
      text("endless version of level play where food falls",WIDTH/2,95)
      text("and you must survive as long as you can. This",WIDTH/2,60)
      text("minigame is unlocked when you beat level 15.",WIDTH/2,25)       
      end

      if switch == 6 then
      fontSize(60)
      text("Level Play",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a level selection",WIDTH/2,130)
      text("page where you can play and unlock 20 different",WIDTH/2,95)
      text("levels, but the levels get harder each time.",WIDTH/2,60)      
      end

      if switch == 7 then
      fontSize(60)
      text("Start button",WIDTH/2,185)
      fontSize(40)  
      text("This button is the start button for level play  ",WIDTH/2,130)
      text("before you begin the game and for both of the",WIDTH/2,95)
      text("Foodfall/Endless minigames.This is also the ",WIDTH/2,60)   
      text("resume button to resume your paused game.",WIDTH/2,25)           
      end
    
      if switch == 8 then
      fontSize(60)
      text("Settings button",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to the Settings page",WIDTH/2,130)
      text("where you can choose your background, modify",WIDTH/2,95)
      text("the volume of the game music and enable or ",WIDTH/2,60)
      text("disable the sound effects.",WIDTH/2,25)
      end
    
      if switch == 9 then
      fontSize(60)
      text("Avatar Creator",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a customizing page ",WIDTH/2,130)
      text("where you can create your own avatar by buying",WIDTH/2,95)
      text("different costume parts using the coins you ",WIDTH/2,60)
      text("earned from your games.",WIDTH/2,25)
      end
    
      if switch == 10 then
      fontSize(60)
      text("Bonus Store",WIDTH/2,185)
      fontSize(40)  
      text("This button will take you to a store where you",WIDTH/2,130)
      text("can boost your game performance by buying",WIDTH/2,95)
      text("additional lives and boosting your win bonus.",WIDTH/2,60)
      end
    
      if info == true then
      text("This guide will show you the functions of ",WIDTH/2,130)
      text("the major game buttons! Click on a button",WIDTH/2,95)
      text("to learn more about what it does!",WIDTH/2,60)
      switch = 0
      end
  end

    function ButtonGuide:touched(touch)
    button1:touched(touch)
    button2:touched(touch)
    button3:touched(touch)
    button4:touched(touch)
    button5:touched(touch)
    button6:touched(touch)
    button7:touched(touch)
    button8:touched(touch)
    button9:touched(touch)
    button10:touched(touch)
    backButton:touched(touch)
    noTouch:touched(touch)

  if backButton.selected == true then
      Scene.Change("Setup")
if soundEffects == true then
sound("Game Sounds One:Pistol",    5)
end
      info = true
      switch = 0
      end

   -- No touch 
    if noTouch.selected == true then
       info = true
    end

     -- MAKING TEXT SHOW UP WHEN CLICKED
      if button1.selected == true then
      switch = 1
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button2.selected == true then
      switch = 2
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button3.selected == true then
      switch = 3
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button4.selected == true then
      switch = 4
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button5.selected == true then
      switch = 5
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button6.selected == true then
      switch = 6
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end
    
      if button7.selected == true then
      switch = 7
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end
    
      if button8.selected == true then
      switch = 8
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

      if button9.selected == true then
      switch = 9
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end
    
      if button10.selected == true then
      switch = 10
      info = false
  if soundEffects == true then
  sound("A Hero's Quest:Hit 3",5)
  end
      end

  end


























--# FoodInfo
FoodInfo = class()
local healthButton
local junkButton
local backButton

function FoodInfo:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- BUTTONS
healthButton = Button("Dropbox:Healthy",vec2(WIDTH/2,HEIGHT/2-100))
junkButton = Button("Dropbox:Junk",vec2(WIDTH/2,HEIGHT/2+100))
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))         
end

function FoodInfo:draw()
-- Choosing the background
if (backgroundSelect == 1) then        
sprite("Dropbox:Background-Hamburger",512, 384, 1024, 768)
end
if (backgroundSelect == 2) then
sprite("Dropbox:Background-Icecream",512, 384, 1024, 768)
end
if (backgroundSelect == 3) then
sprite("Dropbox:Background-Cake",512, 384, 1024, 768)
end
if (backgroundSelect == 4) then
sprite("Dropbox:Background-Apple",552, 384, 1200, 768)
end
if (backgroundSelect == 5) then
sprite("Dropbox:Background-Orange",512, 384, 1024, 768) 
end
if (backgroundSelect == 6) then
sprite("Dropbox:Background-Pie",512, 384, 1024, 768)   
end

-- Level Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")  
-- Text    
text("Food Mania",WIDTH/2,725)  
fontSize(60)
text("Food Catalogue",WIDTH/2,675)        
fontSize(55)    
sprite("Dropbox:Coins",WIDTH/2+410,690)
text(coins,WIDTH/2+410,600)   
    
   -- BUTTONS
   healthButton:draw()
   junkButton:draw()
   backButton:draw()
   end

function FoodInfo:touched(touch)
healthButton:touched(touch)
junkButton:touched(touch)
backButton:touched(touch)

        if healthButton.selected == true then
        Scene.Change("Healthy")
        end

        if junkButton.selected==true then
        Scene.Change("Junk")
        end
    
        if backButton.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pistol",    5)
end
    if foodPrevious == 1 then
    Scene.Change("Level")
end
    if foodPrevious == 2 then
    Scene.Change("Game")
    if levelSetup < 1 then
    foodOn = true
    end
end
        
    if foodPrevious == 3 then
    Scene.Change("Foodfall")
end
    end
        end


























--# Healthy


Healthy = class()
-- Fruits
local fruit1
local fruit2
local fruit3
local fruit4
local fruit5
local fruit6
local fruit7
local fruit8
-- Dairy
local dairy1
local dairy2
--Grains
local grain1
local grain2
local grain3
local grain4
-- Meat
local meat1
local meat2
local meat3

-- Switchs
local switchFruits = 0
local switchdairy = 0
local switchgrains = 0
local switchmeat = 0
local info = true
-- Back Button
local backButton
local noTouch

function Healthy:init(x)
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
   -- Fruits
   fruit1 = Button("Dropbox:Food-Banana",vec2(WIDTH/2-445,HEIGHT-325))
   fruit2 = Button("Dropbox:Food-Broccoli",vec2(WIDTH/2-335,HEIGHT-325))
   fruit3 = Button("Dropbox:Food-Carrot",vec2(WIDTH/2-450,HEIGHT-665))
   fruit4 = Button("Dropbox:Food-Cucumber",vec2(WIDTH/2-335,HEIGHT-435))
   fruit5 = Button("Dropbox:Food-Strawberry",vec2(WIDTH/2-445,HEIGHT-545))
   fruit6 = Button("Dropbox:Food-Eggplant",vec2(WIDTH/2-335,HEIGHT-545)) 
   fruit7 = Button("Dropbox:Food-Grapes",vec2(WIDTH/2-340,HEIGHT-665)) 
   fruit8 = Button("Dropbox:Food-Pumpkin",vec2(WIDTH/2-445,HEIGHT-435)) 
   -- Dairy
   dairy1 = Button("Dropbox:Food-Cheese",vec2(WIDTH/2+85,HEIGHT-275))
   dairy2 = Button("Dropbox:Food-Milk",vec2(WIDTH/2+210,HEIGHT-300))
   -- Grains
   grain1 = Button("Dropbox:Food-Corn",vec2(WIDTH/2-70,HEIGHT-410))
   grain2 = Button("Dropbox:Food-Muffin",vec2(WIDTH/2-70,HEIGHT-285))
   grain3 = Button("Dropbox:Food-Bread",vec2(WIDTH/2-195,HEIGHT-285))
   grain4 = Button("Dropbox:Food-Potato",vec2(WIDTH/2-195,HEIGHT-410))
   -- Meat
   meat1 = Button("Dropbox:Food-Ham",vec2(WIDTH/2+355,HEIGHT-325))
   meat2 = Button("Dropbox:Food-Steak",vec2(WIDTH/2+455,HEIGHT-325))
   meat3 = Button("Dropbox:Food-Egg",vec2(WIDTH/2+395,HEIGHT-435))
   -- BACK BUTTON
   backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))   
   noTouch = Button("Dropbox:Background-FoodGroups",vec2(0,0))
   end

   function Healthy:draw()
   sprite("Dropbox:Background-FoodGroups",WIDTH/2,HEIGHT/2, 1024,768)  
   -- Text Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,725)
fontSize(60)
text("Healthy Food",WIDTH/2,675)
   fontSize(30)
 --  font("Baskerville-SemiBold")  
   font("Courier-BoldOblique")  
   fill(1, 241, 11, 255)
   text("Fruits and",WIDTH/2-400,HEIGHT/2+195)
   text("Vegetables",WIDTH/2-400,HEIGHT/2+150)
   fill(255, 170, 0, 255)
    text("Grain Products",WIDTH/2-135,HEIGHT/2+195)
   fill(77, 92, 135, 255)
   text("Dairy Products",WIDTH/2+145,HEIGHT/2+195)
   fill(159, 26, 25, 255)
   text("Meat and",WIDTH/2+400,HEIGHT/2+195)
   text("Alternatives",WIDTH/2+400,HEIGHT/2+150)
   font("CourierNewPS-BoldItalicMT")   
   fontSize(28)
       
       -- FRUIT INFORMATION
       fill(1, 241, 11, 255)
       if switchFruits == 1 then
       text("Banana",WIDTH/2+145,275) 
       text("Bananas contain a lot of potassium",WIDTH/2+145,200)
       text("which is good for your heart!",WIDTH/2+145,155)      
       end

       if switchFruits == 2 then
       text("Broccoli",WIDTH/2+145,275)
       text("Eat your broccoli kids! It is packed with",WIDTH/2+145,200)
       text("tons of nutrients that reduce cancer risks",WIDTH/2+145,155)
       text("and make you feel great!",WIDTH/2+145,105)
       end
    
       if switchFruits == 3 then
       text("Carrot",WIDTH/2+145,275)
       text("Carrots contain a lot of vitamin A which",WIDTH/2+145,200)
       text("is needed to maintain good eyesight.",WIDTH/2+145,155)
       text("Eat lots of carrots!",WIDTH/2+145,105)
       end
    
       if switchFruits == 4 then
       text("Cucumber",WIDTH/2+145,275)
       text("Cucumbers contain Vitamin B1, Vitamin B2,",WIDTH/2+145,200)
       text("Vitamin B3,Vitamin B5, Vitamin B,",WIDTH/2+145,155)
       text("Vitamin C... You get the idea..",WIDTH/2+145,105)
       end
    
       if switchFruits == 5 then
       text("Strawberry",WIDTH/2+145,275)  
       text("Strawberries are packed with antioxidents ",WIDTH/2+145,200)
       text("which help your body fight sicknesses!",WIDTH/2+145,155)
       end
    
       if switchFruits == 6 then
       text("Eggplant",WIDTH/2+145,275)
       text("Eggplants contain a very low amount of ",WIDTH/2+145,200)
       text("calories and a lot of nutrients which means  ",WIDTH/2+145,155)
       text("that it's healthy to eat a lot!",WIDTH/2+145,105)
       end
    
       if switchFruits == 7 then
       text("Grapes",WIDTH/2+145,275)
       text("Grapes are addictive foods to eat. They're ",WIDTH/2+145,200)
       text("also known to help balance your blood",WIDTH/2+145,155)
       text("sugar and keep you healthy!",WIDTH/2+145,105)
       end
    
       if switchFruits == 8 then
       text("Pumpkin",WIDTH/2+145,275)
       text("Many people don't think of eating pumpkins",WIDTH/2+135,200)
       text("other than in pie, but both pumpkins and",WIDTH/2+135,155)
       text("their seeds can be used in healthy meals!",WIDTH/2+135,105)
       end
    
    
       -- Dairy Information
       fill(77, 92, 135, 255)
       if switchdairy == 1 then
       text("Cheese",WIDTH/2+145,275) 
       text("When eaten in small amounts, cheese ",WIDTH/2+140,200)
       text("has lots of protein and calcium to  ",WIDTH/2+145,155)      
       text("help make you strong!",WIDTH/2+135,105)
       end

       if switchdairy == 2 then
       text("Milk",WIDTH/2+145,275)
       text("Milk contains lots of calcium so",WIDTH/2+141,200)
       text("make sure to drink a lot of milk to",WIDTH/2+141,155)
       text("make your bones strong!",WIDTH/2+131,105)
       end
    
       -- Grain Info
       fill(255, 170, 0, 255)
       if switchgrains == 1 then-- Fruits
       text("Corn",WIDTH/2+145,275) 
       text("Corn is a delicious grain containing",WIDTH/2+145,200)
       text("lots of vitamin A, B, and E!",WIDTH/2+145,155)      
   end

       if switchgrains == 2 then
       text("Muffin",WIDTH/2+145,275)
       text("Muffins aren't neccesarily the healthiest",WIDTH/2+145,200)
       text("food to eat, but whole grain muffins provide ",WIDTH/2+145,155)
       text("a healthier subsitute to most junk foods.",WIDTH/2+135,105)
   end
    
       if switchgrains == 3 then
       text("Bread",WIDTH/2+145,275)
       text("Bread often contains whole grains and",WIDTH/2+145,200)
       text("lots of fibre that helps you with digestion.",WIDTH/2+145,155)
   end
      
       if switchgrains == 4 then
       text("Potato",WIDTH/2+145,275)
       text("Potatoes are delicious foods, low in fat ",WIDTH/2+145,200)
       text("and high in protein! Protein is needed",WIDTH/2+145,155)
       text("to build big and strong muscles.",WIDTH/2+145,105)
    end
    
    
    -- Meat Info
    fill(159, 26, 25, 255)
    if switchmeat == 1 then
       text("Ham",WIDTH/2+145,275) 
       text("Like most meats, Ham contains a ",WIDTH/2+145,200)
       text("healthy dose of protein and plenty",WIDTH/2+145,155)      
       text("of iron for your body!",WIDTH/2+145,105)
   end

       if switchmeat == 2 then
       text("Steak",WIDTH/2+145,275)
       text("Steak provides protein your body uses ",WIDTH/2+145,200)
       text("to build strong muscles! It also comes",WIDTH/2+145,155)
       text("packed with iron and vitamin B12!",WIDTH/2+145,105)
   end

       if switchmeat == 3 then
       text("Eggs",WIDTH/2+145,275)
       text("Eggs are great foods to eat but don't eat",WIDTH/2+135,200)
       text("too many! They contain omega-3 and lower",WIDTH/2+135,155)
       text("your cholesterol which good for your heart!",WIDTH/2+135,105)      
   end
    
       if info== true then
       fill(62, 62, 62, 255)
       text("This Guide will teach you about healthy food!",WIDTH/2+117,200)
       text("Click on a food to learn more about it!",WIDTH/2+117,155)
       switchFruits = 0
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
   end


-- FRUITS
   fruit1:draw()
   fruit2:draw()
   fruit3:draw()
   fruit4:draw()
   fruit5:draw()
   fruit6:draw()
   fruit7:draw()
   fruit8:draw()
-- DAIRY
   dairy1:draw()
   dairy2:draw()
-- GRAINS
   grain1:draw()
   grain2:draw()
   grain3:draw()
   grain4:draw()
-- MEAT
   meat1:draw()
   meat2:draw()
   meat3:draw()
-- BACK BUTTON
   backButton:draw()
   end

function Healthy:touched(touch)
   noTouch:touched(touch)
   -- FRUITS
   fruit1:touched(touch)
   fruit2:touched(touch)
   fruit3:touched(touch)
   fruit4:touched(touch)
   fruit5:touched(touch)
   fruit6:touched(touch)
   fruit7:touched(touch)
   fruit8:touched(touch)
   -- DAIRY
   dairy1:touched(touch)
   dairy2:touched(touch)
   -- GRAINS
   grain1:touched(touch)
   grain2:touched(touch)
   grain3:touched(touch)
   grain4:touched(touch)
   -- MEAT
   meat1:touched(touch)
   meat2:touched(touch)
   meat3:touched(touch)
   -- BACK BUTTON
   backButton:touched(touch)

   if backButton.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pistol",    5)
end
       Scene.Change("Food")
       info = true
       switchFruits = 0
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       end 

if noTouch.selected == true then
       info = true
    end
    
   -- Fruit Info
   if fruit1.selected == true then
       switchFruits = 1
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit2.selected == true then
       switchFruits = 2
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end 

   if fruit3.selected == true then
       switchFruits = 3
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit4.selected == true then
       switchFruits = 4
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit5.selected == true then
       switchFruits = 5
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit6.selected == true then
       switchFruits = 6
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit7.selected == true then
       switchFruits = 7
       switchdairy = 0
       switchgrains = 0
       switchmeat = 0
       info = false
   end

   if fruit8.selected == true then
      switchFruits = 8
      switchdairy = 0
      switchgrains = 0
      switchmeat = 0
      info = false
   end
    
       -- Dairy Info
       if dairy1.selected == true then
       switchdairy = 1
       switchFruits = 0
       switchgrains = 0
       switchmeat = 0      
       info = false
       end

       if dairy2.selected == true then
       switchdairy = 2
       switchFruits = 0
       switchgrains = 0
       switchmeat = 0
       info = false
       end
    
       -- Grains Info
       if grain1.selected == true then
       switchgrains = 1
       switchdairy = 0
       switchFruits = 0
       switchmeat = 0
       info = false
   end

       if grain2.selected == true then
       switchgrains = 2
       switchdairy = 0
       switchFruits = 0
       switchmeat = 0
       info = false
   end

   if grain3.selected == true then
       switchgrains = 3
       switchdairy = 0
       switchFruits = 0
       switchmeat = 0
       info = false
   end
    
   if grain4.selected == true then
       switchgrains = 4
       switchdairy = 0
       switchFruits = 0
       switchmeat = 0
       info = false
   end
    
   -- Meat Info
      if meat1.selected == true then
       switchmeat = 1
       switchgrains = 0
       switchdairy = 0
       switchFruits = 0
       info = false
   end

       if meat2.selected == true then
       switchmeat = 2
       switchgrains = 0
       switchdairy = 0
       switchFruits = 0
       info = false
   end
       if meat3.selected == true then
       switchmeat = 3
       switchgrains = 0
       switchdairy = 0
       switchFruits = 0
       info = false
    end
end





























--# Junk
Junk = class()
local junk1
local junk2
local junk3
local junk4
local junk5
local junk6
local junk7
local noTouch

local backButton
local returnButton
local touchedOn = true
local switch = 8

function Junk:init()
supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN_NO_BUTTONS)
-- FOODS
junk1 = Button("Dropbox:Food-Cake",vec2(WIDTH/2-400,HEIGHT/1.5))
junk2 = Button("Dropbox:Food-Hamburger",vec2(WIDTH/2-140,HEIGHT/1.5))
junk3 = Button("Dropbox:Food-Fries",vec2(WIDTH/2-285,HEIGHT/2))
junk4 = Button("Dropbox:Food-Donuts",vec2(WIDTH/2+400,HEIGHT/1.5))
junk5 = Button("Dropbox:Food-Cookie",vec2(WIDTH/2+140,HEIGHT/1.5))
junk6 = Button("Dropbox:Food-Cupcake",vec2(WIDTH/2+10,HEIGHT/2))
junk7 = Button("Dropbox:Food-Hotdog",vec2(WIDTH/2+285,HEIGHT/2))
noTouch = Button("Dropbox:Background-FoodGroups",vec2(0,0))
backButton = Button("Dropbox:Back Icon", vec2(WIDTH/2-410, 675))       
end

function Junk:draw()
-- sprite("Documents:FoodGroups",WIDTH/2+300,HEIGHT/2, 1800,1000)  
sprite("Dropbox:Background-FoodGroups",WIDTH/2,HEIGHT/2, 1024,768)  
-- Text Setup
strokeWidth(5)
fill(255, 0, 0, 255)
fontSize(75)
font("Copperplate")
-- Text
text("Food Mania",WIDTH/2,725)
fontSize(60)
text("Junk Food",WIDTH/2,675)

 fontSize(37)
 font("CourierNewPS-BoldItalicMT")  
 fill(0, 0, 0, 255)

     junk1:draw()
     junk2:draw()
     junk3:draw()
     junk4:draw()
     junk5:draw()
     junk6:draw()
     junk7:draw()
     backButton:draw()



 -- FOOD INFORMATION

     if switch == 1 then
     text("Cake",WIDTH/2,225)
     text("Most cake is fatty and contains a lot of",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("sugar! The sugar takes away nutrients in ",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("your body that you need.",WIDTH/2,WIDTH/4-WIDTH/16*2.9)

     end

     if switch == 2 then
     text("Hamburgers",WIDTH/2,225)
     text("Although hamburgers contain some food groups,",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("many fast food restaurants use fake meat ",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("which is toxic to your body!",WIDTH/2,WIDTH/4-WIDTH/16*2.9)
 end

     if switch == 3 then
     text("Fries",WIDTH/2,225)
     text("French fries are often fried potatoes",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("Potatoes are healthy, but if you add it with",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("oil, it becomes unhealthy!",WIDTH/2,WIDTH/4-WIDTH/16*2.9)
 end

     if switch == 4 then
     text("Donuts",WIDTH/2,225)
     text("Donuts are often glazed with icing sugar.",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("This icing sugar has no vitamins and contains",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("many unnecessary calories!",WIDTH/2,WIDTH/4-WIDTH/16*2.9)     
 end

     if switch == 5 then
     text("Chocolate Chip Cookies",WIDTH/2,225)
     text("Chocolate chip cookies contain a lot of sugar.",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("When the sugar from the cookie isn't used",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("up it gets stored as extra fat.",WIDTH/2,WIDTH/4-WIDTH/16*2.9)
 end

     if switch == 6 then
     text("Cupcakes",WIDTH/2,225)
     text("Similar to most junk foods, cupcakes are",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("very sugary and this sugar can hurt your",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
     text("teeth and give you caveties.",WIDTH/2,WIDTH/4-WIDTH/16*2.9)
 end
    
     if switch == 7 then
         text("Hotdogs",WIDTH/2,225)
         text("Did you know that hotdogs are often made",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
         text("out of fake meat that contain lots of",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
         text("toxic chemical and preservatives.",WIDTH/2,WIDTH/4-WIDTH/16*2.9)
     end
   if switch == 8 then
     text("This Guide will teach you about junk food!",WIDTH/2,WIDTH/4-WIDTH/16*1.5)
     text("Click on a food to learn more about it!",WIDTH/2,WIDTH/4-WIDTH/16*2.2)
  end
end

function Junk:touched(touch)
     junk1:touched(touch)
     junk2:touched(touch)
     junk3:touched(touch)
     junk4:touched(touch)
     junk5:touched(touch)
     junk6:touched(touch)
     junk7:touched(touch)
     noTouch:touched(touch)
     backButton:touched(touch)

 if backButton.selected == true then
if soundEffects == true then
sound("Game Sounds One:Pistol",    5)
end
     Scene.Change("Food")
     switch = 8
     end

if noTouch.selected == true then
       switch = 8
   end

    -- MAKING TEXT SHOW UP WHEN CLICKED
     if junk1.selected == true then
     switch = 1
     info = false
     end

     if junk2.selected == true then
     switch = 2
     info = false
     end

     if junk3.selected == true then
     switch = 3
     info = false
     end

     if junk4.selected == true then
     switch = 4
     info = false
     end

     if junk5.selected == true then
     switch = 5
     info = false
     end

     if junk6.selected == true then
     switch = 6
     info = false
     end

   if junk7.selected == true then
       switch = 7
       info = false
   end
 end























