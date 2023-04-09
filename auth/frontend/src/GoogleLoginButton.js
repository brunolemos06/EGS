import React from 'react';
import './GoogleLoginButton.css';
import googleLogo from './images/GoogleLogo.png';

function GoogleLoginButton() {
  function handleClick() {
     window.location.href = 'http://10.0.2.2:8080/service-review/v1/auth/google';
  }

  return ( 
    <button onClick={handleClick} className='GoogleLoginButton'>
      <img src={googleLogo} alt='Github'/>
      &nbsp;&nbsp;&nbsp;Login with Google
    </button>
  );
}

export default GoogleLoginButton;