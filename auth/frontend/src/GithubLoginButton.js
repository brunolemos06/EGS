import React, { useState } from 'react';
import './GithubLoginButton.css';
import githubLogo from './images/GithubLogo.png';

function GithubLoginButton() {
  function handleClick() {
     window.location.href = 'http://10.0.2.2:8080/service-review/v1/auth/github';
  }

  return ( 
    <button onClick={handleClick} className='GithubLoginButton'>
      <img src={githubLogo} alt='Github'/>
      &nbsp;&nbsp;&nbsp;Login with GitHub
    </button>
  );
}

export default GithubLoginButton;