# Jules Memory Dump

This document contains the retained memory and context for the AI assistant Jules, covering project details, technical constraints, and learned patterns.

## Project Context
- **Repository**: Monorepo for 'GenX FX AI Trading Platform'.
- **Components**:
    - Python FastAPI backend (`api/`, port 8000).
    - Node.js Express server (`services/server/`, port 5000).
    - React Frontend (`client/`, port 5173).
    - AI Models (`ai_models/`).
    - MQL5 Expert Advisors (`expert-advisors/`).
- **Dependencies**:
    - Frontend dependencies managed in root `package.json`.
    - Python version: 3.12.12.
    - Python dependencies: `requirements.txt`.
- **Command Standards**:
    - Build: `pnpm build`.
    - Dev: `pnpm dev` (runs all services).
    - Frontend Dev: `pnpm client`.
    - Test: `python run_tests.py && pnpm test`.
    - Lint: `pnpm lint` (requires install first).
    - Package Manager: `pnpm` (strongly preferred over npm/yarn).

## Technical Details & Constraints
- **Networking**:
    - Vite proxies `/api`, `/health`, `/socket.io` to Node (5000).
    - Vite proxies `/api/v1`, `/api/v2`, `/trading-pairs` to Python (8000).
    - `api/main.py` has strict CORS allowing specific origins.
    - `services/server/vite.ts` must use relative imports to root.
- **Frontend**:
    - No `package.json` in `client/` (uses root).
    - Uses `lucide-react` for icons.
    - Uses `react-hook-form`.
    - Accessibility: Use `sr-only` for labels, check color contrast.
    - Verification: Use Playwright with intercepted requests to mock backend.
- **Backend (Python)**:
    - `api/main.py` uses `lifespan` for startup/shutdown.
    - Exception handling: Use `except Exception:` not bare `except:`.
    - Tests: `pytest` (via `run_tests.py`). `TrustedHostMiddleware` affects `TestClient`.
- **Backend (Node)**:
    - Uses TypeScript and Drizzle ORM.
- **Expert Advisors**:
    - `EXNESS_GenX_Trader.mq5` uses `UseAI=true` by default (API: `http://203.147.134.90`).
    - Logic: MA(10/30) crossover + RSI(14).
    - JSON handling is manual string parsing.
    - Daily P/L based on `startBalance` reset daily.

## Environment & Infrastructure
- **Git**: Shallow clones cause merge issues; fetch depth needed.
- **External Libs**: Store in `external/`, remove `.git` folders.
- **Docker**: Daemon often restricted in environment; rely on build/test scripts.
- **CI/CD**: `my-drive-projects` repo has workflows. `powershell-ci.yml` needs `pwsh`.

## VPS Deployment Details
- **Singapore VPS**:
    - Path: `.../MQL5/Shared Projects/EXNESS_GenX_Trading/DEPLOY/VPS_6773048_DEPLOYMENT_STATUS.md`
    - Network:
        - SSID: LengA6-9V
        - Protocol: Wi-Fi 4 (802.11n)
        - IP: 192.168.18.6
        - MAC: 78:20:51:54:60:5C
    - Certificate: `secops.group` (Let's Encrypt), Exp: Feb 15, 2026.
    - Docker: `https://github.com/dockur/windows` (Windows in Docker context).

## Links & Resources
- **Dropbox (Memory)**: [Link 1](https://www.dropbox.com/scl/fo/wmsuv2bpkgosp1jli5tc5/AOKGX65h1csk9PcFapBwpJk?rlkey=1h8e0od7q2ijbwdvkvg5qsvrs&st=1d4kjv2w&dl=0)
- **Dropbox (Memory 2)**: [Link 2](https://www.dropbox.com/scl/fo/wmsuv2bpkgosp1jli5tc5/AOKGX65h1csk9PcFapBwpJk?rlkey=1h8e0od7q2ijbwdvkvg5qsvrs&st=wi1idcs3&dl=0)
- **Drive Link (User Request)**: https://1drv.ms/f/c/8F247B1B46E82304/IgDpUzdplXkDTpiyCkdNDZpXASUMJEccVuNGxAaY3MxB1sA
- **Proton Drive**: [Link](https://drive.proton.me/urls/2D7WAV1B70#C5LasdZntV7P)
- **NotebookLM**: [Link](https://notebooklm.google.com/notebook/35d7301f-8fa7-4bd0-b7b8-e492060404de)
- **Samsung Cloud Note (Leng Kundee 01/24)**: [Link](https://groupshare.samsungcloud.com/invitation/notecoedit/hpXmILJ1xT)
- **OneDrive Vault**: Password = 369369
- **Github API**: https://docs.github.com/api/article/body?pathname=/en/enterprise-server@3.19/admin/all-releases
- **OpenAI Codex**: https://github.com/openai/codex

## Learnings & Notes
- **UX**: Learnings in `.Jules/palette.md`.
- **Accessibility**: Avoid `text-green-500`/`amber-500` on white.
- **Testing**: `pnpm test` uses `vitest`.
- **Verification**: Frontend verification is performed using Python scripts utilizing the `playwright` library.
- **Vite Config**: `vite.config.js` is a build artifact generated from `vite.config.ts`.
