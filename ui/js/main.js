const { app, BrowserWindow, ipcMain } = require('electron')
const exec = require('child_process').exec;

let win
let settings_win

function createWindow () {
    win = new BrowserWindow({
        width: 1400,
        height: 600,
        webPreferences: {
            nodeIntegration: true
        }
    })
    
    win.loadFile('../html/index.html')
    
    win.webContents.openDevTools()
    
    win.on('closed', () => {
        win = null
    })
}

function createSettingsWindow() {
    settings_win = new BrowserWindow({
        width: 1400,
        height: 600,
        webPreferences: {
            nodeIntegration: true
        }
    })

    
    settings_win.loadFile('../html/settings.html')
    
    settings_win.webContents.openDevTools()


    settings_win.on('closed', () => {
        settings_win = null
    })
}

app.on('ready', createWindow)

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit()
    }
})

app.on('activate', () => {
    if (win === null) {
        createWindow()
    }
})

ipcMain.on('settingsClicked', function() {
    if(!settings_win) {
        createSettingsWindow();
    }
});

ipcMain.on('startClicked', function() {
    exec("cd ../script && bash slp_to_mp4.sh", (error, stdout, stderr) => { 
        console.log("ERROR: ", error);
        console.log("STDOUT: ", stdout);
        console.log("STDERR: ", stderr);
    });
});
