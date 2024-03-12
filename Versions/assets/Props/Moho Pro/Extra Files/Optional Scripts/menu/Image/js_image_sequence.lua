--[[
LIMITATIONS:
-must have some valid extension
-must have valid numbering
-don't use numbers in names in the last 10 chars...
DONE:
-support all padding
-support extensions other than 4 char (ex : .ai ) 
-ImportEPS(path)
TODO:
-visibility off after last frame
-menu to choose frame step etc...
-insert at current time
-any request?

++
-mac osX / linux file path suppport ex :
"/Volumes/travail2/fabulettes/elems/julien pissenlits/01 Les pissenlits.aif"

]]
-- **************************************************
-- Provide Moho with the name of this script object
-- **************************************************

ScriptName = "JS_image_sequence"

-- **************************************************
-- General information about this script
-- **************************************************

JS_image_sequence = {}
function JS_image_sequence:Name()
	return "Image sequence"
end

function JS_image_sequence:Version()
	return "1.2"
end

function JS_image_sequence:Description()
	return "Import bitmap or vector image sequence in a switch layer (files must have valid extension)"
end

function JS_image_sequence:Creator()
	return "Julien Stiegler"
end

function JS_image_sequence:UILabel()
	return("Import Image Sequence...")
end


-- **************************************************
-- The guts of this script
-- **************************************************

JS_image_sequence.bitmapPath = ""

function JS_image_sequence:OnMouseDown(moho, mouseEvent)
	self:Run(moho)
end


function JS_image_sequence:Run(moho)

	--let user select the first image bitmap (formats : jpg, png, tif, bmp, tga)
	
	JS_image_sequence.bitmapPath = LM.GUI.OpenFile("Select the first image file of the sequence")
	if (self.bitmapPath == "") then
		return
	end
	local f = io.open(self.bitmapPath, "r")
	if (f == nil) then
		print("file doesn't exist!:", self.bitmapPath)
		return
	end
	f:close()
	
	local s = JS_image_sequence.bitmapPath	--valid filepath
	
	--guess padNum, suffix, etc..
--	local padding = "%d%d%d%d"		--0000
--	JS_image_sequence.padNums = 4

-------- TODO : no magic number : find the last slash
	local lastSlashPosition
	local pos = -1
	while lastSlashPosition==nil do
		lastSlashPosition = string.find(s, "[\\/]", pos)			
		pos = pos - 1
	end
--	print(pos, lastSlashPosition)
--	local fileName = 	string.sub(s ,string.find(s, "[\\/]", -10)+1) --buggish here
	local fileName = 	string.sub(s ,string.find(s, "[\\/]", lastSlashPosition)+1 )
	local revLastSlashPos = string.len(s)-lastSlashPosition
	
--	print(revLastSlashPos)
--------


--	local guessNum = string.sub(s , string.find(s, "(%d+)", -10) )
	local guessNum = string.sub(s , string.find(s, "(%d+)", -revLastSlashPos) )
	JS_image_sequence.padNums = string.len(guessNum)	
	local padding = ""		--0000
	for i =  0, self.padNums-1 , 1 do 
		padding = padding.."%d"
	end
	
	--magic number : extension not more than 4 char long!
	local guessSuffix = string.sub(s , string.find(s, ".(%a+)", -5) )
	JS_image_sequence.suffixLen = string.len(guessSuffix)	
	
--	-10 from end contains numbering and no other numbers! (i hope!)
--[[
	local prefix = string.sub(s ,0 ,string.find(s, padding, -10)-1)
	local number = string.sub(s ,string.find(s, padding, -10))
]]
	local prefix = string.sub(s ,0 ,string.find(s, padding, -revLastSlashPos)-1)
	local number = string.sub(s ,string.find(s, padding, -revLastSlashPos))
	
	local suffix = string.sub(s, -self.suffixLen)
--filenames!!	--"/Volumes/travail2/fabulettes/elems/julien pissenlits/01 Les pissenlits.aif"
--	local imgName = string.sub(s ,string.find(s, "[\\]", -20)+1)

--	local imgName = string.sub(s ,string.find(s, "[\\/]", -20)+1)
	local imgName = 	string.sub(s ,string.find(s, "[\\/]", lastSlashPosition)+1 )
	
	if( string.find(suffix, ".ai") or string.find(suffix, ".eps") ) then
		JS_image_sequence.layerType = "vec"
	else
		JS_image_sequence.layerType = "img"
	end

	--print(prefix, number, suffix, imgName)
	
	
	--for (index=0; file(index)exist; index++)
	--iLayer[index]=...
	--PlaceLayerInGroup...
	--SwitchLayer:SetValue
	JS_image_sequence.index = tonumber(number)
	local endFrame = number + self:countFiles(prefix, number, suffix) - 1
	
	--self:Exists(prefix..self:formatNumber(self.index)..suffix)

	moho.document:PrepUndo(nil)
	moho.document:SetDirty()
	JS_image_sequence.sLayer = moho:LayerAsSwitch( moho:CreateNewLayer(MOHO.LT_SWITCH, false) )
	JS_image_sequence.sLayer:SetName("Image Sequence")
	
	--save initial frame to restor later
	JS_image_sequence.initFrame = moho.frame
	
	for i =  self.index, endFrame, 1 do 
		if(self.layerType=="img") then
			local anImageLayer = moho:LayerAsImage( moho:CreateNewLayer(MOHO.LT_IMAGE, false) )
			local anImagePath = prefix..self:formatNumber(i, self.padNums)..suffix
			local anImageName = imgName.."_"..i
			anImageLayer:SetSourceImage(anImagePath)	
			anImageLayer:SetName(anImageName)
			moho:PlaceLayerInGroup(anImageLayer, self.sLayer, false, false)
			moho:SetCurFrame(i, false)
			self.sLayer:SetValue(moho.frame, anImageName)
		else
			local anImagePath = prefix..self:formatNumber(i, self.padNums)..suffix
			local anImageName = imgName.."_"..i
			moho:ImportEPS(anImagePath)
			moho.layer:SetName(anImageName)
			moho:PlaceLayerInGroup(moho.layer, self.sLayer, false, false)
			moho:SetCurFrame(i, false)
			self.sLayer:SetValue(moho.frame, anImageName)
		end
 
	end
	--now select the parent switch layer... and go back to initial frame
	moho:SetSelLayer( JS_image_sequence.sLayer )
	JS_image_sequence.sLayer:Expand( false )
	moho:SetCurFrame( self.initFrame )
	
	
end

function JS_image_sequence:countFiles(prefix, number, suffix)
	local count = 0
	local fileExists = true
	repeat
		count = count+1
		fileExists = self:Exists(prefix..self:formatNumber(number+count, self.padNums)..suffix)
	until
		fileExists ~= true
	return count
end
function JS_image_sequence:formatNumber(num, pad)
	local result = ""
	if( tonumber(num) <10) then
		for i =  0, tonumber(pad)-2 , 1 do 
			result = result.."0"
		end
		return result..num
	elseif( tonumber(num) <100) then
		for i =  0, tonumber(pad)-3 , 1 do 
			result = result.."0"
		end
		return result..num
	elseif( tonumber(num) <1000) then
		for i =  0, tonumber(pad)-4 , 1 do 
			result = result.."0"
		end
		return result..num
	elseif( tonumber(num) <10000) then
		for i =  0, tonumber(pad)-5 , 1 do 
			result = result.."0"
		end
		return result..num
	end
end
--[[
function JS_image_sequence:formatNumber(num)
	if( tonumber(num) <10) then
		return "000"..num
	elseif( tonumber(num) <100) then
		return "00"..num
	elseif( tonumber(num) <1000) then
		return "0"..num
	end
end
]]
function JS_image_sequence:Exists(filepath)
--	print("exists?:", filepath)
	local f = io.open(filepath, "r")
	if( f ~= nil ) then
		f:close()
		return true;
	else
		return false;
	end
end
	
	--[[
	ImageLayer:SetSourceImage(path)
	SwitchLayer:SetValue(frame, value)
	SwitchLayer:SetSourceFile(path)
	
	--path errors! http://www.lua.org/pil/8.1.html C:\\windows\\luasocket.dll
--	self.bitmapPath = "copain0001.jpg"
--	self.bitmapPath = string.format("I:\\copain0001.jpg")
--	self.bitmapPath = string.format("I:\\projets\\fabulettes\\270305\\copain\\copain0001.jpg")
--	self.bitmapPath = string.format("/I/projets/fabulettes/270305/copain/copain0001.jpg")
--	print("image path:", self.iLayer:SourceImage() )
	]]
	--doesn't work!
--	JS_image_sequence.iLayer = moho:CreateNewLayer(MOHO.LT_IMAGE)

--[[
--works for a single file :
	JS_image_sequence.iLayer = moho:LayerAsImage( moho:CreateNewLayer(MOHO.LT_IMAGE) )
	self.iLayer:SetSourceImage(self.bitmapPath)	
--	print("layer path:", self.bitmapPath )	
	JS_image_sequence.sLayer = moho:LayerAsSwitch( moho:CreateNewLayer(MOHO.LT_SWITCH) )
	moho:PlaceLayerInGroup(self.iLayer, self.sLayer, true)
]] 
--	moho:ImportEPS(self.bitmapPath)
--	print("self.bitmapPath", self.bitmapPath)
	--now the same with all images
	--get parts of name : prefix - padding - sufix


--	local s = "Deadline is 30/05/1999, firm"
--	local date = "%d%d/%d%d/%d%d%d%d"
--	print(string.sub(s, string.find(s, date)))   --> 30/05/1999
--	local s = "D:\\image0001.jpg"
--[[
	--buggish if numbers in path! :
	local s = JS_image_sequence.bitmapPath
	local padding = "%d%d%d%d"
	local prefix = string.sub(s ,0 ,string.find(s, padding)-1)
	local number = string.sub(s ,string.find(s, padding))
	local suffix = string.sub(s, -4)
]]
	--[[
	JS_image_sequence.startFrame=number;
	JS_image_sequence.endFrame=number;
	JS_image_sequence.prefix="";
	JS_image_sequence.suffix=suffix;
	]]
