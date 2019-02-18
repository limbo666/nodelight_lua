-- Lua nodelight script to work with nodelight apk 
-- https://play.google.com/store/apps/details?id=io.nodelight.starter
-- The app and web service created by dinestronic@gmail.com. Original arduino script is here: https://github.com/Dinestronic/nodelight

-- This script is a NodeMCU firmware port to make this app work with lua
-- Credits for this script only: Nikos Georgousis

--WiFi setup
mySSID="Set_SSID_here" --set here your SSID
myPASS="WiFi_pass" --set here your WiFi password
--wifi.sta.config {ssid=mySSID, pwd=myPASS}
local nodelight_id= "ABCDEF123" --set here your nodelight id (provided by the android application)
--initialize the outputs
gpio.mode(1, gpio.OUTPUT) 
gpio.mode(2, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)
local script_active=0 --this variable prohibits timer to make multiple requests

function read()
script_active=1 
http.get("http://dinestronic.000webhostapp.com/nodelight/node_read.php?id="..nodelight_id, nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
	script_active=-1 --this means error (it can be used for erro handling)
    else
     -- print(data) 
	script_active=0 --re-arm the variable to loop
	--filter data
	dev1=(string.sub(data,string.find(data,"dev1") +7,string.find(data,"dev1")+7))
	dev2=(string.sub(data,string.find(data,"dev2") +7,string.find(data,"dev2")+7))
	dev3=(string.sub(data,string.find(data,"dev3") +7,string.find(data,"dev3")+7))
	dev4=(string.sub(data,string.find(data,"dev4") +7,string.find(data,"dev4")+7))
	--apply to outputs
	gpio.write(1,dev1)
	gpio.write(2,dev2)
	gpio.write(3,dev3)
	gpio.write(4,dev4)
	print("device1:"..dev1.." device2:"..dev2.." device3:"..dev3.." device4:"..dev4) --diagnostic output, can be removed 
    end
end)
end 

tmr.alarm(0, 1000, 1, function() 
	if script_active<1 then --if script is not running then call it again
		--print("asking for data") -- diagnostic output
		read()
	else
		--print("please wait") -- diagnostic output
	end
end)


