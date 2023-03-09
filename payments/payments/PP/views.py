from django.shortcuts import render
from django.http import HttpResponse

from rest_framework.views import APIView
from rest_framework import serializers 

from .models import ongoing_payment, completed_payment
from .serializers import ongoing_paymentSerializer, completed_paymentSerializer

from payments.settings import CLIENT_ID, CLIENT_SECRET

import requests
import json
import base64
import random
import string


def PaypalToken(client_ID, client_Secret):

    url = "https://api-m.sandbox.paypal.com/v1/oauth2/token"
    data = {
                "client_id" : client_ID,
                "client_secret" : client_Secret,
                "grant_type":"client_credentials"
            }
    headers = {
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic {0}".format(base64.b64encode((CLIENT_ID + ":" + CLIENT_SECRET).encode()).decode())
            }

    token = requests.post(url, data, headers=headers)
    print(token.json())
    return token.json()['access_token']

#on request add reference_id, description, custom_id, soft_descriptor, amount: currency_code, value
class CreateOrderViewRemote(APIView):

    def post(self, request):
        token = PaypalToken(CLIENT_ID, CLIENT_SECRET)
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer '+token,
            'PayPal-Request-Id': ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k=random.randint(1, 36)))
        }

        json_data = {
            "intent": "CAPTURE",
            "purchase_units": [
                {
                "reference_id": ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k=random.randint(1, 265))),
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
        #print(response.json())
        try:
            order_id = response.json()['id']
            linkForPayment = response.json()['links'][1]['href']
            #create a new entry in the ongoing_payments table
            ongoing = ongoing_paymentSerializer(data={'order_id': order_id, 'pp_id': headers['PayPal-Request-Id'], 'ref_id': json_data['purchase_units'][0]['reference_id'], 'amount': json_data['purchase_units'][0]['amount']['value']})
            if ongoing.is_valid():
                ongoing.save()
            else:
                return HttpResponse(json.dumps({'error': 'something went wrong with ongoing order creation'}), status=422)
        except:
            return HttpResponse(json.dumps({'error': 'something went wrong with order creation'}), status=400)
        
        return HttpResponse(json.dumps({'order_id': order_id, 'linkForPayment': linkForPayment}), status=201)

class CaptureOrderView(APIView):
    #capture order aims to check whether the user has authorized payments.
    def post(self, request):
        #check if the order_id exists in ongoing_payments table
        if ongoing_payment.objects.filter(order_id=request.data.get('order_id')).exists():
            token = PaypalToken(CLIENT_ID, CLIENT_SECRET)   #the access token we used above for creating an order, or call the function for generating the token
            ongoing = ongoing_payment.objects.get(order_id=request.data.get('order_id'))
            captureurl = 'https://api.sandbox.paypal.com/v2/checkout/orders/' + request.data.get('order_id') + '/capture'   #see transaction status
            headers = {"Content-Type": "application/json", "Authorization": "Bearer "+token, "PayPal-Request-Id": ongoing.pp_id, "Prefer": "return=representation"}
            response = requests.post(captureurl, headers=headers)

        else:
            return HttpResponse(json.dumps({'error': 'the order doesn\'t exist'}), status=400)

        print(response.json())

        #check if key 'status' exists in the response
        if 'status' in response.json() and response.json()['status'] == 'COMPLETED':

            print('order_id: ', response.json()['id'])
            print('reference_id: ', response.json()['purchase_units'][0]['reference_id'])
            print('amount: ', response.json()['purchase_units'][0]['amount']['value'])
            
            if ongoing_payment.objects.filter(order_id=response.json()['id'], ref_id=response.json()['purchase_units'][0]['reference_id'], amount=response.json()['purchase_units'][0]['amount']['value']).exists():
                #delete the entry from ongoing_payments table
                ongoing_payment.objects.filter(order_id=response.json()['id'], ref_id=response.json()['purchase_units'][0]['reference_id'], amount=response.json()['purchase_units'][0]['amount']['value']).delete()
                #create a new entry in the completed_payments table
                completed = completed_paymentSerializer(data={
                    'email': response.json()['payer']['email_address'],
                    'payer_id': response.json()['payer']['payer_id'],
                    'payer_fname': response.json()['payer']['name']['given_name'],
                    'payer_lname': response.json()['payer']['name']['surname'],
                    'payer_email': response.json()['payer']['email_address'],
                    'amount': response.json()['purchase_units'][0]['amount']['value'],
                    'created_at': response.json()['create_time'],
                    'updated_at': response.json()['update_time']
                })

                if completed.is_valid():
                    completed.save()
                    return HttpResponse(json.dumps({'status': 'success'}), status=201)
                else:
                    print(completed.errors)
                    return HttpResponse(json.dumps({'error': 'something went wrong with completed order creation'}), status=422)
                            
            else:
                return HttpResponse(json.dumps({'error': 'the order doesn\'t exist'}), status=400)
        
        else:
            return HttpResponse(json.dumps({'error': 'something went wrong with order capture'}), status=400)
