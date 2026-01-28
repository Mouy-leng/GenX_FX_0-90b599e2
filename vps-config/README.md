# VPS Configuration & Gitea Runner Setup

This directory contains configuration files and scripts for setting up a Gitea Actions runner (`act_runner`) for the GenX FX Trading Platform on a VPS.

## 🚀 Gitea Runner Setup

The runner connects to **forge.mql5.io** to execute Actions (CI/CD workflows).

### 🔑 Registration Token

Before running the setup scripts, ensure you have your Gitea runner registration token. You can find it in your repository settings on `forge.mql5.io`.

### 🐧 Linux (Ubuntu/Debian)

1.  Copy `setup_runner.sh` and `runner_config.yaml` to your VPS.
2.  Make the script executable: `chmod +x setup_runner.sh`
3.  Run the script: `./setup_runner.sh`
4.  Enter your registration token when prompted.
5.  Follow the instructions in the script output to enable the systemd service.

### 🪟 Windows

1.  Copy `setup_runner.ps1` and `runner_config.yaml` to your VPS.
2.  Open PowerShell as Administrator.
3.  Run the script: `.\setup_runner.ps1`
4.  Enter your registration token when prompted.
5.  To start the runner: `.\act_runner.exe daemon --config config.yaml`

## 📝 Configuration

The setup scripts will use `runner_config.yaml` as the base configuration. You can customize this file before running the scripts to change labels, capacity, or other settings.

## 📁 Dropbox Sync

If you are using Dropbox for configuration sync (e.g., at `C:\Users\USER\Dropbox\vps-config`), you can keep these files there to have them available across all your machines.

## 🛠️ Maintenance

To update the runner, simply download a newer version of the `act_runner` binary from the [official releases](https://gitea.com/gitea/act_runner/releases) and replace the existing one.
