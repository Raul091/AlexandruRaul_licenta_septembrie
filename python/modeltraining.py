from operator import contains
import cv2
import numpy as np
import os
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
from tensorflow.keras.optimizers import Adam
from keras.utils import to_categorical
from sklearn.preprocessing import LabelEncoder

images = []
labels = []

dir_path = r'C:\Users\araul\Downloads\archive\train'
for foldername in os.listdir(dir_path):
    folder_path = os.path.join(dir_path, foldername)
    if os.path.isdir(folder_path):
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            image = cv2.imread(file_path)

            if 'happy' in foldername:
                label = "Happy"
            elif 'sad' in foldername:
                label = "Sad"
            elif 'neutral' in foldername:
                label = "Neutral"
            elif 'surprise' in foldername:
                label = "Surprise"
            elif 'fear' in foldername:
                label = "Fear"
            elif 'disgust' in foldername:
                label = "Disgust"
            elif 'angry' in foldername:
                label = "Angry"


            images.append(image)
            labels.append(label)

X_train = np.array(images)
y_train = np.array(labels)


# Define emotion labels
emotion_labels = ['Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']
num_emotions = len(emotion_labels)

# Define model architecture
model = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(48, 48, 3)),
    MaxPooling2D((2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Flatten(),
    Dense(128, activation='relu'),
    Dense(num_emotions, activation='softmax')
])

# Compile the model
model.compile(optimizer=Adam(learning_rate=0.0001),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# You need to preprocess X_train and y_train here if necessary
# For example, you might need to reshape X_train and one-hot encode y_train
len_sample = len(X_train)
print(len_sample)
# Convert string labels to numerical labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)

y_train_one_hot = to_categorical(y_train_encoded, num_classes=num_emotions)

# Train the model
model.fit(X_train, y_train_one_hot, epochs=20, batch_size=32, validation_split=0.2)

# Save the trained model
model.save('emotion_model_Adam_learningRate_0001.h5')