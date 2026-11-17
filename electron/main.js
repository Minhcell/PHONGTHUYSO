const { app, BrowserWindow, Menu, shell } = require("electron");
const path = require("path");
function createWindow(){
  const win = new BrowserWindow({
    width: 1200, height: 860, minWidth: 380, minHeight: 600,
    title: "Phong Thủy Số – Tra & Luận Số",
    icon: path.join(__dirname, "app", "icon.png"),
    autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, nodeIntegration: false, spellcheck: false }
  });
  Menu.setApplicationMenu(null);
  win.loadFile(path.join(__dirname, "app", "index.html"));
  // liên kết ngoài mở bằng trình duyệt mặc định
  win.webContents.setWindowOpenHandler(({ url }) => { if (/^https?:/i.test(url)) shell.openExternal(url); return { action: "deny" }; });
}
app.whenReady().then(createWindow);
app.on("window-all-closed", () => app.quit());
