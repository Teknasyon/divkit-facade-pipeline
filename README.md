# Automating(divkit-facade-pipeline) Updates with Cron

## Overview
This script automates the process of cloning the `divkit-facade-pipeline` repository, running the `update-divkit-lib.sh` script, and cleaning up temporary files. It is intended to be executed on a CI machine as a scheduled cron job.

## Prerequisites
Ensure that the following dependencies are installed on the CI machine:
- **Git**
- **Bash**
- **Cron (for scheduling the script)**

## Usage

1. Save the script as `update-divkit.sh` and give it execute permissions:

   ```bash
   chmod +x update-divkit.sh
   ```

2. Run the script `update-divkit-lib.sh`

   ```bash
   sh update-divkit.sh
   ```