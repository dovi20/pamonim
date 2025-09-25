#!/bin/bash

# Deployment script for React Coming Soon App
echo "🚀 Starting deployment..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the application
echo "🔨 Building application..."
npm run build

# The dist folder now contains the production build
echo "✅ Build completed successfully!"
echo "📁 Production files are ready in the 'dist' folder"
echo "🌐 You can now serve the contents of the 'dist' folder with any web server"