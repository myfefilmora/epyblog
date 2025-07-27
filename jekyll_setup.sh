#!/bin/bash
set -e

echo "📦 Installing system dependencies..."
sudo apt-get update -y
sudo apt-get install -y build-essential zlib1g-dev libffi-dev libyaml-dev ruby-full

echo "📌 Setting Ruby version to 3.2.2 (recommended)..."
echo "3.2.2" > .ruby-version

echo "🧼 Cleaning old gems (if any)..."
rm -rf vendor .bundle Gemfile.lock

echo "🪄 Initializing Gemfile..."
cat <<EOF > Gemfile
source "https://rubygems.org"

ruby "3.2.2"

gem "jekyll", "~> 4.3.2"
gem "bundler", "~> 2.4"
gem "bigdecimal"
gem "logger"
gem "jekyll-seo-tag"
gem "jekyll-feed"
gem "jekyll-paginate"
gem "webrick"
EOF

echo "📥 Installing gems locally..."
bundle config set --local path 'vendor/bundle'
bundle install

echo "🆕 Creating new Jekyll site in 'site/'..."
jekyll new site --force --skip-bundle
cd site

echo "📎 Using local Gemfile and installing site deps..."
bundle install

echo "✅ Setup complete!"
echo "👉 Run your server with:"
echo "   cd site"
echo "   bundle exec jekyll serve --host=0.0.0.0"
