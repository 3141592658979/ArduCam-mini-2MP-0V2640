# ArduCAM OV2640
This library provides driver and agent code for the ArduCAM OV2640 camera.

To add this library to your project, add ```#require "ArduCAM.device.nut:1.0.0"``` to the top of your device code and ```#require "ArduCAM.agent.nut:1.0.0"``` to the top of your agent code

## Class Usage - Agent

### Constructor: Camera(*cb*)
The constructor takes a single required parameter: a callback function that is called when a jpeg image is received from the device. The callback function should be prepared to take the jpg image as its sole parameter.

#### Example
```
agentCam <- Camera(processImage);
```

### Class Methods

### init()
Init must be called to initialize callback functions for receiving jpeg images. 

#### Example
```
agentCam.init();
```

## Class Usage - Device

### Constructor: Camera(*spi*, *cs_l*, *i2c*)
The constructor takes three required parameters: a pre-configured spi bus, a chip select pin for spi (it need not be pre-configured), and a pre-configured i2c bus. The spi bus, according to the camera datasheet, should have a maximum data rate of 8MHz, and the i2c bus, according to the camera datasheet, should have a data rate of 400kHz. The spi bus must have CPOL = CPHA = 0.
#### Example
```
spi <- hardware.spiBCAD;
// SCK max is 10 MHz for the device
spi.configure(CLOCK_IDLE_LOW | MSB_FIRST, SPI_CLKSPEED);

cs_l <- hardware.pinD;

i2c <- hardware.i2cJK;
i2c.configure(I2C_CLKSPEED);

// Set up camera
myCamera <- Camera(spi, cs_l, i2c);
```

## Class Methods

### reset()
The reset() method resets the OV2640 registers to their default state and loads default parameter sets. By default, it sets the image mode as 320x240 JPEG.

#### Example
```
myCamera.reset();
```

### capture()
The capture() method takes a picture and loads it into the fifo buffer.

#### Example
```
myCamera.capture();
```

### send_buffer()
The send_buffer() method sends the current image in the fifo buffer to the agent. The agent is only prepared to handle jpeg images, so it is necessary to ensure that the image taken was a jpeg.

#### Example
```
myCamera.capture(); // store a picture in fifo
myCamera.send_buffer();
```

### set_jpeg_size(*size*)
The set_jpeg_size(size) method will configure the camera to take a jpeg of the passed size. Supported sizes are 160x120, 176x144, 320x240, 352x288, 640x480, 800x600, 1024x768, 1280x960, and 1600x1200. You must pass the desired width. If a non-supported width is passed, by default 320x240 will be selected.

#### Example
```
myCamera.set_jpeg_size(800);
```

### setRGB()
The setRGB() method will configure the camera to take images in the RGB565 format.

#### Example
```
myCamera.setRGB();
```

### setYUV422()
The setYUV422() method will configure the camera to take images in the YUV422 format.

#### Example
```
myCamera.setYUV422();
```

### saveLocal()
The saveLocal() method will return the image in the fifo buffer. This method is used to get a copy of the image on the device.

#### Example
```
myCamera.setRGB();
myCamera.capture();
local img = myCamera.saveLocal();
// Do something with the image here...
```

### brighten()
The brighten() image will brighten the image taken by the camera.

#### Example
```
myCamera.brighten();
```

### setExposure(*exp*)
The setExposure(exp) method will set the exposure of the images taken by the camera. The parameter to setExposure should be a 16-bit number, with larger numbers corresponding to longer exposure times.

#### Example
```
myCamera.setExposure(0xffff);
```

# License
The ArduCAM library is licensed under the [MIT License](https://github.com/electricimp/ArduCam_0v2640/blob/develop/LICENSE)
