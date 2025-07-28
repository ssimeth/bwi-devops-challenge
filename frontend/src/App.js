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
      maxWidth: '800px', 
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
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
        gap: '20px',
        marginBottom: '30px'
      }}>
        <div style={{ 
          backgroundColor: 'white', 
          padding: '20px', 
          borderRadius: '8px',
          boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ color: '#34495e', marginTop: '0' }}>🖥️ System Status</h3>
          <p><strong>Frontend:</strong> ✅ Running</p>
          <p><strong>Backend:</strong> {backendStatus === 'Connected' ? '✅' : '❌'} {backendStatus}</p>
          <p><strong>Database:</strong> ✅ Connected</p>
          <p><strong>Environment:</strong> {backendInfo?.environment || 'Production'}</p>
        </div>

        <div style={{ 
          backgroundColor: 'white', 
          padding: '20px', 
          borderRadius: '8px',
          boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ color: '#34495e', marginTop: '0' }}>🚀 DevOps Features</h3>
          <ul style={{ listStyle: 'none', padding: '0' }}>
            <li>✅ Kubernetes Deployment</li>
            <li>✅ Docker Containers</li>
            <li>✅ CI/CD Pipeline</li>
            <li>✅ Health Monitoring</li>
            <li>✅ Auto-Scaling</li>
            <li>✅ Security Policies</li>
          </ul>
        </div>

        <div style={{ 
          backgroundColor: 'white', 
          padding: '20px', 
          borderRadius: '8px',
          boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ color: '#34495e', marginTop: '0' }}>🗺️ Geo-Features</h3>
          <ul style={{ listStyle: 'none', padding: '0' }}>
            <li>🌍 Crisis Management</li>
            <li>📍 Geographic Information</li>
            <li>📊 Real-time Data</li>
            <li>🔄 Multi-Agency Collaboration</li>
            <li>📱 Mobile Response</li>
            <li>🛡️ Secure Communications</li>
          </ul>
        </div>
      </div>

      <div style={{ 
        backgroundColor: 'white', 
        padding: '20px', 
        borderRadius: '8px',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
        textAlign: 'center'
      }}>
        <h3 style={{ color: '#34495e', marginTop: '0' }}>📋 Backend Response</h3>
        {backendInfo ? (
          <pre style={{ 
            backgroundColor: '#ecf0f1', 
            padding: '15px', 
            borderRadius: '5px',
            textAlign: 'left',
            overflow: 'auto'
          }}>
            {JSON.stringify(backendInfo, null, 2)}
          </pre>
        ) : (
          <p style={{ color: '#7f8c8d' }}>No backend connection</p>
        )}
      </div>

      <footer style={{ 
        textAlign: 'center', 
        marginTop: '40px', 
        color: '#95a5a6',
        fontSize: '12px'
      }}>
        <p>BWI GmbH - Software Data Solutions & Analytics</p>
        <p>Infrastructure as Code • Container Orchestration • Cloud Native</p>
      </footer>
    </div>
  );
}

export default App;
