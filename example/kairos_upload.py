import requests
import json
import base64
import sys

name = sys.argv[2]
fileName = sys.argv[1]
galleryName = "<GALLERY NAME>"

link = "https://api.kairos.com/enroll"
appId = "<APP ID>"
appKey = "<APP KEY>"

header = {'Content-Type' : 'application/json',
           'app_id' : appId,
           'app_key' : appKey
           }

js =        json.dumps({
            "image" : base64.b64encode(open(fileName, "rb").read()).decode('ascii'),
            "subject_id" : name,
            "gallery_name" : galleryName
            })

r = requests.post(link, headers=header, data=js, verify=False)

if(r.status_code == requests.codes.ok):
	print "OK"
else:
	print "Fail"
