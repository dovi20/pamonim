import React from 'react'
import './App.css'

function App() {
  return (
    <div className="app">
      <div className="coming-soon-container">
        <h1 className="main-title">Coming Soon</h1>
        <p className="subtitle">We're working hard to bring you something amazing</p>
        <div className="progress-bar">
          <div className="progress-fill"></div>
        </div>
        <p className="status">Under Construction</p>
        <div className="social-links">
          <a href="#" className="social-link">Twitter</a>
          <a href="#" className="social-link">GitHub</a>
          <a href="#" className="social-link">Email</a>
        </div>
      </div>
    </div>
  )
}

export default App