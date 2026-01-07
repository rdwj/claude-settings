# Research: Python Async HTTP Clients

**Date:** 2025-01-07
**Topic:** httpx vs requests vs aiohttp for async HTTP requests

## Summary

**For async applications, use `httpx`** - it offers the best balance of performance, developer experience, and flexibility. It supports both sync and async APIs with a requests-compatible interface, making migration easy and code maintainable. Use `aiohttp` only if you need maximum throughput in high-concurrency scenarios (10,000+ concurrent connections) and are willing to accept a steeper learning curve.

## Options Analyzed

| Library | Async Support | HTTP/2 | API Simplicity | Performance | Best For |
|---------|--------------|--------|----------------|-------------|----------|
| **httpx** | Native (sync + async) | Yes | Excellent (requests-like) | Good | Most async applications |
| **aiohttp** | Native (async only) | No | Moderate | Excellent | High-concurrency, WebSockets |
| **requests** | No | No | Excellent | N/A for async | Sync-only scripts |

## Recommendation

**Use `httpx` for your async Python applications** because:

1. **Dual API**: Supports both sync and async with the same interface - no code rewrite needed
2. **HTTP/2 native**: Modern protocol support out of the box
3. **Familiar API**: Near drop-in replacement for `requests` - minimal learning curve
4. **Active development**: Maintained by Tom Christie (Django REST framework author)
5. **Good enough performance**: While ~15-20% slower than aiohttp in benchmarks, this rarely matters in practice

**Consider `aiohttp` only if:**
- You need WebSocket client/server support
- You're handling 10,000+ concurrent connections
- Every millisecond of latency matters (high-frequency trading, etc.)
- You need both HTTP client AND server in one library

## Detailed Findings

### httpx

- **Repository**: [encode/httpx](https://github.com/encode/httpx)
- **First Release**: August 2019
- **License**: BSD
- **Python**: 3.8+

**Strengths:**
- Synchronous and asynchronous APIs in one library
- Native HTTP/2 support
- requests-compatible API (easy migration)
- Excellent documentation
- Built on httpcore for performance

**Example:**
```python
import httpx

# Async usage
async with httpx.AsyncClient() as client:
    response = await client.get("https://api.example.com/data")

# Sync usage (same API!)
with httpx.Client() as client:
    response = client.get("https://api.example.com/data")
```

### aiohttp

- **Repository**: [aio-libs/aiohttp](https://github.com/aio-libs/aiohttp)
- **First Release**: October 2014
- **License**: Apache-2.0 AND MIT
- **Python**: 3.9+
- **Latest**: 3.13.3 (January 2025)

**Strengths:**
- Fastest async HTTP client in benchmarks
- Both client and server capabilities
- WebSocket support built-in
- Mature and battle-tested (10+ years)
- Large ecosystem (aiohttp-related packages)

**Performance tip:** Install with speedups:
```bash
pip install aiohttp[speedups]  # Includes aiodns, brotli
```

**Example:**
```python
import aiohttp

async with aiohttp.ClientSession() as session:
    async with session.get("https://api.example.com/data") as response:
        data = await response.json()
```

### requests

- **Repository**: psf/requests
- **Status**: Sync-only, not suitable for async applications
- **Use case**: Simple scripts, CLI tools, sync-only codebases

**Not recommended for async** - requires threading workarounds that defeat the purpose of async.

## Performance Benchmarks

From multiple sources, performance ranking (fastest to slowest):

1. **aiohttp** (with connection pooling) - ~15-20% faster
2. **httpx async** (with connection pooling)
3. **httpx async** (new client per request)
4. **requests** (not async, included for reference)

**Note:** These differences only matter at high concurrency. For typical applications making <100 concurrent requests, the difference is negligible.

## Integration with Red Hat/OpenShift

Both `httpx` and `aiohttp` work well in containerized environments:
- Available in RHEL/UBI package repositories
- No native dependencies that complicate container builds
- Both support custom SSL contexts for enterprise certificates

## Sources

- [HTTPX vs Requests vs AIOHTTP - Oxylabs](https://oxylabs.io/blog/httpx-vs-requests-vs-aiohttp)
- [Python HTTP Clients Comparison - Speakeasy](https://www.speakeasy.com/blog/python-http-clients-requests-vs-httpx-vs-aiohttp)
- [httpx GitHub Repository](https://github.com/encode/httpx)
- [aiohttp GitHub Repository](https://github.com/aio-libs/aiohttp)
- [HTTPX Official Documentation](https://www.python-httpx.org/)
- [aiohttp Official Documentation](https://docs.aiohttp.org/)
- [Comparing HTTP Clients - DEV Community](https://dev.to/leapcell/comparing-requests-aiohttp-and-httpx-which-http-client-should-you-use-3784)
