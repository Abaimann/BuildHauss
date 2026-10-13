# BuildHaus Offline AI Strategy

## Overview

BuildHaus uses a two-phase approach to AI-powered complaint analysis:

### Phase 1: Rule-Based Analysis (Implemented)

Deterministic keyword matching and safety rule engine:
- Detects danger keywords: "rem blong", "ban pecah", "bahan bakar bocor"
- Risk level assessment: high / medium / low
- Safety-first recommendations
- Works 100% offline, no model download required

### Phase 2: LLM Analysis (Planned)

Qwen3 0.6B GGUF quantized model via llama.cpp Android:
- Small footprint (~350 MB)
- Runs on-device with ~2GB RAM minimum
- Indonesian language understanding
- Structured JSON output for analysis

## Model Manifest

**Candidate Model**: Qwen3-0.6B-GGUF

| Property | Value |
|----------|-------|
| Name | Qwen3-0.6B-GGUF |
| Version | 1.0 |
| Size | ~350 MB |
| License | Apache 2.0 |
| Min RAM | 2 GB |
| Min Storage | 500 MB free |
| Min Android | API 24 |

## Implementation Architecture

```
Flutter UI (Dart)
    ↓
Local LLM Service (bridge)
    ↓
llama.cpp (JNI / FFI)
    ↓
Model file (GGUF, stored in app-private storage)
```

## Model Download Manager

Features:
- Download progress tracking
- Pause / Resume / Cancel support
- SHA-256 checksum verification
- Atomic save to app-private directory
- Download status persistence in database
- Error reporting with last_error field

## Analysis Output Schema

LLM produces structured JSON:
```json
{
  "symptoms": ["string"],
  "component_candidates": ["string"],
  "follow_up_questions": ["string"],
  "risk_level": "high|medium|low",
  "possible_causes": ["string"],
  "inspection_advice": "string",
  "historical_matches": ["string"],
  "uncertainty": "high|medium|low",
  "requires_mechanic": boolean
}
```

## Safety Validation

Rule engine deterministically handles:
- Rem not functioning → ALWAYS require mechanic
- Ban damaged → ALWAYS require mechanic
- Fuel leak → ALWAYS require mechanic
- These overrides apply regardless of LLM output

## Current Status

- Rule-based analysis: ✅ IMPLEMENTED and functional
- LLM download manager UI: ✅ IMPLEMENTED (download flow)
- Native llama.cpp bridge: ⏳ PENDING (requires NDK + JNI setup)
- Model file: ⏳ PENDING (requires verified download URL)

## Privacy

- All complaint data stays on-device
- No network calls for analysis (after model download)
- No user data sent to any server
- Model stored in app-private directory
- Uninstall removes all data
