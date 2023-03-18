import React from 'react';
import axios from 'axios';
import { GoogleLogin } from 'react-google-login';

function App() {
  const clientId = '810039849362-pocpopo5cpne4p0iga8d3fjaes8m5r7c.apps.googleusercontent.com';

  const onSuccess = (response) => {
    // Handle successful sign-in
    console.log('Google Sign-In successful:', response);

    // Send authorization code to your REST API
    const code = new URLSearchParams(response.code).get('code');
    axios.post('http://127.0.0.1:8000/auth/google/', { code : code })
      .then((response) => {
        console.log('Authorization code sent successfully:', response);
      })
      .catch((error) => {
        console.error('Error sending authorization code:', error);
      });
  };

  const onFailure = (error) => {
    // Handle failed sign-in
    console.log('Google Sign-In failed:', error);
  };

  return (
    <div>
      <GoogleLogin
        clientId={clientId}
        buttonText="Sign in with Google"
        onSuccess={onSuccess}
        onFailure={onFailure}
        cookiePolicy={'single_host_origin'}
      />
    </div>
  );
}

export default App;
