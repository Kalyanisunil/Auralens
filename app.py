from flask import Flask, request, jsonify, redirect, url_for, render_template
from flask import Flask, request, jsonify, render_template
import firebase_admin
from firebase_admin import credentials, auth

# Initialize Flask application
app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate('auralens-1-c635c-firebase-adminsdk-lmtmx-ce43ecf40c.json')  # Replace with the path to your Firebase service account key
firebase_admin.initialize_app(cred)

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

# Route to serve the HTML form for registration
@app.route('/register', methods=['GET'])
def register_page():
    return render_template('register.html')

# Route for admin to register new users (Handles POST requests)
@app.route('/register', methods=['POST'])
def register_user():
    try:
        # Get data from the request
        data = request.form  # Get form data submitted via POST
        email = data.get('email')
        password = data.get('password')
        name = data.get('name')

        # Check if all required fields are provided
        if not email or not password or not name:
            return jsonify({'error': 'Missing required fields'}), 400

        # Create a new user with the provided details
        user = auth.create_user(
            email=email,
            password=password,
            display_name=name
        )
        # return redirect(url_for('dashboard'))
       
        return redirect(url_for('dashboard'))
   

    except Exception as e:
        return render_template('register.html', error=f'Error: {str(e)}')
@app.route('/users', methods=['GET'])
def list_users():
    try:
        # Fetch all users from Firebase
        users = auth.list_users().iterate_all()
        
        # Prepare a list of users to send to the HTML template
        user_list = []
        for user in users:
            user_list.append({
                'uid': user.uid,
                'email': user.email,
                'display_name': user.display_name
            })

        # Render the users.html template with the user list
        return render_template('users.html', users=user_list)

    except Exception as e:
        return f"An error occurred while fetching users: {str(e)}", 500

# Start the Flask application
if __name__ == '__main__':
    app.run(debug=True)
