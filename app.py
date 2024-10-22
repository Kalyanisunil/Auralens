from flask import Flask, request, jsonify
import numpy as np
import cv2
import tensorflow as tf

app = Flask(__name__)

# Load the Keras model
model = tf.keras.models.load_model("currency_recognition_model.h5")


def preprocess_image(image):
    image = cv2.resize(image, (224, 224))  # Resize to model input size
    image = image / 255.0  # Normalize to [0, 1]
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    return image


@app.route('/recognize', methods=['POST'])
def recognize_currency():
    file = request.files['image']
    img = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)

    input_data = preprocess_image(img)
    predictions = model.predict(input_data)
    predicted_class = int(np.argmax(predictions[0]))

    return jsonify({'predicted_class': predicted_class})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
