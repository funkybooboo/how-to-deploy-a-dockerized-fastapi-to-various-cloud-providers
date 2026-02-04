# Development Guide

Fast, efficient local development with Docker and live code reloading.

## Quick Start (Recommended)

### Start Development Server

```bash
# Start with live reload
docker-compose -f docker-compose.dev.yaml up

# Run in background
docker-compose -f docker-compose.dev.yaml up -d

# View logs
docker-compose -f docker-compose.dev.yaml logs -f

# Stop
docker-compose -f docker-compose.dev.yaml down
```

**What happens:**
- Local `./src` mounted into container
- Edit files → changes appear instantly
- Uvicorn auto-reloads on changes
- No rebuild needed!

### Test Live Reload

1. Start dev server (command above)
2. Edit `src/api/hello.py` - change the message
3. Watch logs - you'll see "Reloading..."
4. Test: `curl http://localhost:8080/api/hello`

Changes appear immediately! 🎉

## Understanding Volume Mounts

```yaml
volumes:
  - ./src:/code/src  # Local → Container
```

**How it works:**
- Your local files are "linked" to the container
- Edit on host → changes reflect in container instantly
- Container edits → reflect on host (rare, but possible)

### When to Rebuild

**No rebuild needed:**
- ✅ Editing Python code in `./src`
- ✅ Adding new Python files
- ✅ Changing `.env` variables

**Rebuild required:**
- ❌ Modifying `requirements.txt` (dependencies)
- ❌ Changing Dockerfile
- ❌ Installing system packages

```bash
# Rebuild and restart
docker-compose -f docker-compose.dev.yaml up --build
```

## VS Code Dev Container

Best IDE integration for container development:

1. Open project in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. Code inside container with full IntelliSense
4. Terminal runs inside container
5. Extensions work as if coding locally

**Configuration:** `.devcontainer/devcontainer.json`

**Benefits:**
- Consistent environment for all developers
- No "works on my machine" issues
- All tools pre-installed in container

## Running Tests

```bash
# Inside dev container
pytest src/tests/ -v --cov=src

# Using docker-compose
docker-compose -f docker-compose.dev.yaml exec app pytest src/tests/ -v

# Run specific test
pytest src/tests/test_api.py::test_health_check -v
```

See [Quick Reference](./quick-reference.md) for more testing commands.

## Troubleshooting

**Changes not detected?** → Restart: `docker-compose -f docker-compose.dev.yaml restart`

**Port 8080 in use?** → Find process: `lsof -i :8080` (Mac/Linux) or change port

**Won't start?** → Check logs: `docker-compose -f docker-compose.dev.yaml logs`

**Permission errors?** → Fix: `sudo chown -R $USER:$USER ./src` (Linux only)

## Development Workflow

**Daily:** Start → Edit → Save → Test → Commit
```bash
docker-compose -f docker-compose.dev.yaml up
# Edit code, save, test (auto-reload)
# Run: pytest src/tests/ -v
# Stop: Ctrl+C
```

**Adding dependencies:**
1. Add to `requirements.txt` or `requirements-dev.txt`
2. Rebuild: `docker-compose -f docker-compose.dev.yaml up --build`

**Creating endpoints:**
1. Create file in `src/api/` → Define routes → Import in `src/main.py`
2. Save → Test → Add tests in `src/tests/`

## Pro Tips

- Use Docker Compose (easier than manual commands)
- Keep dev server running (no restart needed for code changes)
- Check logs for errors
- Use Dev Container for best IDE experience
- Test before committing
- Small, frequent commits

## Next Steps

- **API Documentation:** See [API Reference](./api-reference.md)
- **Docker Details:** See [Docker Guide](./docker.md)
- **Command Reference:** See [Quick Reference](./quick-reference.md)
- **Deploy to Cloud:** Check cloud-specific branches (gcloud, azure)

---

**Quick Commands:** For a comprehensive command reference, see [Quick Reference](./quick-reference.md)
