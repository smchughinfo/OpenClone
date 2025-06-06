0. add color theme [unthrottled.doki-theme](https://marketplace.visualstudio.com/items?itemName=unthrottled.doki-theme)
1. https://code.visualstudio.com/api/get-started/your-first-extension
2. npm install --global yo generator-code
3. yo code

---

PS C:\Users\seanm\Desktop> yo code

     _-----_     ╭──────────────────────────╮
    |       |    │   Welcome to the Visual  │
    |--(o)--|    │   Studio Code Extension  │
   `---------´   │        generator!        │
    ( _´U`_ )    ╰──────────────────────────╯
    /___A___\   /
     |  ~  |     
   __'.___.'__   
 ´   `  |° ´ Y ` 

? What type of extension do you want to create? New Extension (JavaScript)
? What's the name of your extension? OpenClone-DevContainer-StatusBar
? What's the identifier of your extension? openclone-devcontainer-statusbar
? What's the description of your extension? adds information to satus bar
? Enable JavaScript type checking in 'jsconfig.json'? No
? Initialize a git repository? Yes
? Which package manager to use? (Use arrow keys)
❯ npm 
  yarn 
  pnpm 

---

go into the package.json and set "activationEvents": ["*"] so that vscode will run your extension when you start it.

---

1. npm install -g vsce
2. vsce package
3. it spits out a .vsix
4. open vscode, go to extensions, click the three dots, "Install From VSIX..."



