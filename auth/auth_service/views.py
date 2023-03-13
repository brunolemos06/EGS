from django.http import JsonResponse
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login, logout

from rest_framework.authtoken.models import Token
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.decorators import permission_classes, api_view

from users.models import CustomUser as User

from urllib.parse import unquote

import requests
import json

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def auth(request, provider):
    user_data = None
    user = {}
    if provider == 'google':
        user_data, status_code = google_auth(request)

        if status_code >= 400:
            return JsonResponse(user_data, status=status_code) 
        
        user['uuid'] = user_data.get('id')
        user['email'] = user_data.get('email')
        user['first_name'] = user_data.get('given_name')
        user['last_name'] = user_data.get('family_name')
        user['provider'] = 'Google'
    elif provider == 'facebook':
        user_data, status_code = facebook_auth(request)

        # if status_code >= 400:
        #     return JsonResponse(user_data, status=status_code) 
        
        return JsonResponse({"error" : 'Facebook auth not implemented yet.'}, status=501)
    elif provider == 'github':
        user_data, status_code = github_auth(request)
        
        if status_code >= 400:
            return JsonResponse(user_data, status=status_code) 
        
        user['uuid'] = user_data.get('id')
        user['email'] = user_data.get('email')
        user['first_name'] = user_data.get('name').split(' ')[0]
        user['last_name'] = user_data.get('name').split(' ')[1]
        user['provider'] = 'Github'
    else:
        return JsonResponse({"error" : 'Invalid provider.'}, status=404)

    #if user_data has 40# or 50# error code, return error
    if status_code >= 400:
        return JsonResponse(user_data, status=status_code)

    if User.objects.filter(email=user['email']).exists():
        if User.objects.get(email=user['email']).provider == user['provider']:
            
            user = User.objects.get(email=user['email'])
            user_json = user.get_info()
            user_json['token'] = Token.objects.get_or_create(user=user)[0].key

            # if Token.objects.get(user=User.objects.get(email=user['email'])).exists():
            #     user['token'] = Token.objects.get(user=User.objects.get(email=user['email'])).key
            # else:
            #     user['token'] = Token.objects.create(user=User.objects.get(email=user['email'])).key
            
            return JsonResponse(user_json, status=200, safe=False)
        else :
            return JsonResponse({"error" : 'User already exists with this email on '+ User.objects.get(email=user['email']).get_provider+'}'}, status=401)
    else:
        #create new user
        user = User.objects.create_user(**user)
        token = Token.objects.create(user=user)
        user = user.get_info()
        user['token'] = token.key
        return JsonResponse(json.dumps(user), status=201)
    

@csrf_exempt
@permission_classes([IsAuthenticated])
@api_view(['POST'])
def logout(request):
    request.user.auth_token.delete()
    return JsonResponse({"message" : "logged out"}, status=200)

@csrf_exempt
@permission_classes([IsAuthenticated])
@api_view(['POST'])
def info(request):
    user = request.user.get_info()
    if not user:
        return JsonResponse({"error" : "User not found"}, status=404)
    return JsonResponse(user, status=200, safe=False)
    
    
@csrf_exempt
@permission_classes([AllowAny])
def google_auth(request):
    code = json.loads(request.body).get('code')
    code = unquote(code)
    if not code:
        return {'error': 'No code provided'}, 404

    # exchange authorization code for access token
    data = {
        'code': code,
        'client_id': settings.GOOGLE_AUTH_CLIENT_ID,
        'client_secret': settings.GOOGLE_AUTH_CLIENT_SECRET,
        'redirect_uri': settings.GOOGLE_AUTH_REDIRECT_URI,
        'grant_type': 'authorization_code',
    }

    response = requests.post('https://oauth2.googleapis.com/token', data=data)
    token_data = json.loads(response.text)
    access_token = token_data.get('access_token')
    if not access_token:
        return {'error': 'Failed to obtain access token'}, 400

    # use access token to get user info
    response = requests.get('https://www.googleapis.com/oauth2/v2/userinfo',
                            headers={'Authorization': f'Bearer {access_token}'})
    
    if response.status_code != 200:
        return {'error': 'Failed to obtain user info'}, 400

    return json.loads(response.text), 200

@csrf_exempt
@permission_classes([AllowAny])
def facebook_auth(request):
    # get authorization code from Facebook
    code = json.loads(request.body).get('code')
    if not code:
        return {'error': 'No code provided.'}, 404

    # exchange authorization code for access token
    data = {
        'code': code,
        'client_id': settings.FACEBOOK_AUTH_CLIENT_ID,
        'client_secret': settings.FACEBOOK_AUTH_CLIENT_SECRET,
        'redirect_uri': settings.FACEBOOK_AUTH_REDIRECT_URI,
        'grant_type': 'authorization_code',
    }
    response = requests.get('https://graph.facebook.com/v16.0/oauth/access_token', params=data)
    token_data = json.loads(response.text)
    access_token = token_data.get('access_token')
    if not access_token:
        return {"error": 'Failed to obtain access token'}, 400

    # use access token to get user info
    response = requests.get('https://graph.facebook.com/v16.0/me?fields=id%2Cname',
                            params={'access_token': access_token})
    user_data = json.loads(response.text)
    # do something with user_data, e.g. create a user

    return user_data, 200

@csrf_exempt
@permission_classes([AllowAny])
def github_auth(request):
    code = json.loads(request.body).get('code')
    
    if not code:
        return {"error": 'No code provided'}, 404
    
    data = {
        'client_id': settings.GITHUB_CLIENT_ID,
        'client_secret': settings.GITHUB_CLIENT_SECRET,
        'code': code,
    }
    headers = {'Accept': 'application/json'}
    response = requests.post(settings.GITHUB_ACCESS_TOKEN_URL, data=data, headers=headers)
    
    access_token = response.json().get('access_token')
    if not access_token:
        return {"error": 'Failed to obtain access token'}, 400
    
    user_response = requests.get(settings.GITHUB_API_URL + 'user', headers={'Authorization': f'token {access_token}'})
    
    if user_response.status_code != 200:
        return {"error": 'Failed to obtain user data'}, 400
    
    print(user_response.json())

    return user_response.json(), 200

class TokenAuthentication(TokenAuthentication):
    TokenAuthentication.keyword = 'Bearer'