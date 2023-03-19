from django.http import JsonResponse
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt

from rest_framework.authtoken.models import Token
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.decorators import permission_classes, api_view, authentication_classes

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
        
        user['provider_id'] = user_data.get('id')
        user['provider'] = 'Google'
    elif provider == 'github':
        user_data, status_code = github_auth(request)
        
        if status_code >= 400:
            return JsonResponse(user_data, status=status_code) 
        
        user['provider_id'] = user_data.get('id')
        user['provider'] = 'Github'
    else:
        return JsonResponse({"error" : 'Invalid provider.'}, status=404)

    #if user_data has 40# or 50# error code, return error
    if status_code >= 400:
        return JsonResponse(user_data, status=status_code)

    #print(user_data)
    if User.objects.filter(provider_id=user['provider_id'], provider=user['provider']).exists():
        
        user = User.objects.get(provider_id=user['provider_id'], provider=user['provider'])
        user_json = user.get_info()
        user_json['token'] = Token.objects.get_or_create(user=user)[0].key
            
        return JsonResponse(user_json, status=200, safe=False)
    else:
        #create new user
        user = User.objects.create_user(provider_id=user['provider_id'], provider=user['provider'])
        user = user.get_info()
        user['token'] = Token.objects.get_or_create(user=user)[0].key
        return JsonResponse(json.dumps(user), status=201)
    

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    request.user.auth_token.delete()
    return JsonResponse({"message" : "logged out"}, status=200)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def info(request):
    user = request.user.get_info()
    if not user:
        return JsonResponse({"error" : "User not found"}, status=404)
    return JsonResponse(user, status=200, safe=False)
    
@csrf_exempt
@api_view(['POST'])
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
@api_view(['POST'])
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

    print(response.json())

    access_token = response.json().get('access_token')
    if not access_token:
        return {"error": 'Failed to obtain access token'}, 400
    
    user_response = requests.get(settings.GITHUB_API_URL + 'user', headers={'Authorization': f'token {access_token}'})

    print(user_response.json())
    
    if user_response.status_code != 200:
        return {"error": 'Failed to obtain user data'}, 400

    return user_response.json(), 200



@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request, provider):
    if provider == 'google':
        url = 'https://accounts.google.com/o/oauth2/v2/auth?client_id={}&redirect_uri={}&response_type=code&scope=email%20profile'.format(settings.GOOGLE_AUTH_CLIENT_ID, settings.GOOGLE_AUTH_REDIRECT_URI)
        response = requests.post(url)
        print("Status code: ", response.status_code)
        print("Headers:" , response.headers)
        print("Response: ", response.text)
    elif provider == 'github':
        pass
    else:
        return JsonResponse({"error" : 'Invalid provider.'}, status=404)
    







class TokenAuthentication(TokenAuthentication):
    TokenAuthentication.keyword = 'Bearer'