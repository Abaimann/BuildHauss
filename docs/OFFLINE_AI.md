# BuildHaus Offline AI Strategy & Architecture

## Overview

BuildHaus implements a robust, completely offline on-device AI system for motorcycle complaint consultation and predictive maintenance guidance on Android.

### Dual-Engine Architecture:
1. **Real Native LLM Engine (Implemented in Tahap 04)**:
   - Powered by **Qwen3 0.6B GGUF** quantized at **Q4_K_M** (~378.3 MB)
   - Executed locally via native **llama.cpp** engine on Android (`arm64-v8a` with ARM NEON and Vulkan GPU layer acceleration)
   - Real-time token streaming via Pigeon IPC / EventChannel
   - Ingests active motorcycle context (brand, model, odometer, component health, past services, past complaints)
   - Produces structured diagnostic assessments with strict multi-motorcycle data isolation.

2. **Deterministic Safety Guard Engine (`AiSafetyGuard`)**:
   - Inspects complaints for critical safety red flags:
     - Brake failure ('rem blong', 'rem ambles', 'minyak rem bocor')
     - Fuel leaks ('bensin bocor', 'bahan bakar bocor', 'tangki bocor')
     - Severe tire damage ('ban pecah', 'ban robek', 'kawat ban keluar')
     - Steering/control failure ('stang oleng', 'segitiga bengkok', 'kemudi macet')
   - **Absolute Safety Override**: Enforces `risk_level = 'high'` and `requires_mechanic = true`.
   - The LLM can never override, dismiss, or downgrade these safety warnings.

3. **Transparent Rule-Based Fallback**:
   - When the offline model has not yet been downloaded, or if the host platform is non-Android or unsupported:
   - System transparently operates in rule-based mode, explicitly labeled:
     `[Mode: Analisis Dasar — AI Offline Belum Aktif]`
   - Zero fake inference, zero simulated typing of hardcoded text, and zero cloud API calls.

---

## Model Provenance & Manifest

| Property | Value |
|---|---|
| **Model ID** | `qwen3-0.6b-q4_k_m` |
| **Model Name** | Qwen3-0.6B-GGUF |
| **Model Version** | 1.0.0 |
| **Architecture** | Qwen3 dense 0.6B multilingual language model |
| **Quantization** | Q4_K_M (4-bit medium with k-quants) |
| **File Name** | `Qwen3-0.6B-Q4_K_M.gguf` |
| **Repository** | `unsloth/Qwen3-0.6B-GGUF` (Hugging Face) |
| **Verified URL** | `https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf` |
| **File Size** | 396,705,472 bytes (~378.3 MB) |
| **SHA-256 Checksum** | `ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a` |
| **License** | Apache 2.0 |
| **Min RAM** | 2 GB |
| **Min Free Storage** | 500 MB |
| **Min Android API** | API 26 (Android 8.0 Oreo) |
| **Chat Template** | ChatML (`<\|im_start\|>system...<\|im_end\|>`) |

---

## Native Runtime Architecture

```
Flutter UI (Dart / Riverpod)
    │
    ▼
AiChatService
    │  ├── Context Retrieval (AiContextRetriever - SQLite)
    │  ├── Deterministic Safety Guard (AiSafetyGuard)
    │  └── Model Download & Integrity (ModelDownloadService)
    │
    ▼
OfflineAiRuntime (AndroidOfflineAiRuntime)
    │
    ▼
llama_flutter_android (Pigeon MethodChannel / EventChannel)
    │
    ▼
Native C++ (libllama.so compiled via Android NDK 28 & CMake 3.22.1)
    │  ├── ARM64 NEON & DotProd optimizations
    │  ├── Vulkan Compute Queue layer offloading
    │  └── 16KB memory page size compliance
    │
    ▼
Local GGUF Model (Stored in private app storage: /data/user/0/.../ai_models/)
```

---

## Real Model Download Manager

1. **HTTP Range Resume**:
   - Supports partial chunk resume using `Range: bytes={existingBytes}-`.
   - Validates HTTP 206 (Partial Content); restarts cleanly if server returns HTTP 200.
2. **Cryptographic Verification**:
   - Computes whole-file SHA-256 using chunked streaming via `package:crypto`.
   - Rejects, logs, and deletes corrupt files on hash mismatch.
3. **Atomic File Move**:
   - Download writes to temporary `.part` file.
   - Atomically renames to `.gguf` ONLY after SHA-256 is 100% verified.
4. **Lifecycle & Persistence**:
   - Full persistence in SQLite `ai_model_installs` table.
   - Pause, resume, cancel, and clean deletion workflows.

---

## SQLite Database Persistence

- **Tabel 11 (`complaints`)**: Stores motorcycle complaints with odometer reading and status.
- **Tabel 12 (`complaint_messages`)**: Stores full chat conversation history with roles (`user`, `assistant`, `system`) and `analysis_mode` (`llm` or `rule_based`).
- **Tabel 13 (`complaint_analyses`)**: Stores structured JSON analyses (`symptoms`, `component_candidates`, `follow_up_questions`, `risk_level`, `requires_mechanic`, `model_version`, `analyzed_at`).
- **Tabel 21 (`ai_model_installs`)**: Stores model installation metadata, file paths, exact byte sizes, download status, and verification states.

---

## Current Status: COMPLETED (Tahap 04)

- Model Manifest: ✅ IMPLEMENTED & VERIFIED
- Native llama.cpp Android Integration: ✅ COMPILED & LINKED (NDK 28 / CMake 3.22.1)
- Real Model Download Manager: ✅ IMPLEMENTED (Dio HTTP Range, Resume, Atomic Move)
- SHA-256 Checksum Verification: ✅ IMPLEMENTED & VERIFIED
- AI Context Retrieval (Isolated): ✅ IMPLEMENTED & TESTED
- Deterministic Safety Guard: ✅ IMPLEMENTED & TESTED
- Fallback System: ✅ IMPLEMENTED (Transparent "Analisis Dasar")
- Unit & Database Tests: ✅ 113/113 PASSED (100% PASS RATE)
- Debug APK Build: ✅ SUCCESSFUL (`app-debug.apk` built with native runtime)
