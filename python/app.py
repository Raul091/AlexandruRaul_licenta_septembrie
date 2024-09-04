from flask import Flask, request, jsonify
import subprocess
import os
import time
from pathlib import Path
from fer import FER
import matplotlib.pyplot as plt 
import numpy as np
import cv2
from tensorflow.keras.models import load_model

app = Flask(__name__)

emotion_model = load_model(r'C:\Users\araul\Desktop\emotion_model_Adam_learningRate_0001.h5')
    # Define emotion labels
emotion_labels = ['Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']

# Function to preprocess the image
def preprocess_image(image_file):
    img = cv2.imread(image_file)  # Read the image in color
    img = cv2.resize(img, (48, 48))   # Resize the image to match model input size
    img = img.astype('float32') / 255  # Normalize pixel values
    img = np.expand_dims(img, axis=0)   # Add batch dimension
    return img

# Function to predict emotions on the image
def predict_emotion(image_file):
    img = preprocess_image(image_file)
    emotion_probabilities = emotion_model.predict(img)
    predicted_emotion_index = np.argmax(emotion_probabilities)
    predicted_emotion_label = emotion_labels[predicted_emotion_index]
    return predicted_emotion_label, emotion_probabilities[0]
@app.route('/api', methods=['POST'])
def process_image():


    image_file = request.files['image']
    if image_file:
        # Save the image file to disk
        image_path = 'image.jpg'
        with open(image_path, 'wb') as f:
            image_file.save(f)

        predicted_emotion, emotion_probabilities = predict_emotion(image_path)

        # Display the image with predicted emotion
        img = cv2.imread(image_path)
        plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
        plt.axis('off')
        #emotion_data = dict(zip(emotion_labels, emotion_scores))
        #plt.show()

        emotion_data = {
            'predicted_emotion': predicted_emotion,
            'emotion_probabilities': {emotion_labels[i]: float(emotion_probabilities[i]) for i in range(len(emotion_labels))}
        }

        Path(image_path).unlink()
        return jsonify({'captured_emotions': emotion_data})

    # Return an error response if no image file is received
    return jsonify({'error': 'No image file received'})

if __name__ == '__main__':
    app.debug = True
    app.run(host='172.23.64.1')