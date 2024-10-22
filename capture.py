import cv2
import requests

def capture_image():
    cap = cv2.VideoCapture(0)  # Use the default camera
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        cv2.imshow('Camera', frame)

        # Press 'c' to capture an image
        if cv2.waitKey(1) & 0xFF == ord('c'):
            _, buffer = cv2.imencode('.jpg', frame)
            files = {'image': buffer.tobytes()}
            response = requests.post('http://127.0.0.1:5000/recognize', files=files)
            if response.status_code == 200:
                print('Predicted class:', response.json().get('predicted_class'))
            else:
                print('Failed to recognize currency.')

        # Press 'q' to quit
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    capture_image()
