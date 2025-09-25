# Pamonim - React Application

A beautiful, responsive "Coming Soon" page built with React and Vite.

## 🚀 Quick Start

### Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Open http://localhost:5173 in your browser
```

### Production Build
```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## 📁 Project Structure

```
pamonim/
├── public/          # Static assets
├── src/             # Source code
│   ├── App.jsx      # Main React component
│   ├── App.css      # Component styles
│   ├── index.css    # Global styles
│   └── main.jsx     # Application entry point
├── dist/            # Production build (generated)
├── package.json     # Dependencies and scripts
├── vite.config.js   # Vite configuration
└── deploy.sh        # Deployment script
```

## 🌐 Deployment

### Option 1: Static File Server (Recommended)
The easiest way to deploy is to serve the `dist` folder with any web server:

```bash
# Build the application
npm run build

# Serve with Python (if available)
python3 -m http.server 8000

# Or with Node.js
npx serve dist

# Or with Nginx (configure your web server)
# Point your domain to serve the dist folder
```

### Option 2: GitHub Pages
1. Push this repository to GitHub
2. Go to repository Settings → Pages
3. Set source to "Deploy from a branch"
4. Select "gh-pages" branch (or create GitHub Action for auto-deployment)

### Option 3: Manual Server Deployment
1. Upload the entire project to your Linux server
2. Run the deployment script:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```
3. Configure your web server (Apache/Nginx) to serve the `dist` folder

## 🛠️ Customization

### Changing Colors
Edit `src/App.css` and modify the CSS custom properties:
```css
.app {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

### Adding Content
Edit `src/App.jsx` to modify the coming soon page content:
```jsx
<h1 className="main-title">Your Title Here</h1>
<p className="subtitle">Your subtitle here</p>
```

### Adding Social Links
Update the social links in `src/App.jsx`:
```jsx
<div className="social-links">
  <a href="https://twitter.com/yourusername" className="social-link">Twitter</a>
  <a href="https://github.com/yourusername" className="social-link">GitHub</a>
</div>
```

## 🔧 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally

## 📱 Features

- ✅ Responsive design
- ✅ Modern gradient background
- ✅ Animated progress bar
- ✅ Social media links
- ✅ Production-ready build
- ✅ Fast development with Vite
- ✅ Modern React with hooks

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).