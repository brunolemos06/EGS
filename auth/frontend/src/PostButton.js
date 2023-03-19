import React, { useState } from 'react';
import axios from 'axios';

function PostButton() {
  const [isLoading, setIsLoading] = useState(false);

  const handleClick = async () => {
    setIsLoading(true);

    try {
      const response = await axios.post('http://127.0.0.1:8000/login/google/', {
        // add any data you want to send in the request body here
      });

      console.log(response.data); // handle the response data here
    } catch (error) {
      console.error(error); // handle any errors here
    }

    setIsLoading(false);
  };

  return (
    <button onClick={handleClick} disabled={isLoading}>
      {isLoading ? 'Loading...' : 'Post'}
    </button>
  );
}

export default PostButton;