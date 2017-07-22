import ballerina.lang.jsons;
import ballerina.lang.messages;
import ballerina.lang.system;
import ballerina.net.http;
import ballerina.net.ws;
import ballerina.net.uri;



struct Flight{
		
		string lat;
		string lon;
		string alti;
		string spd;
		float spdKmh;
		string from;
		string to;
		string aeroplaneType;
		string aeroplaneComp;
		string originCountry;
		}
		
@http:configuration {basePath:"/flightTracker"}
@ws:WebSocketUpgradePath {value:"/data"}




service<ws> flightTrack {
    string address = "https://public-api.adsbexchange.com/VirtualRadar";
	string countryAPI = "https://maps.googleapis.com/maps/api/geocode/";
    http:ClientConnector apiAddress = create http:ClientConnector(address);
	http:ClientConnector country = create http:ClientConnector(countryAPI);
	
    
	
	@ws:OnOpen {}
    resource onOpen(message m) {
        system:println("FlightTracker user joined!!");
    }
	
	
	@ws:OnTextMessage {}
    resource onTextMessage(message m) {
        string stringPayload = messages:getStringPayload(m);
        if ("" == stringPayload) {
           string empt = "Callsign was empty!";
		   ws:pushText(empt);
        } else {
		
			 string callSign = stringPayload;
             message n = {};
		while(true){
		
        message response = http:ClientConnector.get(apiAddress,"/AircraftList.json?fCallC="+uri:encode(callSign), n);
		
		json resonseInJson = messages:getJsonPayload(response);
		json acList = resonseInJson["acList"];
		
		if(jsons:toString(acList)=="[]"){
		 
		system:println("Flight is out of ADS-B reciever range");
		  break;
		}
		
		
		else{
		
		acList = acList[0];
		json lat = acList["Lat"];
		json lon = acList["Long"];
		json alti = acList["GAlt"];
		json spd = acList["Spd"];
		json from = acList["From"];
		json to = acList["To"];
		json aeroplaneType = acList["Mdl"];
		json aeroplaneComp = acList["Man"];
		json originCountry = acList["Cou"];
		
		message response1 = http:ClientConnector.get(country,"json?latlng="+uri:encode(jsons:toString(lat))+","+uri:encode(jsons:toString(lon))+"&result_type=political&key=AIzaSyCYSr-QoaCRjzN2ri5NmNzLMNX4_cffwSs", n);
		
		
		json countryData = messages:getJsonPayload(response1);
		json countryData1 = countryData["results"];
		countryData1 = countryData1[0];
		countryData1 = countryData1["formatted_address"];
		
		var spdKmh,_ = <float>(jsons:toString(spd));
		spdKmh = spdKmh*1.852;
		
		Flight f1 = {lat:(jsons:toString(lat)),lon:(jsons:toString(lon)),alti:(jsons:toString(alti)),spd:(jsons:toString(spd)),
		spdKmh:spdKmh,from:(jsons:toString(from)),to:(jsons:toString(to)),aeroplaneType:(jsons:toString(aeroplaneType)),aeroplaneComp:(jsons:toString(aeroplaneComp)),originCountry:(jsons:toString(originCountry))};
		
		json data = {lat:lat,lon:lon,alti:alti,spd:spd,spdKmh:spdKmh,from:from,to:to,nowIn:countryData1,aeroplaneType:aeroplaneType,aeroplaneComp:aeroplaneComp,originCountry:originCountry};
		system:println(jsons:toString(data));
		system:println("Latitude         >>"+jsons:toString(lat));
		system:println("Longitude        >>"+jsons:toString(lon));
		system:println("Altitude         >>"+jsons:toString(alti));
		system:println("Speed (knot)     >>"+jsons:toString(spd));
		system:println("Speed (kmph)     >>"+spdKmh);
		system:println("From             >>"+jsons:toString(from));
		system:println("To               >>"+jsons:toString(to));
		system:println("Now in           >>"+jsons:toString(countryData1));
		system:println("Airoplane        >>"+jsons:toString(aeroplaneType));
		system:println("Airoplane Manufac>>"+jsons:toString(aeroplaneComp));
		system:println("Origin Country   >>"+jsons:toString(originCountry));
		
        
		system:println("--------------");
		
		message dataMsg={};
		messages:setJsonPayload(dataMsg,data);
		string dataStr = jsons:toString(data);
		ws:pushText(dataStr);
        }
    }
    
	}
		
    }
	
	@ws:OnClose {}
    resource onClose(message m) {
        system:println("client left the server.");
    }
	
        
}

