# Done-It Project Memory

## Project Structure
- 3 repos: `done-it-api` (Django), `done-it-web` (React/Vite), `done-it-mobile` (React Native/Expo)
- Backend: Django 4.2 LTS + DRF 3.15, 8 apps under `apps/`, 3 API versions (v1/v2/v3)
- ~89K LOC total across all repos

## Key Files
- `config/settings.py` - All Django config including REST_FRAMEWORK, CELERY, CORS/CSRF
- `apps/cauth/permissions.py` - 8 permission classes (5-tier role hierarchy)
- `apps/core/views.py` - LoggingViewMixin used by most views
- `apps/projects/signals.py` - 663 lines of webhook signal handlers (highly duplicated)
- `apps/be_ss/client/` - Belgian Social Security SOAP/REST integration

## Review Document
- `review_done_it.md` - Complete 19-section review document
- `review_plan.md` - Execution plan for the review
- Phase 1 (Backend Deep Dive) sections 6-14 completed in full
- All sections 1-19 filled, no _TODO_ markers remaining

## Known Issues Found
- `ProjectViewSet.get_permissions()` bug at line 73-74 (dead code)
- 33 dependency vulnerabilities (13 backend, 17 web, 3 mobile)
- Non-expiring auth tokens
- No CI/CD pipeline
- Zero frontend/mobile tests
- Signal handler duplication (~380 lines)
- CELERY_BROKER_USE_SSL with CERT_NONE

## Patterns
- `for_user()` static methods on 7 models for row-level access control
- Webhook dispatch via Django signals + Celery tasks
- v1/v2 serializers have ~60% code overlap
- Use `mermaid` syntax for diagrams in review docs
- Use lists instead of tables when requested
