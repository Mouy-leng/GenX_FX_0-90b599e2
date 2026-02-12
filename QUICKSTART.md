# Quick Start Guide - GenX FX Trading Platform

## 🚀 5-Minute Setup

### Prerequisites
- Python 3.11+
- Node.js 18+
- Git

### 1. Clone & Install (2 minutes)

```bash
# Clone repository
git clone https://github.com/Mouy-leng/GenX_FX_0.git
cd GenX_FX_0

# Install Python dependencies
pip install -r requirements.txt

# Install Node.js dependencies
npm install

# Create environment file
cp .env.example .env
```

### 2. Configure (1 minute)

Edit `.env` and add at minimum:
```bash
GEMINI_API_KEY=your_key_here
LOG_LEVEL=INFO
PORT=8000
```

### 3. Validate Setup (1 minute)

```bash
python validate_setup.py
```

### 4. Start Development (1 minute)

```bash
npm run dev
```

Access:
- **Frontend**: http://localhost:5173
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## 📚 Detailed Guides

| Guide | Purpose |
|-------|---------|
| [SETUP.md](../SETUP.md) | Complete setup instructions |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Trading with the platform |
| [SYSTEM_ARCHITECTURE_GUIDE.md](SYSTEM_ARCHITECTURE_GUIDE.md) | Architecture overview |
| [API_KEY_SETUP.md](API_KEY_SETUP.md) | API key configuration |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Production deployment |

---

## 🔧 Common Commands

### Development
```bash
npm run dev          # Start all services
npm run client       # Start frontend only
npm run server       # Start Node server only
npm run python:dev   # Start Python API only
```

### Testing
```bash
python -m pytest tests/ -v     # Python tests
npm test                        # Node tests
npm run lint                    # Lint code
```

### Building
```bash
npm run build        # Build for production
npm run preview      # Preview production build
```

### Docker
```bash
docker-compose up -d             # Start all services
docker-compose logs -f           # View logs
docker-compose down              # Stop services
```

---

## 🚨 Security Notice

**IMPORTANT**: Before deploying to production:

1. ✅ Read [SECURITY_ALERT.md](../SECURITY_ALERT.md)
2. ✅ Rotate any exposed keys
3. ✅ Configure all required secrets
4. ✅ Review [SECURITY_REVIEW.md](SECURITY_REVIEW.md)
5. ✅ Run `npm audit fix`

---

## ✅ Validation Checklist

- [ ] Python 3.11+ installed
- [ ] Node.js 18+ installed
- [ ] Dependencies installed (Python & Node)
- [ ] `.env` file created and configured
- [ ] Tests passing (`pytest` and `npm test`)
- [ ] API keys configured
- [ ] Development server starts successfully
- [ ] Can access frontend at http://localhost:5173
- [ ] Can access API at http://localhost:8000

---

## 📞 Getting Help

- **Setup Issues**: See [SETUP.md](../SETUP.md) Troubleshooting section
- **Documentation**: Browse `docs/` directory
- **Bug Reports**: https://github.com/Mouy-leng/GenX_FX_0/issues
- **Security Issues**: See [SECURITY_ALERT.md](../SECURITY_ALERT.md)

---

## 📝 Next Steps After Setup

1. **For Traders**: Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. **For Developers**: Read [SYSTEM_ARCHITECTURE_GUIDE.md](SYSTEM_ARCHITECTURE_GUIDE.md)
3. **For Deploying**: Read [DEPLOYMENT.md](DEPLOYMENT.md)
4. **For MT4/5**: Read [EA_SETUP_GUIDE.md](EA_SETUP_GUIDE.md)

---

**Quick Reference**: Keep this guide handy for common tasks and commands.
