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



if __name__ == "__main__":
    app.run(debug=True, port=8080)