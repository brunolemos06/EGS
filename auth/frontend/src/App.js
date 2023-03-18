import React from 'react';
import axios from 'axios';

function App() {
  const onSuccess = (response) => {
    // Handle successful sign-in
    console.log('Google Sign-In successful:', response);

    // Send authorization code to your REST API

    axios.post('http://127.0.0.1:8000/login/google/')
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
      {/* button that post on     axios.post('http://127.0.0.1:8000/login/google/') */}
      <button onClick={onSuccess}>Login with Google</button>
    </div>
  );
}

export default App;
