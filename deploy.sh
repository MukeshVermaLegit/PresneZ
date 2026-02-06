#!/bin/bash

# Presenz Token Deployment Script for Base Layer 2
# This script simplifies the deployment process for both testnet and mainnet

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}ℹ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

print_error() {
    echo -e "${RED}✖ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found!"
    print_info "Creating .env from .env.example..."
    cp .env.example .env
    print_warning "Please edit .env file with your configuration and run this script again."
    exit 1
fi

# Load environment variables
source .env

# Check if required variables are set
if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" = "your_private_key_here_without_0x_prefix" ]; then
    print_error "PRIVATE_KEY not set in .env file"
    exit 1
fi

if [ -z "$ADMIN_ADDRESS" ] || [ "$ADMIN_ADDRESS" = "0x0000000000000000000000000000000000000000" ]; then
    print_error "ADMIN_ADDRESS not set in .env file"
    exit 1
fi

# Function to display banner
show_banner() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║   PRESENZ TOKEN DEPLOYMENT SCRIPT          ║"
    echo "║   Base Layer 2 Blockchain                  ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
}

# Function to display menu
show_menu() {
    echo "Select deployment network:"
    echo "  1) Base Sepolia Testnet (Chain ID: 84532)"
    echo "  2) Base Mainnet (Chain ID: 8453)"
    echo "  3) Run Tests Only"
    echo "  4) Simulate Testnet Deployment (no broadcast)"
    echo "  5) Simulate Mainnet Deployment (no broadcast)"
    echo "  6) Exit"
    echo ""
}

# Function to run tests
run_tests() {
    print_info "Running Foundry tests..."
    forge test -vv
    print_success "Tests completed!"
}

# Function to check balance
check_balance() {
    local rpc_url=$1
    local network_name=$2
    
    print_info "Checking balance on $network_name..."
    local balance=$(cast balance $ADMIN_ADDRESS --rpc-url $rpc_url)
    local eth_balance=$(echo "scale=6; $balance / 1000000000000000000" | bc)
    
    echo "Balance: $eth_balance ETH"
    
    if (( $(echo "$eth_balance < 0.01" | bc -l) )); then
        print_warning "Low balance! You may not have enough ETH for deployment."
        echo "Recommended: At least 0.05 ETH"
    fi
}

# Function to deploy
deploy() {
    local network=$1
    local rpc_url=$2
    local broadcast=$3
    
    print_info "Deploying to $network..."
    
    if [ "$broadcast" = "true" ]; then
        print_warning "This will broadcast the transaction to $network"
        echo -n "Are you sure? (yes/no): "
        read confirmation
        
        if [ "$confirmation" != "yes" ]; then
            print_info "Deployment cancelled."
            return
        fi
        
        forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
            --rpc-url $rpc_url \
            --broadcast \
            --verify \
            -vvvv
    else
        print_info "Running simulation (no broadcast)..."
        forge script script/DeployPresenzToken.s.sol:DeployPresenzToken \
            --rpc-url $rpc_url \
            -vvvv
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Deployment successful!"
        
        if [ "$broadcast" = "true" ]; then
            print_info "Transaction details saved in broadcast/ directory"
            print_info "View your deployment on the block explorer:"
            
            if [ "$network" = "Base Sepolia" ]; then
                echo "https://sepolia.basescan.org/"
            else
                echo "https://basescan.org/"
            fi
        fi
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

# Main script
show_banner

# Check if forge is installed
if ! command -v forge &> /dev/null; then
    print_error "Foundry is not installed!"
    print_info "Install it with: curl -L https://foundry.paradigm.xyz | bash"
    exit 1
fi

while true; do
    show_menu
    echo -n "Enter your choice [1-6]: "
    read choice
    echo ""
    
    case $choice in
        1)
            check_balance "$BASE_SEPOLIA_RPC_URL" "Base Sepolia"
            echo ""
            deploy "Base Sepolia" "$BASE_SEPOLIA_RPC_URL" "true"
            echo ""
            ;;
        2)
            print_warning "⚠️  MAINNET DEPLOYMENT ⚠️"
            print_warning "This will deploy to Base Mainnet with REAL money!"
            echo ""
            check_balance "$BASE_RPC_URL" "Base Mainnet"
            echo ""
            deploy "Base Mainnet" "$BASE_RPC_URL" "true"
            echo ""
            ;;
        3)
            run_tests
            echo ""
            ;;
        4)
            deploy "Base Sepolia" "$BASE_SEPOLIA_RPC_URL" "false"
            echo ""
            ;;
        5)
            deploy "Base Mainnet" "$BASE_RPC_URL" "false"
            echo ""
            ;;
        6)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice! Please select 1-6."
            echo ""
            ;;
    esac
done
