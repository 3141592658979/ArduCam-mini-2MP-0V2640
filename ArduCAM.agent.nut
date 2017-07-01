#require "PrettyPrinter.class.nut:1.0.1"
#require "rocky.class.nut:2.0.0"

const css = @"
body {
    background: #35a8dd;
    color: white;
    font-family: ""Helvetica Neue"", ""Helvetica"",""sans"";
}
"

settings <- {
    accessControl = true,
    allowUnsecure = true,
    strictRouting = false,
    timeout = 50
};

app <- Rocky(settings);


// ---------------- Kairos attempt ---------------------

appId <- "<APP ID>";
APP_key <- "<APP KEY>";

galleryName <- "MyGallery";


function enroll(name, gallery) {
    local headers = {
        "Content-Type" : "application/json",
        "app_id" : appId,
        "app_key" : APP_key
    }
    local parameters = http.jsonencode({
        // "url" : image_url,
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
        "app_key" : APP_key
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

function detect(gallery) {
    local headers = {
        "Content-Type" : "application/json",
        "app_id" : appId,
        "app_key" : APP_key
    };
    
    local url = "https://api.kairos.com/recognize";
    local data = http.jsonencode({
        "image" : http.base64encode(image),
        "gallery_name" : gallery
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
        // Uh-oh, we didn't recognize anyone
    }
    
    device.send("done", "");
}

http.onrequest(function(req,res) {
    server.log("0");
    if (req.path == "/camera.JPG") {
        res.header("Content-Type", "image/jpeg");
        res.send(200, image);
    }else if (req.path == "/css.css") {
        res.header("Content-Type", "text/css");
        res.send(200, css);
    } 
});

jpeg_buffer <- null
jpeg_startat <- 0;
image <- null

device.on("something", function(arg) {
    // Do something here...
});

device.on("jpeg_start", function(size) {
    jpeg_buffer = blob(size);
    jpeg_startat = time();
});

device.on("jpeg_chunk", function(v) {
    // check we've not got some barf from a previous boot
    if (jpeg_buffer == null) return;

    local offset = v[0];
    local b = v[1];
    for(local i = offset; i < (offset+b.len()); i++) {
        if(i < jpeg_buffer.len()) {
            jpeg_buffer[i] = b[i-offset];
        }
    }
});

device.on("jpeg_end", function(v) {
    // check we've not got some barf from a previous boot
    if (jpeg_buffer == null) return;

    // copy last JPEG to web server blob
    image = jpeg_buffer
    
    server.log("done");
    
    detect(galleryName);
    
    server.log(format("Agent: JPEG Received (%d bytes) at rate of %.2fkB/s",image.len(), (image.len()/1024.0)/(time()-jpeg_startat)));
    server.log(format("Agent memory remaining: %d bytes", imp.getmemoryfree()));
});

device.on("enroll" function(name) {
    enroll(name, galleryName);
})
