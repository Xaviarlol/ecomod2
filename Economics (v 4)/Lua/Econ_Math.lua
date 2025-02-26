-- Econ_Math
-- Author: FramedArchitecture
-- DateCreated: 5/5/2015
--------------------------------------------------------------
local ceil = math.ceil
local floor = math.floor
local min = math.min
local max = math.max
local abs = math.abs
local power = math.pow
local seed = math.randomseed
local rand = math.random
local match = string.match
local L = Locale.ConvertTextKey
--------------------------------------------------------------
function locale(str, ...)
	return L(str, ...)
end
--------------------------------------------------------------
function date(num)
	if (num < 0) then
		return tostring(abs(num)) .. " BC"
	else
		return tostring(abs(num)) .. " AD"
	end
end
--------------------------------------------------------------
function culture(num)
	return tostring(comma(num)) .. "[ICON_CULTURE]"
end
--------------------------------------------------------------
function currency(num)
	return tostring(comma(num)) .. "[ICON_GOLD]"
end
--------------------------------------------------------------
function decimalshift(num, ishift)
	return num*power(10, ishift)
end
--------------------------------------------------------------
function percent(num, idp)
	return tostring(round(100*num, idp)) .. "%"
end
--------------------------------------------------------------
function comma(num)
	local left,num,right = match(num,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
--------------------------------------------------------------
function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
--------------------------------------------------------------
function up(num)
	return ceil(num)
end
--------------------------------------------------------------
function down(num)
	return floor(num)
end
--------------------------------------------------------------
function smaller(num1, num2)
	return min(num1, num2)
end
--------------------------------------------------------------
function larger(num1, num2)
	return max(num1, num2)
end
--------------------------------------------------------------
function absolute(num)
	return abs(num)
end
--------------------------------------------------------------
function negative(num)
	local neg = (num ~= 0) and -num or 0
	return neg
end
--------------------------------------------------------------
function average(t)
	local iSum = 0
	local iCount = 0
	for k,v in pairs(t) do
		if type(v) == 'number' then
		  iSum = iSum + v
		  iCount = iCount + 1
		end
	end
	return (iSum/iCount)
end
--------------------------------------------------------------
function pow(x, y)
	return power(x, y)
end
--------------------------------------------------------------
function decay(num, rate)
	local fMultiplier = (2.2 - power(1.5, rate))
	fMultiplier = (fMultiplier > 1.15) and 1.15 or fMultiplier
	return (num*fMultiplier)
end
--------------------------------------------------------------
function random(min, max)
	seed(tonumber(tostring(os.time()):reverse():sub(1,6)))
	local min = min and min or 1
	local max = max and max or 100
	return rand(min, max)
end
--------------------------------------------------------------
