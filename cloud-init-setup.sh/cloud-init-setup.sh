#!/bin/bash
# ====================================================
# Local Dev Setup Script (Ubuntu/WSL Version)
# Description:
#   Sets up a development environment with:
#     - Latest SQLite
#     - Python 3.11.9 via pyenv
#     - Data science Python packages
#     - JupyterLab
#     - OCI CLI
#     - Pulls a specific folder from GitHub
# ====================================================

LOGFILE="$HOME/cloud-init-output.log"
exec > >(tee -a "$LOGFILE") 2>&1

MARKER_FILE="$HOME/.init_done"
if [ -f "$MARKER_FILE" ]; then
  echo "Init script has already been run. Exiting."
  exit 0
fi

echo "===== Starting Local Setup Script ====="

# -------------------------
# System packages
# -------------------------
echo "Installing required system packages..."
sudo apt-get update
sudo apt-get install -y git libffi-dev build-essential \
    libbz2-dev libncurses5-dev libncursesw5-dev \
    libreadline-dev wget make gcc zlib1g-dev \
    libssl-dev curl xz-utils tk-dev

# -------------------------
# Install latest SQLite
# -------------------------
echo "Installing latest SQLite..."
cd /tmp || exit
wget https://www.sqlite.org/2023/sqlite-autoconf-3430000.tar.gz
tar -xvzf sqlite-autoconf-3430000.tar.gz
cd sqlite-autoconf-3430000 || exit
./configure --prefix=/usr/local
make
sudo make install

# Update environment
export PATH="/usr/local/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
echo 'export PATH="/usr/local/bin:$PATH"' >> "$HOME/.bashrc"
echo 'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"' >> "$HOME/.bashrc"

source "$HOME/.bashrc"

# -------------------------
# Install pyenv and Python
# -------------------------
echo "Installing pyenv and Python 3.11.9..."
export PYENV_ROOT="$HOME/.pyenv"
curl https://pyenv.run | bash

cat << 'EOF' >> "$HOME/.bashrc"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

cat << 'EOF' >> "$HOME/.bash_profile"
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF

source "$HOME/.bashrc"
export PATH="$PYENV_ROOT/bin:$PATH"

CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" \
LD_LIBRARY_PATH="/usr/local/lib" pyenv install 3.11.9
pyenv rehash

PROJECT_DIR="$HOME/labs"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit
pyenv local 3.11.9
pyenv rehash

python --version

# -------------------------
# Install Python packages
# -------------------------
pip install --upgrade pip
pip install --no-cache-dir \
    oci==2.129.1 scikit-learn==1.3.0 seaborn==0.13.2 \
    pandas==2.2.2 numpy==1.26.4 ipywidgets==8.1.2 jupyterlab

# -------------------------
# Install OCI CLI
# -------------------------
echo "Installing OCI CLI..."
curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o install.sh
chmod +x install.sh
./install.sh --accept-all-defaults
echo 'export PATH=$PATH:$HOME/.local/bin' >> "$HOME/.bashrc"
source "$HOME/.bashrc"

# -------------------------
# Git sparse checkout for labs folder
# -------------------------
echo "Pulling 'labs' folder from GitHub..."
REPO_URL="https://github.com/ou-developers/ou-ai-foundations.git"

git init
git remote add origin "$REPO_URL"
git config core.sparseCheckout true
echo "labs/*" >> .git/info/sparse-checkout
git pull origin main
mv labs/* . 2>/dev/null || true
rm -rf .git labs

echo "Files successfully downloaded to $PROJECT_DIR"

# -------------------------
# Marker file
# -------------------------
touch "$MARKER_FILE"
echo "===== Local Setup Completed Successfully ====="
exit 0

