# Plan: vLLM Pooling Models KServe Integration for OpenShift AI

## Goal
Create KServe ServingRuntimes and InferenceServices for vLLM embedding/reranker models that integrate with OpenShift AI's Model Deployments UI.

## Key Requirements
1. Models appear in OpenShift AI → Models → Model Deployments
2. ServingRuntime shows with proper name (not "unknown")
3. Support both embedding (`--task embed`) and reranker (`--task score`) models
4. Use existing `vllm-embeddings` namespace
5. **Use shared PVC (`vllm-model-cache`) for model storage** - models already cached from raw deployment testing

## Architecture Decision

**Challenge**: vLLM requires different `--task` flags for embeddings vs rerankers, and a single vLLM instance can only serve one task type.

**Solution**: Create two ServingRuntimes:
1. `vllm-embedding-runtime` - For embedding models (`--task embed`)
2. `vllm-reranker-runtime` - For reranker/cross-encoder models (`--task score`)

**Storage**: Mount existing `vllm-model-cache` PVC at `/models`, set `HF_HOME=/models/huggingface` so vLLM finds cached models.

## Implementation Plan

### Phase 1: Create ServingRuntimes

#### File: `manifests/kserve/serving-runtime-embedding.yaml`
```yaml
apiVersion: serving.kserve.io/v1alpha1
kind: ServingRuntime
metadata:
  name: vllm-embedding-runtime
  namespace: vllm-embeddings
  annotations:
    opendatahub.io/recommended-accelerators: '["nvidia.com/gpu"]'
    openshift.io/display-name: vLLM Embedding Runtime
  labels:
    opendatahub.io/dashboard: "true"
spec:
  containers:
    - name: kserve-container
      image: vllm/vllm-openai:latest
      command: ["python", "-m", "vllm.entrypoints.openai.api_server"]
      args:
        - --port=8080
        - --task=embed
        - --dtype=float16
        - --gpu-memory-utilization=0.3
        # Model-specific args (--model, --max-model-len) added via InferenceService
      env:
        - name: HOME
          value: /tmp/home
        - name: HF_HOME
          value: /models/huggingface      # Uses cached models from PVC
        - name: TRANSFORMERS_CACHE
          value: /models/huggingface
        - name: XDG_CACHE_HOME
          value: /tmp/cache
      ports:
        - containerPort: 8080
          protocol: TCP
      volumeMounts:
        - name: model-cache
          mountPath: /models              # Shared PVC with cached models
        - name: tmp-home
          mountPath: /tmp/home
        - name: tmp-cache
          mountPath: /tmp/cache
        - name: shm
          mountPath: /dev/shm
  volumes:
    - name: model-cache
      persistentVolumeClaim:
        claimName: vllm-model-cache       # Existing PVC from raw deployment testing
    - name: tmp-home
      emptyDir: {}
    - name: tmp-cache
      emptyDir: {}
    - name: shm
      emptyDir:
        medium: Memory
        sizeLimit: 2Gi
  supportedModelFormats:
    - name: vllm-embedding
      autoSelect: true
  multiModel: false
```

#### File: `manifests/kserve/serving-runtime-reranker.yaml`
Similar structure but with `--task=score` instead of `--task=embed`.

### Phase 2: Create InferenceServices

#### File: `manifests/kserve/minilm-embedding-isvc.yaml`
```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: minilm-embedding
  namespace: vllm-embeddings
  annotations:
    openshift.io/display-name: MiniLM Embedding (vLLM)
    serving.kserve.io/deploymentMode: RawDeployment
  labels:
    opendatahub.io/dashboard: "true"
spec:
  predictor:
    model:
      modelFormat:
        name: vllm-embedding
      runtime: vllm-embedding-runtime
      args:
        - --model=sentence-transformers/all-MiniLM-L6-v2
        - --max-model-len=256
      resources:
        requests:
          cpu: "2"
          memory: 4Gi
          nvidia.com/gpu: "1"
        limits:
          cpu: "4"
          memory: 8Gi
          nvidia.com/gpu: "1"
```

#### File: `manifests/kserve/granite-embedding-isvc.yaml`
Same pattern with:
- `name: granite-embedding`
- `--model=ibm-granite/granite-embedding-278m-multilingual`
- `--max-model-len=512`
- Higher memory: 8Gi request, 16Gi limit

#### File: `manifests/kserve/msmarco-reranker-isvc.yaml`
Uses `vllm-reranker-runtime` with:
- `name: msmarco-reranker`
- `modelFormat: vllm-reranker`
- `--model=cross-encoder/ms-marco-MiniLM-L12-v2`
- `--max-model-len=512`

### Phase 3: Directory Structure

```
models/vllm-embeddings/
├── manifests/
│   ├── kserve/                          # NEW - KServe resources
│   │   ├── serving-runtime-embedding.yaml
│   │   ├── serving-runtime-reranker.yaml
│   │   ├── minilm-embedding-isvc.yaml
│   │   ├── granite-embedding-isvc.yaml
│   │   └── msmarco-reranker-isvc.yaml
│   ├── base/                            # Existing - keep for raw deployment option
│   └── ... (existing model dirs)
```

### Phase 4: Update Makefile

Add new targets:
- `deploy-kserve-runtimes` - Deploy both ServingRuntimes
- `deploy-kserve-minilm` - Deploy MiniLM InferenceService
- `deploy-kserve-granite` - Deploy Granite InferenceService
- `deploy-kserve-reranker` - Deploy MS-MARCO InferenceService
- `status-kserve` - Check InferenceService status

## Files to Create/Modify

1. **CREATE**: `manifests/kserve/serving-runtime-embedding.yaml`
2. **CREATE**: `manifests/kserve/serving-runtime-reranker.yaml`
3. **CREATE**: `manifests/kserve/minilm-embedding-isvc.yaml`
4. **CREATE**: `manifests/kserve/granite-embedding-isvc.yaml`
5. **CREATE**: `manifests/kserve/msmarco-reranker-isvc.yaml`
6. **MODIFY**: `Makefile` - Add KServe deployment targets
7. **MODIFY**: `README.md` - Add KServe deployment instructions
8. **MODIFY**: `LESSONS_LEARNED.md` - Add KServe notes

## Key Configuration Notes

1. **Model-specific args via InferenceService**: The `args` field in InferenceService.spec.predictor.model appends to the ServingRuntime's container args
2. **OpenShift cache fix**: HOME, HF_HOME, XDG_CACHE_HOME redirect to writable volumes (critical for flashinfer JIT compilation)
3. **Shared PVC**: `vllm-model-cache` PVC mounted at `/models`, HF_HOME points to `/models/huggingface` for cached models
4. **GPU allocation**: `--gpu-memory-utilization=0.3` for shared environments
5. **RawDeployment mode**: Required for standard Kubernetes deployments (vs Knative serverless)
6. **Dashboard labels**: `opendatahub.io/dashboard: "true"` on both ServingRuntime and InferenceService

## Testing Steps

1. Deploy ServingRuntimes: `make deploy-kserve-runtimes`
2. Check OpenShift AI → Settings → Serving Runtimes (should show both)
3. Deploy one InferenceService: `make deploy-kserve-minilm`
4. Check OpenShift AI → Models → Model Deployments (should show model)
5. Get Route URL and test embedding endpoint
6. Repeat for other models

## Verification Commands

```bash
# Check ServingRuntimes
oc get servingruntime -n vllm-embeddings

# Check InferenceServices
oc get inferenceservice -n vllm-embeddings

# Get Routes (created automatically by KServe)
oc get routes -n vllm-embeddings

# Test endpoint
curl -sk "https://<route>/v1/embeddings" \
  -H "Content-Type: application/json" \
  -d '{"input": "test", "model": "sentence-transformers/all-MiniLM-L6-v2"}'
```

## Future: Helm Chart (Deferred)

Parameterize:
- Model ID and type (embedding vs reranker)
- Max model length
- GPU memory utilization
- Resource requests/limits
- Namespace
