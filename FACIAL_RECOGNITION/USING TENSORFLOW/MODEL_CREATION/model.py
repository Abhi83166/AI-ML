#header files
#install tensorflow and keras to use this code.
import os
from imutils import paths
import matplotlib.pyplot as plt
import numpy as np

from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import AveragePooling2D
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Input
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.preprocessing.image import load_img
from tensorflow.keras.utils import to_categorical
from sklearn.preprocessing import LabelBinarizer
from sklearn.model_selection import train_test_split

dataset_path = list(paths.list_images('#path to dataset')) #remove # abd add the path to the dataset
#variables to store the information from the dataset
data = []
labels = []

for imagePath in dataset_path: #loop through the dataset
	
	label = imagePath.split(os.path.sep)[-2]# extract the class label from the filename
	
	image = load_img(imagePath, target_size=(224, 224))# target_size is the size of the image that will be fed to the model
	image = img_to_array(image)#convert the image to an array
	image = preprocess_input(image)#preprocess the image
	data.append(image)#append the image array to the data list
	labels.append(label)#append the label to the labels list
# convert the data and labels to NumPy arrays
data = np.array(data, dtype="float32")#convert the data to a numpy array
labels = np.array(labels)#convert the labels to a numpy array
baseModel = MobileNetV2(weights="imagenet", include_top=False,#include_top=False excludes the top layer of the model
	input_shape=(224, 224, 3))#input_shape is the size of the image that will be fed to the model
headModel = baseModel.output#output of the base model
headModel = AveragePooling2D(pool_size=(7, 7))(headModel)#average pooling layer
headModel = Flatten(name="flatten")(headModel)#flatten layer
headModel = Dense(128, activation="relu")(headModel)#dense layer
headModel = Dropout(0.5)(headModel)#dropout layer
headModel = Dense(2, activation="softmax")(headModel)#dense layer
model = Model(inputs=baseModel.input, outputs=headModel)#create the model
for layer in baseModel.layers:#loop through the layers of the base model
	layer.trainable = False#set the layers to non-trainable
lb = LabelBinarizer()#create a label binarizer
labels = lb.fit_transform(labels)#fit the label binarizer and transform the labels
labels = to_categorical(labels)#convert the labels to a one-hot vector
# partition the data into training and testing splits using 80% of
# the data for training and the remaining 20% for testing
(trainX, testX, trainY, testY) = train_test_split(data, labels,
	test_size=0.20, stratify=labels, random_state=42)
# construct the training image generator for data augmentation
aug = ImageDataGenerator(
	rotation_range=20,
	zoom_range=0.15,
	width_shift_range=0.2,
	height_shift_range=0.2,
	shear_range=0.15,
	horizontal_flip=True,
	fill_mode="nearest")
INIT_LR = 1e-4
EPOCHS = 20 
BS = 32
print("[INFO] PLEASE WAIT WHILE THE MODEL IS TRAINING...")
opt = Adam(lr=INIT_LR, decay=INIT_LR / EPOCHS)
model.compile(loss="binary_crossentropy", optimizer=opt,
	metrics=["accuracy"])#compile the model
# train the head of the network
print("[INFO] PLEASE WAIT WHILE THE MODEL IS TRAINING...")
H = model.fit(#train the head of the network
	aug.flow(trainX, trainY, batch_size=BS),#flow the training data
	steps_per_epoch=len(trainX) // BS,#steps per epoch
	validation_data=(testX, testY),#validation data
	validation_steps=len(testX) // BS,#validation steps
	epochs=EPOCHS)#epochs
N = EPOCHS
plt.style.use("ggplot")
plt.figure()
plt.plot(np.arange(0, N), H.history["loss"], label="train_loss")#plot the training loss
plt.plot(np.arange(0, N), H.history["val_loss"], label="val_loss")#plot the validation loss
plt.plot(np.arange(0, N), H.history["accuracy"], label="train_acc")#plot the training accuracy
plt.plot(np.arange(0, N), H.history["val_accuracy"], label="val_acc")#plot the validation accuracy
plt.title("Training Loss and Accuracy")
plt.xlabel("Epoch #")
plt.ylabel("Loss/Accuracy")
plt.legend(loc="lower left")

#if you want to save the model and satisfy the requirements of the project
model.save('model_v_.h5')#save the model and change the version number to the version number of the model