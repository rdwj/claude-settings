# Faster-Whisper Service Implementation Plan

## Overview

Deploy a faster-whisper service with verbose_json output (words inside segments) for pyannote integration. Uses medium model, shares GPU with pyannote-server via timeslicing.

## Target Locations

- **Service code**: `components/faster-whisper/`
- **Deployment docs**: `/Users/wjackson/Developer/advanced-rag/models/faster-whisper/`

## Architecture

```
┌─────────────────────────────────────────────┐
│            GPU Node (timesliced)            │
│  ┌─────────────────┐  ┌─────────────────┐  │
│  │ pyannote-server │  │ faster-whisper  │  │
│  │   (existing)    │  │    (new)        │  │
│  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────┘
         │                      │
         └──────────┬───────────┘
                    ▼
         Higher-level orchestrator
```

## Implementation Steps

### Step 1: Create Project Structure

```
components/faster-whisper/
├── src/
│   ├── __init__.py
│   ├── server.py          # FastAPI app, endpoints
│   ├── transcribe.py      # faster-whisper wrapper
│   └── models.py          # Pydantic response models
├── tests/
│   └── test_transcribe.py
├── Containerfile
├── requirements.txt
├── Makefile
└── manifests/
    ├── kustomization.yaml
    ├── deployment.yaml    # Deployment + Service (cluster-internal)
    └── pvc.yaml           # Model cache storage
```

### Step 2: Implement Response Models (`src/models.py`)

OpenAI verbose_json compatible format:

```python
class Word(BaseModel):
    word: str
    start: float
    end: float
    probability: float

class Segment(BaseModel):
    id: int
    start: float
    end: float
    text: str
    avg_logprob: float
    no_speech_prob: float
    words: list[Word]

class TranscriptionResponse(BaseModel):
    task: str = "transcribe"
    language: str
    duration: float
    text: str
    segments: list[Segment]
```

### Step 3: Implement Transcription Wrapper (`src/transcribe.py`)

- Load faster-whisper model at module import (for startup loading)
- Use `WhisperModel("medium", device="cuda", compute_type="float16")`
- Wrapper function to convert faster-whisper output to verbose_json format
- Handle word timestamp extraction from segments

### Step 4: Implement FastAPI Server (`src/server.py`)

**Endpoints:**
- `POST /transcribe` - Main transcription endpoint (multipart file upload)
- `GET /health` - Model status, device info
- `GET /ready` - Readiness probe

**Startup:**
- Load model in `@app.on_event("startup")`
- Log device (cuda/cpu) and model loaded status

**Request handling:**
- Accept audio file via multipart/form-data
- Optional query params: `language` (auto-detect if not specified)
- Use ThreadPoolExecutor for transcription (CPU-bound during decode)

### Step 5: Create Containerfile

Based on pyannote-server pattern:
- UBI9 Python 3.11 base
- Install ffmpeg for audio processing
- Install faster-whisper + dependencies
- PyTorch CUDA 12.1 wheels
- Expose port 8080

### Step 6: Create OpenShift Manifests

**deployment.yaml:**
- Namespace: `faster-whisper` (new project)
- GPU request: `nvidia.com/gpu: 1`
- GPU toleration for scheduling
- PVC mount at `/mnt/models` for model cache
- /dev/shm emptyDir (2Gi) for PyTorch
- Environment: `MODEL_SIZE=medium`, `COMPUTE_TYPE=float16`
- Probes: `/ready` (readiness), `/health` (liveness)
- Service: ClusterIP only (cluster-internal)

**pvc.yaml:**
- 5Gi storage for medium model cache

**kustomization.yaml:**
- Reference pvc.yaml and deployment.yaml

### Step 7: Create Makefile

Targets:
- `build` - Local podman build
- `build-remote` - Delegate to ec2-dev for x86_64
- `push` - Push to quay.io
- `deploy` - `oc apply -k manifests/`
- `logs` - `oc logs -f deployment/faster-whisper`
- `test` - Run pytest

### Step 8: Write Tests

- Test response model serialization
- Test transcription wrapper with sample audio
- Mock model for unit tests

### Step 9: Create Deployment Documentation

Copy to `/Users/wjackson/Developer/advanced-rag/models/faster-whisper/`:
- README.md with deployment steps
- All source code
- Manifests
- Makefile

## Key Files to Modify/Create

| File | Action | Purpose |
|------|--------|---------|
| `components/faster-whisper/src/models.py` | Create | Pydantic response models |
| `components/faster-whisper/src/transcribe.py` | Create | faster-whisper wrapper |
| `components/faster-whisper/src/server.py` | Create | FastAPI application |
| `components/faster-whisper/Containerfile` | Create | Container image |
| `components/faster-whisper/requirements.txt` | Create | Python dependencies |
| `components/faster-whisper/Makefile` | Create | Build/deploy targets |
| `components/faster-whisper/manifests/*.yaml` | Create | OpenShift resources |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `MODEL_SIZE` | `medium` | Whisper model size |
| `MODEL_PATH` | `/mnt/models` | Model cache directory |
| `COMPUTE_TYPE` | `float16` | Inference precision |
| `DEVICE` | `cuda` | Device (cuda/cpu) |

## Dependencies

```
fastapi>=0.109.0
uvicorn>=0.27.0
python-multipart>=0.0.6
faster-whisper>=1.0.0
torch>=2.0.0
pydantic>=2.0.0
```

## Container Registry

- **Image**: `quay.io/wjackson/faster-whisper:latest`

## Verification Steps

1. Build and push container image to quay.io/wjackson/faster-whisper
2. Create namespace: `oc new-project faster-whisper`
3. Deploy to OpenShift: `oc apply -k manifests/ -n faster-whisper`
4. Wait for pod ready
5. Test transcription (from within cluster or port-forward):
   ```bash
   oc port-forward svc/faster-whisper 8080:8080 -n faster-whisper
   curl -X POST http://localhost:8080/transcribe -F "file=@test.wav"
   ```
6. Verify verbose_json output with words inside segments
