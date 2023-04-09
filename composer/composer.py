# auth          -> port     =   5000
# review        -> port     =   5005
# mensagem      -> port     =   5010
# trip          -> port     =   5015
# payment       -> port     =   8000
# frontendauth  -> port     =   3000

# RIDE-MATE API -> port     =   8080

from flask import Flask, jsonify, request
from flask_restful import Api, Resource, reqparse
import datetime
import sqlite3
from flask_swagger_ui import get_swaggerui_blueprint
import requests
from flask import redirect
import json

# import file located in the same directory
from db_func import *


app = Flask(__name__)

ip = '127.0.0.1'
SWAGGER_URL = '/api/docs'   # URL for exposing Swagger UI (without trailing '/')
API_URL = '/static/swagger.yml'  # Our API url (can of course be a local resource)

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': "My App"
    }
)

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

api = Api(app)

new_user_args = reqparse.RequestParser()

appendurl = '/service-review/v1/'

@app.route('/')
def index():
    return 'Ridemate API',200

# -
# REVIEW
# -

@app.route(appendurl + 'review', methods=['GET', 'POST', 'DELETE', 'PUT'])
def get_all_reviews():
    url = f'http://{ip}:5005/api/v1/reviews'
    if (request.method == 'GET'):
        reviewid = request.args.get('reviewid')
        personid = request.args.get('personid')
        # get in http:{ip}:5005/api/v1/review?reviewid=1&personid=1
        if (reviewid == None and personid == None):
            response = requests.get(url)
        elif (reviewid == None and personid != None):
            params = {'personid': personid}
            response = requests.get(url, params=params)
        elif (personid == None and reviewid != None):
            params = {'reviewid': reviewid}
            response = requests.get(url, params=params)
        else:
            params = {'reviewid': reviewid, 'personid': personid}
            response = requests.get(url, params=params)
    elif (request.method == 'POST'):
        try:
            personid = request.form['personid']
            title = request.form['title']
            description = request.form['description']
            rating = request.form['rating']
        except:
            return jsonify({'error': 'personid, title, description, rating are required'}), 400

        data = {'personid': personid, 'title': title, 'description': description, 'rating': rating}
        response = requests.post(url, data=data)
        
    return response.json(), response.status_code


@app.route(appendurl+'/review/rating/', methods=['GET'])
def rating_reviews():
    if request.method == 'GET':
        url = f'http://{ip}:5005/api/v1/reviews/rating'
        personid = request.args.get('personid')
        if personid == None:
            response = requests.get(url)
        else:
            params = {'personid': personid}
            response = requests.get(url, params=params)

    return response.json(), response.status_code

# ------------------------------


@app.route(appendurl + 'auth/login', methods=['POST'])
def login():
    if request.method == 'POST':
        url = f'http://{ip}:5000/login'
        data = request.get_json()
        response = requests.post(url, json=data)
        if response.status_code == 202:
            # get token from response
            token = response.json()['token']
            # create a new header with the token
            headers = {
                "x-access-token": token,
                "Content-Type": "application/json"
            }
            # send the new header to the info endpoint
            url = f'http://{ip}:5000/info'
            response1 = requests.post(url, headers=headers)
            authid = response1.json()['id']
            email = response1.json()['email']
            print(authid)
            entry = get_entry(str(authid))
            if entry == None:
                url = f'http://{ip}:5010/new_user?identity={email}'
                response2 = requests.post(url)
                jsonresponse = response2.json()
                UID = jsonresponse['UID']
                print(UID)
                # random id for reviewid int
                reviewid = 0
                while(check_free_review_id(reviewid) == False):
                    reviewid += 1
                    print(reviewid)
                print(create_full_entry(str(authid), str(UID),reviewid,str(UID)))
                print("authid: " + str(authid) + " UID: " + str(UID) + " reviewid: " + str(reviewid))

            # print entry
            print(get_entry(str(authid)))
            

    return response.json(), response.status_code

@app.route(appendurl + 'auth/register', methods=['POST'])
def register():
    if request.method == 'POST':
        url = f'http://{ip}:5000/register'
        data = request.get_json()
        response = requests.post(url, json=data)
        print(data)
    return response.json(), response.status_code

@app.route(appendurl + 'auth/auth', methods=['POST'])
def auth():
    # get token from header
    if request.method == 'POST':
        url = f'http://{ip}:5000/auth'
        headers = request.headers
        response = requests.post(url, headers=headers)
        print(response.json())
    return response.json(), response.status_code
        

@app.route(appendurl + 'auth/info', methods=['POST'])
def info():
    # get token from header
    if request.method == 'POST':
        url = f'http://{ip}:5000/info'
        headers = request.headers
        response = requests.post(url, headers=headers)
        print(response.json())
    return response.json(), response.status_code

@app.route(appendurl + 'auth/github')
def github():
    url = f'http://10.0.2.2:5000/github'
    if request.method == 'GET':
        return redirect(url)

@app.route(appendurl + 'auth/fetchdata', methods=['POST'])
def fetchdata():
    # get authid from request from body
    
    authid = request.get_json()['auth_id']
    email = request.get_json()['email']
    print(authid)
    print(email)
    entry = get_entry(str(authid))
    try:
        if entry == None:
            url = f'http://{ip}:5010/new_user?identity={email}'
            response2 = requests.post(url)
            jsonresponse = response2.json()
            UID = jsonresponse['UID']
            print(UID)
            # random id for reviewid int
            reviewid = 0
            while(check_free_review_id(reviewid) == False):
                reviewid += 1
                print(reviewid)
            print(create_full_entry(str(authid), str(UID),reviewid,str(UID)))
            print("authid: " + str(authid) + " UID: " + str(UID) + " reviewid: " + str(reviewid))

        # print entry
        print(get_entry(str(authid)))
    except Exception as e:
        print(e)
        print("\n\n\n\nBIG ERROR\n\n\n\n")
        return {"authid": authid, "chat": "error", "reviewid": "error"}, 400
    # entry to json
    entry = get_entry(str(authid))
    print(entry)
    return jsonify({"authid": entry[0], "chat": entry[1], "reviewid": entry[2]}), 200

@app.route(appendurl + 'auth/google', methods=['GET'])
def google():
    url = f'http://{ip}:5000/google'
    if request.method == 'GET':
        response = requests.get(url)

    # response is a redirect to google like this:
    # https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=...
    # so we need to redirect to that url

    return redirect(response.url)

if __name__ == "__main__":
    app.run(debug=True, port=8080)