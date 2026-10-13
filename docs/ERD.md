# BuildHaus ERD — 22 Tables

## Mermaid ERD Diagram

```mermaid
erDiagram
    MOTORCYCLE_MODELS {
        int id PK
        string brand
        string model
        string variant
        string generation
        int year_start
        int year_end
        string source_url
        datetime verified_at
    }

    MOTORCYCLES {
        int id PK
        int model_id FK
        string nickname
        int manufacture_year
        string plate_number
        string emoji
        string usage_profile
        datetime created_at
        datetime updated_at
        bool is_primary
    }

    ODOMETER_LOGS {
        int id PK
        int motorcycle_id FK
        real odometer_km
        datetime recorded_at
        string source
        string note
    }

    COMPONENT_TYPES {
        int id PK
        string name
        string category
        bool safety_critical
        string applies_to
    }

    MAINTENANCE_RULES {
        int id PK
        int model_id FK
        int component_type_id FK
        real interval_km
        int interval_days
        string severe_use_rule
        string source_url
        string rule_version
        datetime verified_at
    }

    COMPONENT_STATUSES {
        int id PK
        int motorcycle_id FK
        int component_type_id FK
        string estimated_status
        real score
        string explanation
        real confidence
        datetime calculated_at
        string rule_version
    }

    SERVICE_RECORDS {
        int id PK
        int motorcycle_id FK
        datetime serviced_at
        real odometer_km
        string workshop_name
        string notes
        int total_cost
        datetime created_at
    }

    SERVICE_ITEMS {
        int id PK
        int service_record_id FK
        int component_type_id FK
        int sparepart_id FK
        string action
        int parts_cost
        int labor_cost
        int total_cost
        string notes
    }

    SELF_INSPECTIONS {
        int id PK
        int motorcycle_id FK
        datetime inspected_at
        string notes
        string risk_level
        string status
    }

    INSPECTION_ANSWERS {
        int id PK
        int inspection_id FK
        string question_code
        string answer
        string answer_type
        bool risk_flag
    }

    COMPLAINTS {
        int id PK
        int motorcycle_id FK
        int inspection_id FK
        int resolved_by_service_id FK
        string title
        string description
        string status
        datetime opened_at
        datetime closed_at
        real odometer_km
        datetime updated_at
    }

    COMPLAINT_MESSAGES {
        int id PK
        int complaint_id FK
        string role
        string content
        datetime created_at
        string analysis_mode
    }

    COMPLAINT_ANALYSES {
        int id PK
        int complaint_id FK
        string symptoms_json
        string component_candidates_json
        string follow_up_json
        string historical_matches_json
        string risk_level
        string summary
        string model_version
        string analysis_mode
        datetime analyzed_at
    }

    CATALOG_SOURCES {
        int id PK
        string provider_name
        string website_url
        string license_or_permission
        datetime verified_at
        datetime last_checked_at
    }

    SPAREPARTS {
        int id PK
        int source_id FK
        string part_number
        string name
        string brand
        string category
        int reference_price
        string product_url
        datetime price_updated_at
        string catalog_version
        bool is_verified
    }

    SPAREPART_FITMENTS {
        int id PK
        int sparepart_id FK
        int model_id FK
        int year_start
        int year_end
        string notes
        datetime verified_at
        string source_url
    }

    BUDGET_PLANS {
        int id PK
        int motorcycle_id FK
        int budget_amount
        string period
        datetime created_at
        string notes
    }

    SERVICE_RECOMMENDATIONS {
        int id PK
        int budget_plan_id FK
        int estimated_total
        string rule_version
        datetime generated_at
        string data_freshness
        string explanation
    }

    RECOMMENDATION_ITEMS {
        int id PK
        int recommendation_id FK
        int component_type_id FK
        int sparepart_id FK
        string priority
        string decision
        int estimated_cost
        int estimated_labor_cost
        string reason
        string consequence_if_delayed
        bool requires_inspection
    }

    LOCAL_REMINDERS {
        int id PK
        int motorcycle_id FK
        int component_type_id FK
        string reminder_type
        real due_odometer_km
        datetime due_date
        bool enabled
        datetime last_scheduled_at
        int notification_id
    }

    AI_MODEL_INSTALLS {
        int id PK
        string model_name
        string version
        string file_path
        string sha256
        int file_size_bytes
        string download_status
        datetime installed_at
        string source_url
        string last_error
    }

    APP_SETTINGS {
        string key PK
        string value
        datetime updated_at
    }

    MOTORCYCLE_MODELS ||--o{ MOTORCYCLES : "1:N"
    MOTORCYCLES ||--o{ ODOMETER_LOGS : "1:N"
    MOTORCYCLES ||--o{ COMPONENT_STATUSES : "1:N"
    MOTORCYCLES ||--o{ SERVICE_RECORDS : "1:N"
    MOTORCYCLES ||--o{ SELF_INSPECTIONS : "1:N"
    MOTORCYCLES ||--o{ COMPLAINTS : "1:N"
    MOTORCYCLES ||--o{ BUDGET_PLANS : "1:N"
    MOTORCYCLES ||--o{ LOCAL_REMINDERS : "1:N"
    COMPONENT_TYPES ||--o{ MAINTENANCE_RULES : "1:N"
    COMPONENT_TYPES ||--o{ COMPONENT_STATUSES : "1:N"
    COMPONENT_TYPES ||--o{ SERVICE_ITEMS : "1:N"
    COMPONENT_TYPES ||--o{ RECOMMENDATION_ITEMS : "1:N"
    MAINTENANCE_RULES }o--|| MOTORCYCLE_MODELS : "N:1"
    SERVICE_RECORDS ||--o{ SERVICE_ITEMS : "1:N"
    SELF_INSPECTIONS ||--o{ INSPECTION_ANSWERS : "1:N"
    COMPLAINTS ||--o{ COMPLAINT_MESSAGES : "1:N"
    COMPLAINTS ||--o{ COMPLAINT_ANALYSES : "1:N"
    COMPLAINTS }o--|| SELF_INSPECTIONS : "0..1:0..1"
    COMPLAINTS }o--|| SERVICE_RECORDS : "0..1:0..1"
    CATALOG_SOURCES ||--o{ SPAREPARTS : "1:N"
    SPAREPARTS ||--o{ SPAREPART_FITMENTS : "1:N"
    SPAREPART_FITMENTS }o--|| MOTORCYCLE_MODELS : "N:1"
    BUDGET_PLANS ||--o{ SERVICE_RECOMMENDATIONS : "1:N"
    SERVICE_RECOMMENDATIONS ||--o{ RECOMMENDATION_ITEMS : "1:N"
    AI_MODEL_INSTALLS ||--|| : "standalone"
    APP_SETTINGS ||--|| : "standalone"
```

## Relationships Summary

| Parent | Child | Type |
|--------|-------|------|
| motorcycle_models | motorcycles | 1:N |
| motorcycles | odometer_logs | 1:N |
| motorcycles | component_statuses | 1:N |
| motorcycles | service_records | 1:N |
| motorcycles | self_inspections | 1:N |
| motorcycles | complaints | 1:N |
| motorcycles | budget_plans | 1:N |
| motorcycles | local_reminders | 1:N |
| motorcycle_models | maintenance_rules | 1:N |
| motorcycle_models | sparepart_fitments | 1:N |
| component_types | maintenance_rules | 1:N |
| component_types | component_statuses | 1:N |
| component_types | service_items | 1:N |
| component_types | recommendation_items | 1:N |
| component_types | local_reminders | 0..1:N |
| service_records | service_items | 1:N |
| self_inspections | inspection_answers | 1:N |
| complaints | complaint_messages | 1:N |
| complaints | complaint_analyses | 1:N |
| complaints | self_inspections | 0..1:0..1 |
| complaints | service_records | 0..1:0..1 |
| catalog_sources | spareparts | 1:N |
| spareparts | sparepart_fitments | 1:N |
| budget_plans | service_recommendations | 1:N |
| service_recommendations | recommendation_items | 1:N |
| ai_model_installs | standalone | - |
| app_settings | standalone | - |
