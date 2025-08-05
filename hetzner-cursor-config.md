# 🎯 Cursor Editor Configuration for Hetzner DevOps

This guide helps you configure Cursor editor for seamless remote development on your Hetzner server (5.78.70.68).

## 📋 Prerequisites

- [Cursor Editor](https://cursor.sh) installed on your local machine
- SSH access to your Hetzner server
- DevOps user created on the server

## 🔧 SSH Configuration

### 1. Create SSH Config File

Create or edit `~/.ssh/config` on your local machine:

```ssh-config
# Hetzner DevOps Server
Host hetzner-devops
    HostName 5.78.70.68
    User devopsuser
    IdentityFile ~/.ssh/id_ed25519
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    
# Alternative connection (if using custom port)
Host hetzner-devops-alt
    HostName 5.78.70.68
    User devopsuser
    IdentityFile ~/.ssh/id_ed25519
    Port 2222
    ServerAliveInterval 60
```

### 2. Test SSH Connection

```bash
# Test connection
ssh hetzner-devops

# Should connect without password
```

## 🚀 Cursor Remote Development Setup

### 1. Install Remote - SSH Extension

1. Open Cursor
2. Go to Extensions (`Ctrl+Shift+X`)
3. Search for "Remote - SSH"
4. Install the extension by Microsoft
5. Restart Cursor if prompted

### 2. Connect to Hetzner Server

1. Press `Ctrl+Shift+P` to open Command Palette
2. Type "Remote-SSH: Connect to Host"
3. Select "hetzner-devops" from the list
4. Cursor will install VS Code Server on your Hetzner machine
5. Once connected, you'll see "SSH: hetzner-devops" in the status bar

### 3. Open Project Folder

1. In Cursor: File > Open Folder
2. Navigate to `/home/devopsuser/projects`
3. Select the folder you want to work on

## 📁 Recommended Folder Structure

```
/home/devopsuser/
├── projects/
│   ├── web/                 # Web applications
│   ├── api/                 # API services
│   ├── microservices/       # Microservice projects
│   ├── mobile/              # Mobile app projects
│   └── sample-app/          # Sample Node.js app
├── scripts/                 # Utility scripts
│   └── server-status.sh     # Server status checker
├── tools/                   # Development tools
└── workspace/               # Temporary workspace
```

## ⚙️ Cursor Workspace Settings

### 1. Create Workspace Settings

Create `.vscode/settings.json` in your project root:

```json
{
    "terminal.integrated.shell.linux": "/bin/bash",
    "terminal.integrated.cwd": "${workspaceFolder}",
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/dist/**": true,
        "**/build/**": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true,
        "**/.git": true,
        "**/dist": true,
        "**/build": true
    },
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "eslint.workingDirectories": ["./"],
    "docker.enableDockerComposeLanguageService": true,
    "docker.compose.files": [
        "docker-compose.yml",
        "docker-compose.yaml"
    ]
}
```

### 2. Recommended Extensions for Remote Development

Install these extensions in the remote session:

#### Essential Extensions
- **Docker** - Docker support
- **GitLens** - Git supercharged
- **Thunder Client** - API testing
- **Auto Rename Tag** - HTML/XML tag renaming
- **Bracket Pair Colorizer** - Bracket highlighting
- **indent-rainbow** - Indentation visualization

#### Language-Specific Extensions
- **JavaScript/TypeScript**: ESLint, Prettier
- **Python**: Python, Pylance
- **Go**: Go
- **PHP**: PHP IntelliSense
- **Java**: Extension Pack for Java

#### DevOps Extensions
- **YAML** - YAML language support
- **Kubernetes** - Kubernetes support
- **Terraform** - Terraform syntax highlighting
- **SSH FS** - SSH filesystem support

### 3. Create Launch Configuration

Create `.vscode/launch.json` for debugging:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Node.js App",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/app.js",
            "env": {
                "NODE_ENV": "development"
            },
            "console": "integratedTerminal",
            "restart": true,
            "runtimeExecutable": "nodemon"
        },
        {
            "name": "Attach to Docker",
            "type": "node",
            "request": "attach",
            "port": 9229,
            "address": "localhost",
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/app",
            "protocol": "inspector"
        }
    ]
}
```

### 4. Create Tasks Configuration

Create `.vscode/tasks.json` for common tasks:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "npm: install",
            "type": "shell",
            "command": "npm install",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        },
        {
            "label": "npm: start",
            "type": "shell",
            "command": "npm start",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        },
        {
            "label": "docker: build",
            "type": "shell",
            "command": "docker build -t ${workspaceFolderBasename} .",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        },
        {
            "label": "docker: run",
            "type": "shell",
            "command": "docker run -p 3000:3000 ${workspaceFolderBasename}",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        },
        {
            "label": "docker-compose: up",
            "type": "shell",
            "command": "docker compose up -d",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            }
        }
    ]
}
```

## 🔧 Useful Cursor Features for Remote Development

### 1. Integrated Terminal

- Press `Ctrl+\`` to open terminal
- Multiple terminals: Click the `+` button
- Split terminals: Click split button
- Terminal tabs: Right-click for options

### 2. Port Forwarding

Cursor automatically forwards common ports. For custom ports:

1. Press `Ctrl+Shift+P`
2. Type "Remote-SSH: Forward Port from Remote"
3. Enter port number (e.g., 3000)
4. Access via `http://localhost:3000`

### 3. File Synchronization

- Auto-save: Files are automatically synced
- Manual save: `Ctrl+S`
- Save all: `Ctrl+K, S`

### 4. Git Integration

- Source Control panel: `Ctrl+Shift+G`
- Stage changes: Click `+` next to files
- Commit: Type message and press `Ctrl+Enter`
- Push/Pull: Use status bar Git actions

## 🚀 Quick Start Workflow

### 1. Connect and Open Project

```bash
# Local machine
cursor --remote ssh-remote+hetzner-devops /home/devopsuser/projects/sample-app
```

### 2. Development Workflow

1. **Edit Code**: Use Cursor's AI features for coding assistance
2. **Run Application**: Use integrated terminal or tasks
3. **Debug**: Set breakpoints and use debugging features
4. **Test**: Run tests in terminal or use testing extensions
5. **Deploy**: Use docker-compose or deployment scripts

### 3. Common Commands

```bash
# In Cursor terminal on remote server

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run with Docker
docker compose up -d

# Check application status
curl http://localhost:3000

# View logs
docker logs container_name
pm2 logs
```

## 🔍 Troubleshooting

### Connection Issues

```bash
# Test SSH connection
ssh -v hetzner-devops

# Check SSH agent
ssh-add -l

# Restart SSH agent
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519
```

### Performance Issues

1. **Exclude large directories** in workspace settings
2. **Disable unnecessary extensions** for remote
3. **Use .gitignore** to exclude build folders
4. **Increase server resources** if needed

### Extension Issues

1. **Install extensions in remote session**, not locally
2. **Some extensions may not work** in remote mode
3. **Check extension compatibility** with Remote-SSH

## 🎯 Best Practices

### 1. Security

- **Never store passwords** in code
- **Use environment variables** for secrets
- **Keep SSH keys secure**
- **Regularly update server**

### 2. Performance

- **Use .gitignore** effectively
- **Exclude unnecessary files** from search
- **Use Docker multi-stage builds**
- **Optimize container sizes**

### 3. Workflow

- **Use Git branches** for features
- **Commit frequently** with meaningful messages
- **Use Docker for consistency**
- **Automate deployments**

### 4. Monitoring

- **Check server resources** regularly
- **Monitor application logs**
- **Set up alerts** for issues
- **Use health checks**

## 📚 Additional Resources

- [Cursor Documentation](https://cursor.sh/docs)
- [Remote-SSH Documentation](https://code.visualstudio.com/docs/remote/ssh)
- [Docker Documentation](https://docs.docker.com/)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/)

---

## 🎉 You're Ready!

Your Cursor editor is now configured for seamless remote development on your Hetzner DevOps server. You can:

✅ **Edit code remotely** with full IDE features  
✅ **Debug applications** with breakpoints and inspection  
✅ **Manage containers** with Docker integration  
✅ **Deploy applications** with integrated terminal  
✅ **Monitor performance** with built-in tools  

**Happy coding!** 🚀