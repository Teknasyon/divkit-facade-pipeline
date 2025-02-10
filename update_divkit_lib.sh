#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo "${color}${message}${NC}"
}

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message $RED "Error: $1 is required but not installed."
        exit 1
    fi
}

# Check required commands
check_command "git"

# Working directory
WORK_DIR=$(mktemp -d)
print_message $BLUE "📍 Working in temporary directory: $WORK_DIR"

# Copying scipio
print_message $YELLOW "📤 Copying and Extracting scipio.zip ..."
cp -r scipio.zip $WORK_DIR
cd $WORK_DIR
unzip scipio.zip
rm -rf scipio.zip

# Clone pods-binary-container to check current version
print_message $YELLOW "🔍 Checking current version..."
git clone --depth 1 https://github.com/mustafagunes/pods-binary-container.git
current_version=$(grep -E 's.version\s*=' pods-binary-container/DivKitBinaryCompatibilityFacade.podspec | awk -F"[\'\"]" '{print $2}')
print_message $GREEN "📌 Current version: $current_version"

# Get latest tag from divkit-ios-facade
print_message $YELLOW "🔍 Checking latest version from divkit-ios-facade..."
latest_tag=$(curl -s https://api.github.com/repos/divkit/divkit-ios-facade/tags | grep -o '"name": "[^"]*' | head -1 | cut -d'"' -f4)
print_message $GREEN "📌 Latest version: $latest_tag"

if [[ "$current_version" == "$latest_tag" ]]; then
    print_message $GREEN "✅ Version is up to date! No action needed."
    exit 0
fi

print_message $YELLOW "🔄 Update needed. Starting update process..."

# Clone divkit-ios-facade repository
print_message $BLUE "📥 Cloning divkit-ios-facade repository..."
git clone --depth 1 https://github.com/divkit/divkit-ios-facade.git
cd divkit-ios-facade

# Run scipio command
print_message $BLUE "🛠 Running scipio command..."
../scipio create --platforms iOS --support-simulators

# Move XCFrameworks to parent directory
print_message $BLUE "📦 Moving XCFrameworks..."
mv XCFrameworks ../

# Remove artifacts
print_message $YELLOW "🗑 Removing artifacts..."
rm -rf .build .git .gitignore
cd ..

# Zip facade directory
print_message $BLUE "🗜 Creating zip archive..."
zip -r divkit-ios-facade-source.zip divkit-ios-facade/

# Clone and update pods-binary-container
print_message $BLUE "🔄 Updating pods-binary-container..."
cd pods-binary-container/divkit-ios-facade-binary/

# Remove old files
print_message $YELLOW "🗑 Removing old files..."
rm -rf *.zip XCFrameworks

# Copy new files
print_message $BLUE "📋 Copying new files..."
mv ../../divkit-ios-facade-source.zip .
mv ../../XCFrameworks .

# Update podspec version
print_message $BLUE "📝 Updating podspec version..."
cd ..
sed -i '' "s/s.version.*=.*/s.version      = '$latest_tag'/" DivKitBinaryCompatibilityFacade.podspec

# Git operations
print_message $BLUE "📤 Committing and pushing changes..."
git checkout -b divkit-facade-lib-$latest_tag
git add .
git commit -m "Update DivKit to version $latest_tag"
git push -u origin divkit-facade-lib-$latest_tag

print_message $GREEN "✅ Update completed successfully!"
print_message $GREEN "📌 Updated from version $current_version to $latest_tag"

# Cleanup
cd ../
rm -rf $WORK_DIR
print_message $BLUE "🧹 Cleaned up temporary files"
