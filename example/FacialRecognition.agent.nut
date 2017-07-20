#require "PrettyPrinter.class.nut:1.0.1"

// ---------------- Kairos attempt ---------------------

appId <- "<YOUR APP ID>";
appKey <- "<YOUR API KEY>";

galleryName <- "ElectricImp";
subjectName <- "<YOUR NAME>";


function enroll(image, name, gallery) {
    local headers = {
        "Content-Type" : "application/json",
        "app_id" : appId,
        "app_key" : appKey
    }
    local parameters = http.jsonencode({
        "image" : http.base64encode(image),
        "subject_id" : name,
        "gallery_name" : gallery
    });
    local send_url = "https://api.kairos.com/enroll";
    local request = http.post(send_url, headers, parameters);
    local response = request.sendsync();
    local pp = PrettyPrinter();
    server.log(pp.format(http.jsondecode(response.body)));
}


function deleteGallery(gallery) {
    local headers = {
        "Content-Type" : "application/json",
        "app_id" : appId,
        "app_key" : appKey
    };
    
    local url = "https://api.kairos.com/gallery/remove";
    local data = http.jsonencode({
        "gallery_name" : gallery
    });
    local request = http.post(url, headers, data);
    local response = http.jsondecode(request.sendsync());
    if("status" in response && response.status == "Complete") {
        server.log("successfully deleted gallery");
    }
}

function detect(img) {
    local headers = {
        "Content-Type" : "application/json",
        "app_id" : appId,
        "app_key" : appKey
    };
    
    local url = "https://api.kairos.com/recognize";
    local data = http.jsonencode({
        "image" : http.base64encode(img),
        "gallery_name" : galleryName
    });
    
    local request = http.post(url, headers, data);
    local response = request.sendsync();
    local pp = PrettyPrinter();
    server.log(pp.format(http.jsondecode(response.body)));
    local ret = http.jsondecode(response.body);
    if("images" in ret) {
        server.log("image found");
        if("transaction" in ret.images[0] && ret.images[0].transaction.status == "success") {
            server.log("success");
            local myCandidates = ret.images[0].candidates;
            if(myCandidates.len() > 0) {
                local topCandidate = myCandidates[0].subject_id;
                local maxVal = myCandidates[0].confidence;
                
                foreach(i in myCandidates) {
                    if(i.confidence > maxVal) {
                        topCandidate = i.subject_id;   
                        maxVal = i.confidence;
                    }
                }
                
                if(maxVal > 0.5) {
                    local ret = format("Hello %s",
                    topCandidate, maxVal);
                    server.log(ret);
                    // Do something with topCandidate here...
                }
            }
            
        }
    }
    else {
        // Uh-oh, something went wrong
    }
    
    device.send("done", "");
}

device.on("detect", function(img) {
    detect(img);
});

device.on("enroll"), function(img) {
    enroll(img, subjectName, galleryName);
}

device.on("something" function(v) {
    server.log("Something came into the frame!");
});
