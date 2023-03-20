import React from 'react';
import './LogoutButton.css';

function LogoutButton() {
  function handleClick() {
    window.location.href = 'http://127.0.0.1:5000/logout';
  }

  return ( 
    <button onClick={handleClick} className='LogoutButton'>
      Logout
    </button>
  );
}

export default LogoutButton;