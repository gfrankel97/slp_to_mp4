import React from 'react';
import FilePicker from './FilePicker/FilePicker';
import './Settings.css';
import SlippiSettings from '../../settings/settings-display-info.json';

const renderSettings = settings => {
  return settings.map(setting => {
    const { name, displayName, description } = setting;
    return (
      <div key={name} className="file-picker">
        <FilePicker title={displayName} description={description}/>
      </div>
    );
  })
}

const Settings = () => {
  const { desktop_settings, converter_settings } = SlippiSettings;
  console.log(SlippiSettings);
  return (
    <div className="settings-page">
      <div className="header">Slippi Desktop App Settings</div>
      {renderSettings(desktop_settings)}
      <div className="header">Slp to MP4 Settings</div>
      {renderSettings(converter_settings)}
    </div>
  );
}

export default Settings;