# BuildHaus Sources and Licenses

## Asset Sources

### Motorcycle Models Catalog
- **Source**: BuildHaus curated data
- **Format**: JSON
- **License**: Public domain / CC0
- **URL**: Internal asset (`assets/catalogs/motorcycle_models.json`)

### Spareparts Catalog
- **Source**: BuildHaus curated from official manufacturer catalogs
- **Format**: JSON
- **License**: Public domain / CC0
- **Sources referenced**:
  - Astra Honda Motor (astra-honda.com)
  - Yamaha Indonesia (yamaha-motor.co.id)
  - Suzuki Indonesia (suzuki.co.id)
  - Kawasaki Indonesia (kawasaki-motor.co.id)
- **Disclaimer**: All data is for reference only. Always verify with official sources.

### Maintenance Rules
- **Source**: BuildHaus curated from official service manuals
- **Format**: JSON
- **License**: Public domain / CC0
- **Disclaimer**: Rules are general estimates. Always verify with your motorcycle's official manual.

## Dependencies

| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| flutter_riverpod | 2.6.1 | MIT | State management |
| go_router | 14.8.1 | BSD-3-Clause | Navigation |
| drift | 2.28.2 | MIT | SQLite ORM |
| drift_flutter | 0.2.7 | MIT | Drift Flutter integration |
| sqlite3_flutter_libs | 0.5.42 | BSD-3-Clause | SQLite native libs |
| dio | 5.11.1 | MIT | HTTP client |
| path_provider | 2.1.6 | BSD-3-Clause | File system paths |
| flutter_local_notifications | 18.0.1 | BSD-3-Clause | Local notifications |
| intl | 0.20.3 | BSD-3-Clause | Internationalization |
| uuid | 4.6.0 | MIT | UUID generation |
| crypto | 3.0.7 | BSD-3-Clause | SHA-256 for checksum |
| shared_preferences | 2.5.5 | BSD-3-Clause | Simple key-value storage |
| equatable | 2.1.0 | BSD-3-Clause | Value equality |
| timezone | 0.10.1 | BSD-3-Clause | Timezone support |

## Third-Party Assets

### LLM Model (Future)
- **Candidate**: Qwen3 0.6B GGUF
- **License**: Apache 2.0
- **Source**: To be determined (official Qwen/HuggingFace distribution)
- **SHA-256**: To be verified upon download

## Data Privacy

- All motorcycle and complaint data is stored locally in SQLite on the device
- No data is transmitted to external servers during normal operation
- Uninstalling the app removes all data (unless backed up)
- AI model (when downloaded) is stored in app-private directory

## No Inappropriate Data Usage

BuildHaus does not:
- Collect personal information without consent
- Send motorcycle/location data to third parties
- Use scraped or illegally obtained data
- Include fake or fabricated sparepart pricing as official data
