#require "ArduCAM.device.nut:1.0.0"

// Loop through all of the pixels and consider their differences in order
// to do a rough estimation of how similar the images are
function calcImageDifferences(img1, img2) {
    local pixelDiff = 0;
    local buf1 = [0, 0, 0];
    local buf2 = [0, 0 ,0];
    local len = 153604; // byte length of rgb qvga
    for(local i = 4; i < len; i+= len/128) {
            buf1[0] = ((img1[i] & 0xf8) >> 3);
            buf1[1] = ((img1[i] & 0x07) << 3) + ((img1[i +1] & 0xe0) >> 5);
            buf1[2] = img1[i +1] & 0x1f;
            
            buf2[0] = ((img2[i] & 0xf8) >> 3);
            buf2[1] = ((img2[i] & 0x07) << 3) + ((img2[i +1] & 0xe0) >> 5);
            buf2[2] = img2[i +1] & 0x1f;
            
            pixelDiff += pixelDifference(buf1, buf2);
    }
    return pixelDiff;
}

function pixelDifference(buf1, buf2) {
    // calculate the difference between the pixels. If it exceeds a threshold,
    // consider the pixels to be different
    local diff = math.abs(buf1[0] - buf2[0]) + math.abs(buf1[1] - buf2[1]) +
    math.abs(buf1[2] - buf2[2]);
    return (diff > 30) ? 1 : 0;
}
    
// Keep on taking RGB pictures until two have sufficient similarity to 
// assume that whatever came into frame is still 
function getClearPicture() {
    local diff = 101;
    myCamera.capture();
    img1 = myCamera.saveLocal();
    if(img1.len() == img2.len()) diff = calcImageDifferences(img1, img2);
    if(diff > 10) {
        img2 = img1;
        getClearPicture();
    } else {
        server.log("clear");
    }
    
}

// Call this method with the subject's name in order to take a photo of them
// and enroll it into your gallery
function enroll() {
    myCamera.set_jpeg_size(1600);
    myCamera.capture();
    agent.send("enroll", myCamera.saveLocal());
}

// Keep on taking RGB pictures and consider their differences. If there is
// a sufficient amount of difference between the last two, then we guess
// that something probably came into frame, so take a jpeg an analyze it
function capture_loop() {
    if(ready) {
        myCamera.capture();
        img1 = myCamera.saveLocal(); 
        if(img1.len() == img2.len()) { // only compare same size images 
            local diff = calcImageDifferences(img1, img2);
            if(count == 0) {
                if(diff > threshold) {
                    ready = false;
                    server.log("I see something!");
                    agent.send("something", "");
                    getClearPicture();
                    myCamera.reset();
                    myCamera.set_jpeg_size(1600);
                    myCamera.setExposure(0xffff);
                    // give the camera a moment
                    imp.sleep(0.5);
                    myCamera.capture();
                    server.log("sending...");
                    agent.send("detect", myCamera.saveLocal());
                    
                    count = 3;
                }
            }
            else {
                count--;
            }
        }
        
        img2 = img1;
    }
    
    imp.wakeup(0.1, capture_loop);
}

// Set ready to true once the agent has finished dealing with the jpeg we
// sent it so that we don't send more images while it's busy
function done(dn) {
    server.log("ready!");
    myCamera.reset();
    myCamera.brighten();
    myCamera.setRGB();
    ready = true;
}

// Specified SPI speed is 8MHz
// Specified I2C speed is 400kHz
const I2C_CLKSPEED  = 400000;
const SPI_CLKSPEED  = 6000; // kHz

// Increase outbound packet buffers to make TX faster
// wifi only!
imp.setsendbuffersize(32768); // returns last
server.log("Send Buffers set to "+imp.setsendbuffersize(32768));

spi <- hardware.spiBCAD;
// SCK max is 10 MHz for the device
spi.configure(CLOCK_IDLE_LOW | MSB_FIRST, SPI_CLKSPEED);

cs_l <- hardware.pinD;
cs_l.configure(DIGITAL_OUT, 1);

i2c <- hardware.i2cJK;
i2c.configure(I2C_CLKSPEED);

// Set up camera
myCamera <- Camera(spi, cs_l, i2c);

ready <- true; // whether to start considering pictures again
threshold <- 10; // threshold for number of pixels differnet for determining 
// whether something new came intothe frame 

img1 <- null;
img2 <- null;
count <- 3;

function setup() {
    myCamera.reset();
    myCamera.brighten();
    myCamera.setRGB();
    myCamera.capture();
    img2 = myCamera.saveLocal();
}

setup();

agent.on("done", done);

capture_loop(); // Comment me out if you are enrolling a face. Uncomment me if you are recognizing faces

// enroll(); // Uncomment me if you are enrolling a face. Comment me out if you are recognizing faces
