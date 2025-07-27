#!/bin/bash
set -e

echo "📦 Step 1: Install system dependencies..."
sudo apt-get update -y
sudo apt-get install -y build-essential zlib1g-dev libffi-dev libyaml-dev ruby-full

echo "📁 Step 2: Configure bundler to install locally (portable)..."
bundle config set --local path 'vendor/bundle'

echo "🧩 Step 3: Install missing Ruby standard gems removed in 3.4+..."
cat >> Gemfile <<EOF

# Extra gems needed for Ruby 3.4+ compatibility
gem "bigdecimal"
gem "logger"
gem "csv"
gem "base64"
EOF

echo "📥 Step 4: Install all Gemfile dependencies..."
bundle install

echo "🚀 Setup complete!"
echo ""
echo "👉 Run your server using:"
echo "   bundle exec jekyll serve --host=0.0.0.0"
echo ""
echo "🌐 Then open port 4000 in GitHub Codespace"
