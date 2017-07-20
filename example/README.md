# ArduCAM OV2640 Example Code: Facial Recognition
This example code shows an application of the OV2640 ArduCAM. This application uses the Kairos Facial Recognition API to detect and recognize faces.

To run this code, you'll first need to set up an account on Kairos to get an app ID and API key. 

## Setting up Kairos Account

1. Go to the [Kairos Developer Page](http://kairos.com/docs/) and click GET YOUR API KEY
2. Scroll to the bottom and select GET YOUR FREE API KEY
3. Fill in your information and be sure to select YES as your answer to "Are you a software developer" in order to create an account and get your app ID and API key.

## Running the code

1. Paste the agent and device code into your IDE. In the agent code, add your app ID and API key.
2. It's now time to enroll some faces! You have two options.

### Option 1: Enroll an image through your device and agent code.
1. At the bottom of the device code, comment out capture_loop() and uncomment enroll().
2. In your agent code, enter the subject's name as the value of subjectName.
2. When you are ready to take a picture of your face and enroll it, hit Build and Run. When your device connects and starts, it will immediately take a picture and attempt to enroll it. 

### Option 2: Enroll an image through a command line python script.
1. On the command line, run the python script kairos_upload.py with the filepath to the image the subject's name.

#### Example
```
C:\Users\Liam\CSE\ArduCAM>python kairos_upload.py liam.jpg Liam
```

#### Template
```
YOUR CMD_LINE PATH> python kairos_upload.py IMAGE_FILEPATH IMAGE_NAME
```

## Recognizing Faces

Once you've enrolled some images of a person's face (you can enroll multiple images of the same face to increase the likelihood of it being recognized), make sure capture_loop() is uncommented in the device code and run the code. The code will take RGB images in a loop and compare them to the previous image taken to see if something has come into frame. If it is determined that something entered the frame, a jpeg image will be taken and sent to the agent, which will pass the image on to kairos to be analyzed. If the image contains a recognized face, the agent will log the name of the recognized individual to the server.