#!/usr/bin/python
import simplejson as json, requests
import urllib,urllib2
import sys,time

##
# dragonsubs.py coded by Braam
# @www: github.com/braam
# @version: 1.0
print "dragonsubs.py coded by Braam \n@www: github.com/braam \n@version: 1.0"


##
# Retrieve arguments or exit
#
if len(sys.argv) >1:
	formdata = {
		'fichier': str(sys.argv[1]),
		'lg': str(sys.argv[2]),
	}
else: 
	print "Usage: dragonsubs.py <title> <language>, for a complete language list visit www.dragonsubtitles.com"
	exit()


##
# Submit POST formdata with arguments
# curl 'http://www.dragonsubtitles.com/assetz/php/search.html' --data "fichier=Mr.Robot.S02E09&lg=dut" > testSUB.txt
req = urllib2.Request(url="http://www.dragonsubtitles.com/assetz/php/search.html",
                      data=urllib.urlencode(formdata), 
                      headers={"Content-type": "application/x-www-form-urlencoded"}) 
response = urllib2.urlopen(req)


##
# Parse response as JSON file
data = json.loads(response.read())

if data['subs']['status'] == "200 OK":
	print "**200 OK, parsing subtitles.."
	time.sleep(1)
	count = 0
	for subtitle in data['subs']['data']:
		print "[",count,"]", subtitle['MovieReleaseName']
		count += 1
else:
	print "** Unknown error, exiting.."
	exit()


##
# Get desired download
input_var = raw_input("Which subtitle would you like to download? use * for all: ")
if input_var == "*":
	for subtitle in data['subs']['data']:
		subfile = urllib.URLopener()
		subfile.retrieve(subtitle['ZipDownloadLink'],subtitle['SubFileName']+".zip")
else:
	input_var = int(input_var)
	subfile = urllib.URLopener()
	subfile.retrieve(data['subs']['data'][input_var]['ZipDownloadLink'], data['subs']['data'][input_var]['SubFileName']+".zip")

print "Subtitle(s) have been saved in working directory."

