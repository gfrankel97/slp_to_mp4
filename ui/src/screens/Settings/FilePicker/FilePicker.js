import React from 'react';
import './FilePicker.css';
const { dialog } = window.require('electron').remote;

const openFolder = () => {
  const paths = dialog.showOpenDialog({
    properties: [
      'openDirectory',
      'treatPackageAsDirectory',
      'createDirectory',
    ],
  }) || [];

  // const folderPath = paths[0];
  console.log(paths);
  console.log(1);
}


const FilePicker = ({ title, description, onChange }) => {
  return (
    <div>
      <div class="title">{title}</div>
      <div class="description">{description}</div>

      <div className="file-wrapper">
        <input 
          type="text" 
          webkitdirectory="true"
          class="input"
          readOnly
          onChange={() => console.log(title)} 
        />
        <button className="button" onClick={openFolder}>
          boop
        </button>
      </div>
    </div>
  );
}

export default FilePicker;