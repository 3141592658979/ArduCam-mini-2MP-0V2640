import requests
import json
import base64
import sys

name = sys.argv[2]
filename = "/" + sys.argv[1]
gallery_name = "MyGallery"

link = "https://api.kairos.com/enroll"
appId = "<APP ID>";
APP_key = "<APP KEY>";

header = {'Content-Type' : 'application/json',
           'app_id' : appId,
           'app_key' : APP_key
           }
path = "<YOUR IMAGE PATH>"
js =        json.dumps({
            "image" : base64.b64encode(open(path + filename, "rb").read()).decode('ascii'),
            "subject_id" : name,
            "gallery_name" : gallery_name
            })

r = requests.post(link, headers=header, data=js, verify=False)
print r.text
