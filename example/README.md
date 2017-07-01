# ArduCAM OV2640 Example Code: Facial Recognition
This example code shows an application of the OV2640 ArduCAM. This application uses the Kairos Facial Recognition API to detect and recognize faces.

To run this code, you'll first need to set up an account on Kairos to get an app id and app key. You can do this at https://www.kairos.com/

Once you've got your app id and app key, you'll need to paste them into the agent code. 

Before you can start recognizing faces, you'll need to enroll them. You can either do this by running a provided Python script on the command line (probably easier) or by uncommenting the call to enroll in the device code and the agent code. If you do the former, you'll need to edit the python code and enter your image path, app id, and app key. If you do the latter, you'll need to enter your name as the parameter to enroll in the agent code. Enroll will run on the device once when the code executes, so be sure to be facing the camera when you run the code. 

Example of running command line script:

C:\Users\Liam\CSE\ArduCAM>python kairos_upload.py liam.jpg Liam

TEMPLATE: 

YOUR CMD LINE PATH>python kairos_upload.py <IMAGE NAME> <PERSON NAME>

Once you've enrolled some images of a person's face (you can enroll multiple images of the same face to increase the likelihood of it being recognized), make sure capture_loop() is uncommented in the device code and run the code. The code will take RGB images in a loop and compare them to the previous image taken to see if something has come into frame. If it is determined that something entered the frame, a jpeg image will be taken and sent to the agent, which will pass the image on to kairos to be analyzed. If the image contains a recognized face, the agent will log the name of the recognized individual.