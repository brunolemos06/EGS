import json, sqlite3

from flask import Flask, redirect, url_for, jsonify

#from flask_cors import CORS, cross_origin

from flask_login import (
    LoginManager,
    current_user,
    login_required,
    login_user,
    logout_user,
)

from authlib.integrations.flask_client import OAuth

# Project imports
from db import init_db_command
from user import User

app = Flask(__name__)

# Enable CORS
#CORS(app)

# Setup flask-login
login_manager = LoginManager()
login_manager.init_app(app)

# Authlib setup
oauth = OAuth(app)

#CONFIGS
with open('client_secret_google.json') as f:
    google_credentials = json.load(f)['web']

app.config['SECRET_KEY'] = "OH NO ANYWAYS"
app.config['GOOGLE_CLIENT_ID'] = google_credentials['client_id']
app.config['GOOGLE_CLIENT_SECRET'] = google_credentials['client_secret']
app.config['GITHUB_CLIENT_ID'] = "61e17ec5a329b5e84b6e"
app.config['GITHUB_CLIENT_SECRET'] = "da7a7cf6beb5c94ba5378f588a2f2162d8eb8453"

#DB setup
try:
    init_db_command()
except sqlite3.OperationalError:
    pass  # Assume it's already been created

google = oauth.register(
    name = 'google',
    client_id = app.config["GOOGLE_CLIENT_ID"],
    client_secret = app.config["GOOGLE_CLIENT_SECRET"],
    access_token_url = 'https://accounts.google.com/o/oauth2/token',
    access_token_params = None,
    authorize_url = 'https://accounts.google.com/o/oauth2/auth',
    authorize_params = None,
    api_base_url = 'https://www.googleapis.com/oauth2/v1/',
    userinfo_endpoint = 'https://openidconnect.googleapis.com/v1/userinfo', 
    client_kwargs = {'scope': 'email profile'},
    server_metadata_url=f'https://accounts.google.com/.well-known/openid-configuration'
)

github = oauth.register (
  name = 'github',
    client_id = app.config["GITHUB_CLIENT_ID"],
    client_secret = app.config["GITHUB_CLIENT_SECRET"],
    access_token_url = 'https://github.com/login/oauth/access_token',
    access_token_params = None,
    authorize_url = 'https://github.com/login/oauth/authorize',
    authorize_params = None,
    api_base_url = 'https://api.github.com/',
    client_kwargs = {'scope': 'user:email'},
)

@login_manager.user_loader
def load_user(user_id):
    return User.get(user_id)


# Default route
@app.route('/')
def home():
  return "root"

@app.route('/google')
#@cross_origin()
def google():
    return redirect('/login/google')

# Google login route
@app.route('/login/google')
#@cross_origin()
def google_login():
    google = oauth.create_client('google')
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)


# Google callback route
@app.route('/login/google/callback')
#@cross_origin()
def google_callback():
    google = oauth.create_client('google')
    token = google.authorize_access_token()
    resp = google.get('userinfo').json()

    print(resp)

    user = User(
        id_=str(resp['id']) + 'google',
        provider_id=str(resp['id']),
        provider='google'
    )

    if not User.get(resp['id'], 'google'):
        print("User not found, creating new user")
        user = User.create(str(resp['id'])+'google', resp['id'], 'google')
        user = User.get(resp['id'], 'google')

    login_user(user)

    return jsonify({'message': 'Logged in successfully'}), 200

@app.route('/github')
#@cross_origin()
def github():
    return redirect('/login/github')

# Github login route
@app.route('/login/github')
#@cross_origin()
def github_login():
    github = oauth.create_client('github')
    redirect_uri = url_for('github_callback', _external=True)
    return github.authorize_redirect(redirect_uri)


# Github callback route
@app.route('/login/github/callback')
#@cross_origin()
def github_callback():
    github = oauth.create_client('github')
    token = github.authorize_access_token()
    resp = github.get('/user').json()
    
    # print(f"\n{resp}\n")

    user = User(
        id_=str(resp['id']) + 'github',
        provider_id=str(resp['id']),
        provider='github'
    )

    if not User.get(resp['id'], 'github'):
        print("User not found, creating new user")
        user = User.create(str(resp['id'])+'github', resp['id'], 'github')
        user = User.get(resp['id'], 'github')

    login_user(user)

    return "You are successfully logged in", 200

@app.route('/logout')
#@cross_origin()
@login_required
def logout():
   logout_user()
   return "You are successfully logged out", 200


if __name__ == '__main__':
  app.run(debug=True)