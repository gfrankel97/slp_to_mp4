import React, { useState } from 'react';
import './App.css';
import Settings from './screens/Settings/Settings';
import VideoConverter from './screens/VideoConverter/VideoConvert';

const renderSection = showSettings => {
  console.log('hit');
  return showSettings ? <Settings /> : <VideoConverter />;
}

const App = () => {
  const [showSettings, changeShowSettings] = useState(true);
  const swapScene = () => changeShowSettings(!showSettings);
  const buttonText = showSettings ? 'Back' : 'Settings';

  return (
    <div className="app">
      <div className="app-wrapper">
        <div className="app-header">
          Slippi to MP4 Converter
          <div className="settings" onClick={swapScene}>
            {buttonText}
          </div>
        </div>
        <div className="section-wrapper">
          {renderSection(showSettings)}
        </div>
      </div>
    </div>
  );
}

export default App;
