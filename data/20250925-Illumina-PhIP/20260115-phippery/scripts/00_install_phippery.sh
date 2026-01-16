#!/bin/bash

#	This won't run on the cluster as the nodes do not have outside access.
#SBATCH --job-name=install_phippery
#SBATCH --output=logs/install_phippery_%j.out
#SBATCH --error=logs/install_phippery_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

# ==============================================================================
# Phippery Installation Script
# ==============================================================================
# This script sets up the phippery environment for PhIPSeq analysis
# Run once before using the pipeline
# ==============================================================================

set -euo pipefail

# Create log directory
mkdir -p logs

echo "======================================================================"
echo "Installing Phippery Pipeline Environment"
echo "Date: $(date)"
echo "======================================================================"

# ==============================================================================
# Option 1: Using Singularity Container (RECOMMENDED for HPC)
# ==============================================================================

echo ""
echo "Setting up Singularity container..."
echo ""

# Create singularity cache directory
SINGULARITY_CACHEDIR="${HOME}/.singularity/cache"
mkdir -p "${SINGULARITY_CACHEDIR}"
export SINGULARITY_CACHEDIR

# Pull the phippery container
CONTAINER_DIR="containers"
mkdir -p "${CONTAINER_DIR}"

if [ ! -f "${CONTAINER_DIR}/phippery.sif" ]; then
    echo "Pulling phippery Singularity image..."
    singularity pull "${CONTAINER_DIR}/phippery.sif" docker://quay.io/hdc-workflows/phippery:latest
    echo "Container downloaded successfully!"
else
    echo "Container already exists at ${CONTAINER_DIR}/phippery.sif"
fi

# Test the container
echo ""
echo "Testing container..."
singularity exec "${CONTAINER_DIR}/phippery.sif" phippery --help

# ==============================================================================
# Option 2: Local Python Installation (Alternative)
# ==============================================================================

echo ""
echo "======================================================================"
echo "Setting up local Python environment (backup option)..."
echo "======================================================================"

# Load Python module if available (adjust for your HPC)
#	python3 is "built in"
#module load python/3.10 2>/dev/null || module load python3 2>/dev/null || true

# Create virtual environment
VENV_DIR="phippery_env"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "${VENV_DIR}"
fi

# Activate environment
source "${VENV_DIR}/bin/activate"

# Upgrade pip
pip install --upgrade pip

# Install phippery and dependencies
echo "Installing phippery and dependencies..."
pip install phippery
pip install pandas numpy scipy xarray matplotlib seaborn
pip install scikit-learn statsmodels
pip install pyyaml tqdm click
pip install pyarrow  # For fast parquet I/O

# For parallel processing
pip install joblib multiprocess

# Verify installation
echo ""
echo "Verifying installation..."
python3 -c "import phippery; print(f'phippery version: {phippery.__version__}')"
python3 -c "import pandas; print(f'pandas version: {pandas.__version__}')"
python3 -c "import xarray; print(f'xarray version: {xarray.__version__}')"

# Test CLI
phippery --help

echo ""
echo "======================================================================"
echo "Installation complete!"
echo ""
echo "To use the Singularity container:"
echo "  singularity exec ${CONTAINER_DIR}/phippery.sif phippery <command>"
echo ""
echo "To use the local Python environment:"
echo "  source ${VENV_DIR}/bin/activate"
echo "  phippery <command>"
echo "======================================================================"
