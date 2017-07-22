# LiveWings
# 1.run the ballerina service file
  flightTrackerSerive.bal
# 2.then open the index.html and enter a callsign for search a flight
  index.html
This is web app which monitors live air traffic.This allows you to track your loved ones, in flights which would allow a customized search, which displays all the vital information of the flight such as the location, speed, position on the map.

This ballerina service file have connected to two API's.
1.Flight data API
2.Google maps API

The flight APIs data collected as json objects and they have being analyzed using Ballerina. Struct has been used to create a template of flight data.
The flight's
 # Position,Altitude,Speed,From where,To where, Aeroplane type and manufacture will be processed using Ballerina. Then those data will be reflected as a Webservice to users.
 
 
 The users will be able to search the flight by its 'callsign' sample callsign = "N137AA0"
 # You can download more callsigns online
 
 
 
