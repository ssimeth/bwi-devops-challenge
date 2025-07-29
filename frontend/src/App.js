import React, { useState, useEffect } from 'react';

function App() {
  const [backendStatus, setBackendStatus] = useState('Loading...');
  const [backendInfo, setBackendInfo] = useState(null);

  useEffect(() => {
    // Check backend status
    fetch('/api/status')
      .then(res => res.json())
      .then(data => {
        setBackendStatus('Connected');
        setBackendInfo(data);
      })
      .catch(() => {
        setBackendStatus('Disconnected');
      });
  }, []);

  return (
    <div style={{ 
      fontFamily: 'Arial, sans-serif', 
      maxWidth: '600px', 
      margin: '50px auto', 
      padding: '20px',
      backgroundColor: '#f5f5f5',
      borderRadius: '10px'
    }}>
      <header style={{ textAlign: 'center', marginBottom: '40px' }}>
        <h1 style={{ color: '#2c3e50', marginBottom: '10px' }}>
          🗺️ KVInfoSysBund
        </h1>
        <h2 style={{ color: '#7f8c8d', fontWeight: 'normal' }}>
          Geo-Informationssystem für Krisenbewältigung
        </h2>
        <p style={{ color: '#95a5a6', fontSize: '14px' }}>
          BWI DevOps Challenge - Deployment Demo
        </p>
      </header>

      <div style={{ 
        backgroundColor: 'white', 
        padding: '30px', 
        borderRadius: '8px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
        textAlign: 'center'
      }}>
        <h3 style={{ color: '#34495e', marginTop: '0', marginBottom: '20px' }}>🖥️ System Status</h3>
        <div style={{ display: 'flex', justifyContent: 'space-around', marginBottom: '20px' }}>
          <div>
            <strong>Frontend:</strong><br/>
            <span style={{ color: '#27ae60', fontSize: '18px' }}>✅ Running</span>
          </div>
          <div>
            <strong>Backend:</strong><br/>
            <span style={{ color: backendStatus === 'Connected' ? '#27ae60' : '#e74c3c', fontSize: '18px' }}>
              {backendStatus === 'Connected' ? '✅' : '❌'} {backendStatus}
            </span>
          </div>
          <div>
            <strong>Database:</strong><br/>
            <span style={{ color: '#27ae60', fontSize: '18px' }}>✅ Connected</span>
          </div>
        </div>
        
        {backendInfo && (
          <div style={{ marginTop: '20px' }}>
            <p><strong>Environment:</strong> {backendInfo.environment || 'Production'}</p>
            <p><strong>Version:</strong> {backendInfo.version || '1.0.0'}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
