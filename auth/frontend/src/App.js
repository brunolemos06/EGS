import React, { useState } from 'react';
import GoogleLogin from 'react-google-login';

const App = () => {
  const [loggedIn, setLoggedIn] = useState(false);

  const responseGoogle = (response) => {
    // send the response.tokenId to your REST API for verification and authentication
    fetch('/api/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ token: response.tokenId }),
    })
      .then((response) => response.json())
      .then((data) => {
        localStorage.setItem('token', data.token);
        setLoggedIn(true);
      });
  };

  return (
    <div>
      {!loggedIn && (
        <GoogleLogin
          clientId="YOUR_CLIENT_ID"
          buttonText="Login with Google"
          onSuccess={responseGoogle}
          onFailure={responseGoogle}
          cookiePolicy={'single_host_origin'}
        />
      )}
      {loggedIn && <p>You are logged in!</p>}
    </div>
  );
};

export default App;