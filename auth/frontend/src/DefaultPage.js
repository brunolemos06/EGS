import React from 'react';
import { Container, Row, Col, Button } from 'react-bootstrap';

function MyPage() {

    const GoogleLoginButton = () => {
        const handleLoginClick = () => {
          window.location.href = 'https://accounts.google.com/o/oauth2/v2/auth?redirect_uri=http://localhost:3000/login/callback/&prompt=consent&response_type=code&client_id=810039849362-pocpopo5cpne4p0iga8d3fjaes8m5r7c.apps.googleusercontent.com&scope=openid%20email%20profile&access_type=offline';
        };
      
        return (
          <button onClick={handleLoginClick}>Login with Google</button>
        );
    };

    const GitHubLoginButton = () => {
        const handleLoginClick = () => {
          window.location.href = 'https://github.com/login/oauth/authorize?client_id=61e17ec5a329b5e84b6e&redirect_uri=http://localhost:3000/login/callback/&scope=user:email';
        };
    
        return (
          <button onClick={handleLoginClick}>Login with GitHub</button>
        );
    };

    return (
        <Container fluid className="p-5 bg-light">
            <Row className="justify-content-center">
                <Col md={6}>
                    <h1 className="text-center mb-5">Welcome to RideMate Login!</h1>
                </Col>
            </Row>
            <Row className="justify-content-center mt-5">
                <Col md={4}>
                    <div className="card">
                        <GoogleLoginButton />
                    </div>
                </Col>
                <Col md={4}>
                    <div className="card">
                        <GitHubLoginButton />
                    </div>
                </Col>
            </Row>
        </Container>
    );
}

export default MyPage;

