import React, { Component } from 'react';
import GoogleLogin from 'react-google-login';

class GoogleSocialAuth extends Component {

  render() {
    const googleResponse = (response) => {
      console.log(response);
    }
    return (
      <div className="App">
        <h1>LOGIN WITH GOOGLE</h1>
      
        <GoogleLogin
          clientId="810039849362-pocpopo5cpne4p0iga8d3fjaes8m5r7c.apps.googleusercontent.com"
          redirectUri='http://localhost:3000/login/callback/'
          buttonText="LOGIN WITH GOOGLE"
          onSuccess={googleResponse}
          onFailure={googleResponse}
        />
      </div>
    );
  }
}

export default GoogleSocialAuth;