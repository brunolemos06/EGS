from django.shortcuts import render
from django.http import HttpResponse

from rest_framework.views import APIView

from payments.settings import CLIENT_ID, CLIENT_SECRET

import requests
import json
import base64


def PaypalToken(client_ID, client_Secret):

    url = "https://api-m.sandbox.paypal.com/v1/oauth2/token"
    data = {
                "client_id" : CLIENT_ID,
                "client_secret" : CLIENT_SECRET,
                "grant_type":"client_credentials"
            }
    headers = {
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic {0}".format(base64.b64encode((CLIENT_ID + ":" + CLIENT_SECRET).encode()).decode())
            }

    token = requests.post(url, data, headers=headers)
    #print(token.json())
    return token.json()['access_token']

#on request add reference_id, description, custom_id, soft_descriptor, amount: currency_code, value
class CreateOrderViewRemote(APIView):

    def get(self, request):
        token = PaypalToken(CLIENT_ID, CLIENT_SECRET)
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer '+token,
            'PayPal-Request-Id': request.data.get('pp_id')
        }
        json_data = {
            "intent": "CAPTURE",
            "purchase_units": [
                {
                "reference_id": request.data.get('reference_id'),
                "amount": {
                    "currency_code": "EUR",
                    "value": request.data.get('amount'),
                }
                }
            ],
            "payment_source": {
                "paypal": {
                "experience_context": {
                    "payment_method_preference": "IMMEDIATE_PAYMENT_REQUIRED",
                    "payment_method_selected": "PAYPAL",
                    "brand_name": "RideMate",
                    "landing_page": "LOGIN",
                    "user_action": "PAY_NOW",
                    "return_url": "https://example.com/returnUrl",  #change this later to the actual return url
                    "cancel_url": "https://example.com/cancelUrl"
                }
                }
            }
        }
        response = requests.post('https://api-m.sandbox.paypal.com/v2/checkout/orders', headers=headers, json=json_data)
        print(response.json())
        order_id = response.json()['id']
        linkForPayment = response.json()['links'][0]['href']
        return HttpResponse(linkForPayment)

class CaptureOrderView(APIView):
    #capture order aims to check whether the user has authorized payments.
    def get(self, request):
        token = PaypalToken(CLIENT_ID, CLIENT_SECRET) #request.data.get('token')   #the access token we used above for creating an order, or call the function for generating the token
        captureurl = request.data.get('url') + '/capture'   #see transaction status
        #print("CAPTURL: "+captureurl)
        headers = {"Content-Type": "application/json", "Authorization": "Bearer "+token, "PayPal-Request-Id": request.data.get('pp_id')}
        response = requests.post(captureurl, headers=headers)
        #print("RESPONSE:\n")
        print(response.json())
        return HttpResponse(response.json())