#!/bin/bash

# Frontend Build Test Script
set -e

echo "🔨 Testing Frontend Build Process"
echo "=================================="

cd "$(dirname "$0")/../frontend"

echo "📋 Current directory: $(pwd)"
echo "📋 Node version: $(node --version)"
echo "📋 npm version: $(npm --version)"

echo ""
echo "📦 Installing dependencies..."
npm ci

echo ""
echo "🔍 Checking available scripts..."
npm run

echo ""
echo "📊 Package info..."
npm list --depth=0 react-scripts || echo "react-scripts not found"

echo ""
echo "🚀 Building application..."
npm run build

echo ""
echo "✅ Build completed successfully!"
echo "📁 Build output:"
ls -la build/ || echo "No build directory found"
