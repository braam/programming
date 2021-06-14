# coding=utf-8

'''
Retrieve detailed live values from Huwai SolarFusion webportal
*\@ braam.vanhavermaet*gmail.com
Version: 1.2
	+ Run only during daylight
	+ If not daylight return attributes as zero.

>> LAT/LONG through https://www.latlong.net/convert-address-to-lat-long.html.
'''

import requests, json, ephem, time

#>> Global variables
home        = ephem.Observer()  
home.lat    = 'xx.x'           # str() Latitude
home.lon    = 'x.x'            # str() Longitude
next_sunrise    = home.next_rising(ephem.Sun()).datetime()
next_sunset     = home.next_setting(ephem.Sun()).datetime()

portalUser = "USERNAME"
portalPassword = "PASSWORD"
PV_stationDN = "XXXXXXXX"

huaweiMainUrl = "https://intlobt.fusionsolar.huawei.com"
huaweiPortalUrl = huaweiMainUrl + "/rest/pvms/web/station/v1/overview/energy-flow?stationDn=NE=" + PV_stationDN
huaweiStatsUrl = huaweiMainUrl + "/rest/pvms/web/station/v1/overview/station-detail?stationDn=NE%3D" + PV_stationDN
huaweiTotalUrl = huaweiMainUrl + "/rest/pvms/web/station/v1/station/total-real-kpi"
huaweiLoginUrl = huaweiMainUrl + "/unisso/v2/validateUser.action?service=%2Funisess%2Fv1%2Fauth%3Fservice%3D%252Frest%252Fpvms%252Fweb%252Fstation%252Fv1%252Foverview%252Fenergy-flow%253FstationDn%253DNE%25253D" + PV_stationDN
#<< end Global variables


#>> Functions
def getPVdata():
	s = requests.session()
	r = s.get(huaweiPortalUrl) #get page first to set cookies.

	r = s.post(huaweiLoginUrl, json={"organizationName":"", "username":portalUser, "password":portalPassword})
	
	#Next get redirectURL value from JSON, it'll contains the data we need.. also in JSON format.
	json_response = json.loads(r.text)
	if not json_response['errorCode']:
		solar_data_url = "https://intlobt.fusionsolar.huawei.com" + json_response['redirectURL']
		solar_data = s.get(solar_data_url)
		solar_stats = s.get(huaweiStatsUrl)
		solar_total = s.get(huaweiTotalUrl)

		PV_data = json.loads(solar_data.text) #convert to json.
		PV_stats = json.loads(solar_stats.text)
		PV_total = json.loads(solar_total.text)
	    
		outputList = {} #create empty list for json output.
		outputList['activePower'] = PV_data["data"]["flow"]["nodes"][1]["deviceTips"]["ACTIVE_POWER"]
		outputList['electricalLoad'] = PV_data["data"]["flow"]["nodes"][4]["description"]["value"].split()[0]
		outputList['onGrid'] = PV_data["data"]["flow"]["links"][4]["description"]["value"].split()[0]
		outputList['yearEnergy'] = PV_stats["data"]["yearEnergy"]
		outputList['monthEnergy'] = PV_stats["data"]["monthEnergy"]
		outputList['dayEnergy'] = PV_stats["data"]["dailyEnergy"]
		outputList['totalEnergy'] = PV_total["data"]["cumulativeEnergy"]
		
		print(json.dumps(outputList)) #print as json to let HASS parse the attributes.

#<< end Functions


'''
 ** @@MAIN@@
'''
#check for daylight, otherwise return attributes as zero.
if next_sunset < next_sunrise:
	getPVdata()
else:
	print('{"onGrid": "0", "activePower": "0", "monthEnergy": "0", "totalEnergy": "0", "dayEnergy": "0", "yearEnergy": "0", "electricalLoad": "0"}')
