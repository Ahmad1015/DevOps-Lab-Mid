#!/bin/bash
set -e

# Make helper scripts executable
chmod +x deploy_to_aws.sh cleanup_aws.sh

function show_help {
    echo "DevOps Lab Automation (WSL/Linux)"
    echo "Usage: ./demo.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --deploy    Provision infrastructure and deploy app (Default)"
    echo "  --cleanup   Destroy infrastructure and cleanup resources"
    echo "  --help      Show this message"
}

if [ "$1" == "--cleanup" ]; then
    echo ">>> TRIGGERING CLEANUP..."
    ./cleanup_aws.sh
elif [ "$1" == "--help" ]; then
    show_help
else
    echo ">>> TRIGGERING DEPLOYMENT..."
    ./deploy_to_aws.sh
fi
