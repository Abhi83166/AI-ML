import cv2
import os
import numpy as np
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
 
cascPath = os.path.dirname(
    cv2.__file__) + "/data/haarcascade_frontalface_alt2.xml"#path to the haarcascade xml file
faceCascade = cv2.CascadeClassifier(cascPath)#create a cascade classifier
model = load_model("model_v_.h5")#change the model name to the model saved previously
 
video_capture = cv2.VideoCapture(0)#Capture video from the webcam change the 0 to 1 for external camera
while True:
    # Capture frame-by-frame
    ret, frame = video_capture.read()#read the frame
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)#convert the frame to grayscale
    faces = faceCascade.detectMultiScale(gray,
                                         scaleFactor=1.1,
                                         minNeighbors=5,
                                         minSize=(60, 60),
                                         flags=cv2.CASCADE_SCALE_IMAGE)#detect the faces in the frame
    faces_list=[]#create a list to store the faces
    preds=[]#create a list to store the predictions
    for (x, y, w, h) in faces:#loop through the faces
        face_frame = frame[y:y+h,x:x+w]#extract the face
        face_frame = cv2.cvtColor(face_frame, cv2.COLOR_BGR2RGB)#convert the frame to RGB
        face_frame = cv2.resize(face_frame, (224, 224))#resize the frame to 224x224
        face_frame = img_to_array(face_frame)#convert the frame to an array
        face_frame = np.expand_dims(face_frame, axis=0)#expand the dimensions of the array
        face_frame =  preprocess_input(face_frame)#preprocess the frame
        faces_list.append(face_frame)3#append the frame to the list
        if len(faces_list)>0:#if there are faces in the list
            preds = model.predict(faces_list)#predict the face
        for pred in preds:#loop through the predictions
            (mask, withoutMask) = pred#extract the mask and without mask
        label = "Mask" if mask > withoutMask else "No Mask"#if the mask is greater than the without mask then the person wears a mask
        color = (0, 255, 0) if label == "Mask" else (0, 0, 255)#if the label is mask then the color is green else the color is red
        label = "{}: {:.2f}%".format(label, max(mask, withoutMask) * 100)#format the label
        cv2.putText(frame, label, (x, y- 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.45, color, 2)
 
        cv2.rectangle(frame, (x, y), (x + w, y + h),color, 2)
        # Display the resulting frame
    cv2.imshow('Video', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
video_capture.release()
cv2.destroyAllWindows()
