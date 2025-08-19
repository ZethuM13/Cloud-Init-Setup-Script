# Cloud-Init-Setup-Script
This script shows practical experience in:  1. Automating environment setups 2. Integrating Python with cloud tools 3. Writing maintainable, production-ready scripts 4. Using GitHub as a portfolio of technical skills
# Cloud-Init Setup Script

## Overview
This script automates the setup of a complete Python development environment on Oracle Linux 8 (OL8) for **data science and Oracle Cloud Infrastructure (OCI) projects**.  
It is designed to run **once** per instance and prepares the system for immediate use.

**Features:**
- Installs the latest **SQLite** from source
- Installs **Python 3.11.9** via **pyenv**
- Installs essential Python packages for data science and cloud automation:
  - `numpy`, `pandas`, `scikit-learn`, `seaborn`, `ipywidgets`, `oci`
- Installs **JupyterLab** for interactive Python development
- Installs the **OCI CLI** for Oracle Cloud resource management
- Pulls the `labs` folder from a GitHub repository into the local project directory

---

## Prerequisites
- Oracle Linux 8 or compatible Linux system
- `sudo` privileges
- Internet connection

---

## Usage

1. **Clone this repository:**
```bash
git clone https://github.com/<your-username>/cloud-init-scripts.git
cd cloud-init-scripts
