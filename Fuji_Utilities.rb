################################################################################
# FUIJI'S UTILITIES
# Version: 1.0 (Build 1)
# Date: 8/3/2016
# Developer: Fuji
################################################################################

################################################################################
# GRAPHICS AND INPUT EVENT HANDLERS
#
# DESCRIPTION:
# You can add more element to update before or after calling Graphics.update or
# Input.update, just add your method with
# Graphics/Input.[event] += method(:methodName) and remove it with
# Graphics/Input.[event] -= method(:methodName)
#
# EVENTS:
# onUpdate: Call the methods before calling the main update
# afterUpdate: Call the methods after calling the main update
################################################################################

module Graphics
	class << self
		attr_accessor	:onUpdate
		attr_accessor	:afterUpdate
		
		alias updateCaller update
		def update
			@onUpdate.trigger(self)
			updateCaller
			@afterUpdate.trigger(self)
		end
	end
	@onUpdate = Event.new
	@afterUpdate = Event.new
end

module Input
	class << self
		attr_accessor	:onUpdate
		attr_accessor	:afterUpdate
		
		alias updateCaller update
		def update
			@onUpdate.trigger(self)
			updateCaller
			@afterUpdate.trigger(self)
		end
	end
	@onUpdate = Event.new
	@afterUpdate = Event.new

end

# Test Event handler
=begin
class FrameCounter < Sprite
	def initialize(viewport=nil)
		super(viewport)
		@counter = 0
		self.z = 100000
		self.bitmap = Bitmap.new(Graphics.width,Graphics.height)
		self.bitmap.draw_text(0,0,Graphics.width,40,@counter.to_s)
	end
	
	def update
		super
		@counter += 1
		self.bitmap.clear
		self.bitmap.draw_text(0,0,Graphics.width,40,@counter.to_s)
	end
end

$frameCounter = FrameCounter.new

def updateCounter(*args)
	$frameCounter.update
end

Graphics.onUpdate += method(:updateCounter)
=end

################################################################################
# CUSTOM PBS READER
#
# DESCRIPTION:
# Passing the filename (just the name, without extension) the function returns
# a matrix Hash which contains the parsed data.
#
# EXAMPLE PBS:
# [Section1]
# Attribute1 = Value1
# # Comment in a line
# Attribute2 = Value2
# [Section2]
# Attribute3 = Value3
# Attribute4 = Value4
# Another comment
# Attribute5 = Value5
#
# EXAMPLE PARSED DATA:
# ["Section1" => [
#		"Attribute1" => "Value1",
# 	"Attribute2" => "Value2"],
# 	[
#		"Attribute3" => "Value3",
# 	"Attribute4" => "Value4",
# 	"Attribute5" => "Value5"]
# ]
#
# SOME IMPORTANT THINGS:
# 1- Sections and values support spaces (the value is readed till endline)
# 2- Spaces before the attribute name, before and after the equal symbol and
#    after the last word of the value are ignored
# 3- Spaces before and after square brackets (sections) are ignored
# 3- Parser ignores all lines with a '#' at the start of the line (comments)
################################################################################
def pbReadPBS(filename)
	parsedData = {}
	path = "PBS" + File::SEPARATOR + filename + ".txt"
	if !File.exists?(path)
		raise _INTL("File '{1}' doesn't exist", file)
	else
		File.open(path,"r") do |f|
			section = ""
			lineno = 0
			f.each_line do |line|
				lineno += 1
				line = line.chomp
				if  /^#/ =~ line
					next
				end
				echoln("Line " + lineno.to_s)
				
				if matchSection = /^\s*\[\s*(.+)\s*\]\s*$/.match(line)
					section = matchSection[1]
					parsedData[section] = {}
				elsif matchAttribute = /^\s*(\w+)\s*=\s*(.+)\s*$/.match(line)
					parsedData[section][matchAttribute[1]] = matchAttribute[2]
				else
					raise _INTL("Syntax error in line {1}", lineno.to_s)
				end
			end
		end
	end
	
	return parsedData
end

def testPbReadPBS(*args)
	if Input.press?(Input::F6)
		Console::setup_console
		data = pbReadPBS("achievement")
		echoln(data)
		data.each { |bb, zz|
			echoln("[" + bb+ "]")
			zz.each { |aa, cc|
				echoln(aa + " = " + cc)
			}
		}
	end
end

Input.afterUpdate += method(:testPbReadPBS)