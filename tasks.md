# Kubuni Business Institute — E-Learning Platform

## Delivery Plan & Task Breakdown (`tasks.md`)

Companion to `project.md`. Tasks are grouped into **phases** that are roughly
sequential but allow parallel work where noted. Each phase has a **Definition
of Done (DoD)**. Check items off as you go.

**Legend:** `[BE]` backend/context · `[FE]` LiveView/UI · `[INFRA]` ops ·
`[EXT]` external provider · `FUTURE` = deliberately deferred to v2.

> **Critical path:** Phase 0 → 1 → 2 → 3 (video) → 4 (payments) → 5 → 6. Phases
> 7–9 can overlap once their dependencies land. Phase 3 and Phase 4 are the two
> riskiest (external providers) — start provider account/sandbox setup early,
> in parallel with Phase 1–2.

---

## Phase 0 — Foundations & Project Setup

**Goal:** A running Phoenix app with CI, tooling, and brand scaffolding.

- [ ] `[INFRA]` Create Phoenix 1.8 app (LiveView, Postgres, Tailwind, esbuild).
- [ ] `[INFRA]` Repo + GitHub Actions: `mix format --check`, `credo`, `mix test`.
- [ ] `[BE]` Add core deps: `oban`, `swoosh`, `money`/`ex_money`, `chromic_pdf`
      (or `typst`), `mox`, `sentry`, HTTP client (`req`).
- [ ] `[BE]` Configure Oban (queues: `payments`, `certificates`, `mailers`,
      `default`) + migration.
- [ ] `[INFRA]` Dotenv/secrets strategy for dev; document required env vars.
- [ ] `[FE]` Brand foundation: Tailwind theme (navy + orange on white),
      base layout, fonts, shared components, favicon placeholder.
- [ ] `[INFRA]` Provision Fly.io app + Postgres + R2 bucket (empty), set up
      staging.
- [ ] `[EXT]` **Kick off provider accounts now** (parallel): Daraja sandbox,
      Paystack test, video provider (Mux/Cloudflare/Bunny) trial. _(Long lead
      time — don't block.)_

**DoD:** App boots locally and on staging; CI green; brand layout renders.

---

## Phase 1 — Accounts & Authentication

**Goal:** Learners can register, confirm, and log in securely.

- [ ] `[BE]` `mix phx.gen.auth Accounts User users` (email/password +
      confirmation).
- [ ] `[BE]` Extend `users` with `phone` (required) + `role`
      (`learner`/`admin`); migration + changeset validation.
- [ ] `[BE]` Phone normalisation to `2547XXXXXXXX` (used later for M-Pesa).
- [ ] `[FE]` Style register / login / confirm / reset pages to brand.
- [ ] `[BE]` Role-based access plug/helper; seed one admin user.
- [ ] `[BE]` Welcome email scaffold (wired in Phase 7).
- [ ] `[BE]` Tests: registration, confirmation, login, phone validation, role gate.

**DoD:** A learner can sign up, confirm by email, and log in; an admin user exists.

---

## Phase 2 — Catalog & Admin CRUD

**Goal:** Admins can create the course structure; learners can browse it.

- [ ] `[BE]` Schemas + migrations: `Course`, `CourseModule` (table `modules`),
      `Lecture` (with `video_asset_id` placeholder, `position`, `duration`).
- [ ] `[BE]` `Catalog` context API: list/get published courses, ordered modules
      & lectures, publish/draft.
- [ ] `[FE]` Admin LiveView: CRUD courses/modules/lectures + drag-to-reorder.
      _(Or Backpex accelerator — see project.md §11.)_
- [ ] `[FE]` Public course catalogue + course detail page (gated content hidden).
- [ ] `[BE]` `priv/repo/seeds.exs`: seed _"The Human Stack"_ course + its **6
      modules** (lecture rows filled once content arrives by email).
- [ ] `[BE]` Tests: catalog queries, ordering, publish gating.

**DoD:** Admin can build a course; the first course (6 modules) is seeded and
visible in the catalogue.

---

## Phase 3 — Video Integration & Protected Playback

**Goal:** Enrolled-only, signed, non-downloadable HLS playback.
_(Depends on a provider decision; start the spike early.)_

- [ ] `[EXT]` **Decide & finalise video provider** (Mux / Cloudflare Stream /
      Bunny). Document cost & DRM options.
- [ ] `[BE]` Define `Media` behaviour + adapter: `create_upload/1`,
      `playback_token/3`.
- [ ] `[FE]` Admin video upload via **provider direct-upload**; store returned
      `asset_id` + duration on the lecture.
- [ ] `[BE]` Server-side **signed playback token** minting — gated behind the
      enrollment check (returns 403 without active enrollment).
- [ ] `[FE]` Lecture player LiveView + JS hook (provider player / `hls.js`),
      `timeupdate`/`ended` → server.
- [ ] `[FE]` Protection deterrents: disable right-click/context menu, dynamic
      **email watermark** overlay.
- [ ] `[BE]` Tests (Mox): token issued only with active enrollment; denied
      otherwise.

**DoD:** An enrolled test user streams a protected lecture; an un-enrolled user
cannot obtain a token or play.

---

## Phase 4 — Enrollment & Payments

**Goal:** Pay before access; real-time unlock; receipts. **The core invariant.**

### 4a. Enrollment & gate

- [ ] `[BE]` `Enrollment` schema/migration (`unique(user_id, course_id)`,
      status `pending`/`active`).
- [ ] `[BE]` `Enrollments` API — the single authority for "can access course?"
      Wire this gate into Catalog/Media access paths.

### 4b. Payment core

- [ ] `[BE]` `Payment` schema/migration (`provider_reference` UNIQUE,
      `amount_minor`, `status`, `raw_payload` jsonb).
- [ ] `[BE]` `Payments` behaviour + lifecycle (`pending → successful/failed`),
      idempotent.

### 4c. M-Pesa (Daraja STK Push)

- [ ] `[EXT]` Daraja credentials (sandbox → prod): shortcode, passkey, keys.
- [ ] `[BE]` STK Push client (`initiate`) + auth token handling.
- [ ] `[BE]` Callback controller → enqueue `ProcessMpesaCallback` (Oban,
      idempotent).
- [ ] `[BE]` On success: mark payment, **activate enrollment**, broadcast
      `:payment_confirmed` on `"user:{id}"`.
- [ ] `[BE]` `ReconcilePayments` Oban cron (STK status query for stale pendings).

### 4d. Paystack (card + regional)

- [ ] `[EXT]` Paystack keys + webhook secret.
- [ ] `[BE]` Initialise transaction + checkout (inline/redirect).
- [ ] `[BE]` **Signature-verified** webhook → verify → activate enrollment.

### 4e. Checkout UX

- [ ] `[FE]` Checkout LiveView: choose method, M-Pesa "check your phone /
      waiting…" state, PubSub-driven **instant unlock + redirect**.
- [ ] `[FE]` Receipts/payment history on the learner account.
- [ ] `[BE]` Tests (Mox): STK success, missed-callback reconciliation, duplicate
      callback idempotency, Paystack webhook verify, gate stays closed until paid.

**DoD:** A test learner pays via M-Pesa **and** via Paystack; access unlocks in
real time; duplicate/missed callbacks handled; receipt recorded.

---

## Phase 5 — Progress Tracking

**Goal:** Learners track progress; completion is detected reliably.

- [ ] `[BE]` `LectureProgress` schema/migration (`unique(user_id, lecture_id)`,
      `last_position_seconds`, `status`).
- [ ] `[BE]` Upsert progress from player events; mark complete at ~95% or
      explicit action.
- [ ] `[BE]` Completion detection: lecture → **module complete?** → **course
      complete?** (emits events for certificates).
- [ ] `[FE]` Progress bars + per-module/lecture status; resume playback at last
      position.
- [ ] `[BE]` Tests: progress upsert, module-completion, course-completion edges.

**DoD:** Completing all lectures in a module flags the module complete; finishing
all modules flags the course complete.

---

## Phase 6 — Certificates

**Goal:** Auto-issued, branded, downloadable certificates (module + course).

- [ ] `[BE]` `Certificate` schema/migration (`type` module|course,
      `serial_number` UNIQUE, `file_key`).
- [ ] `[FE]` Branded Heex certificate template (logo, navy/orange, learner name,
      title, date, serial).
- [ ] `[BE]` `IssueCertificate` Oban worker (unique per user+scope): render via
      **ChromicPDF** → upload to **R2** → create row → broadcast ready.
- [ ] `[BE]` Trigger issuance from module/course completion events (Phase 5).
- [ ] `[FE]` Certificate download via **short-lived signed R2 URL** in dashboard.
- [ ] `[BE]` Tests: issued once per scope (idempotent), correct content/serial.

**DoD:** Completing a module issues a module certificate; completing the course
issues a course certificate; both download as branded PDFs.

---

## Phase 7 — Notifications (Email)

**Goal:** Key transactional emails, sent reliably off the request path.

- [ ] `[EXT]` Configure Swoosh provider (SES/Resend); verify sending domain.
- [ ] `[BE]` Mailers + Oban `mailers` jobs: **registration confirmation**,
      **payment confirmation**, **certificate issued**.
- [ ] `[FE]` Branded email templates.
- [ ] `[BE]` Tests: each event enqueues & renders the right email.

**DoD:** The three transactional emails fire on their events in staging.

---

## Phase 8 — Landing / Marketing Page & Branding Polish

**Goal:** A credible public home for the Institute.
_(Needs final brand assets — flag the dependency early.)_

- [ ] `[FE]` Landing page: mission, value prop, course catalogue CTA.
- [ ] `[FE]` Apply **final** logo + exact navy/orange hex codes once provided.
- [ ] `[FE]` Mobile-responsive pass across all pages (smartphone-first audience).
- [ ] `[FE]` Basic SEO/meta, OG tags, favicon, 404/500 pages.

**DoD:** Landing page live and on-brand; whole app verified responsive on mobile.

---

## Phase 9 — Admin Polish & Basic Analytics

**Goal:** Operable platform + minimal insight.

- [ ] `[FE]` Admin: learner list, enrollment/payment views, manual
      "verify/reconcile payment".
- [ ] `[BE]` Basic analytics (Ecto aggregates): registrations, payments (count/
      sum/success rate), completion rates — shown in admin.
- [ ] `[FE]` Live admin dashboard (PubSub: new registrations/payments appear
      live).

**DoD:** Admin can manage learners/payments and see basic platform numbers.

---

## Phase 10 — Hardening, QA, Launch & Handover

**Goal:** Production-ready, documented, handed over.

- [ ] `[BE]` Security pass: server-side gate audit, webhook auth, rate-limiting
      (auth + payment init), signed-download checks.
- [ ] `[INFRA]` Observability: Sentry/AppSignal, LiveDashboard, payment
      telemetry/alerts.
- [ ] `[INFRA]` Backups (DB), restore drill, runbook for failed payments.
- [ ] `[BE]` **Switch providers to production** (Daraja prod shortcode, Paystack
      live, video, SES out of sandbox).
- [ ] `[BE]` Load the **real first-course content** (6 modules) + videos.
- [ ] `[BE]` End-to-end UAT: register → pay (M-Pesa & card) → watch → complete →
      certificate → email.
- [ ] `[INFRA]` Custom domain + TLS/HSTS; production deploy.
- [ ] `[DOCS]` **Handover notes** (brief §7): how to upload courses/modules/
      videos, manage learners, manage/verify payments.

**DoD:** All brief §3 requirements met, first course live, handover docs
delivered.

---

## Deliverables Mapping (Brief §7)

| Brief deliverable                                  | Where it's satisfied                     |
| -------------------------------------------------- | ---------------------------------------- |
| Technical proposal (architecture, stack, payments) | `project.md`                             |
| Timeline & cost estimate                           | Phasing below + separate quote           |
| Working platform meeting §3                        | Phases 1–6 (core), validated in Phase 10 |
| First course loaded (§4)                           | Phase 2 (seed) + Phase 10 (real content) |
| Handover/admin docs                                | Phase 10 `[DOCS]`                        |

---

## Indicative Timeline (rough, one experienced Elixir dev)

| Phase                          | Est.                                              |
| ------------------------------ | ------------------------------------------------- |
| 0 Foundations                  | 0.5 wk                                            |
| 1 Accounts                     | 0.5 wk                                            |
| 2 Catalog + admin              | 1 wk                                              |
| 3 Video                        | 1–1.5 wk                                          |
| 4 Payments (M-Pesa + Paystack) | 1.5–2 wk                                          |
| 5 Progress                     | 0.5 wk                                            |
| 6 Certificates                 | 1 wk                                              |
| 7 Notifications                | 0.5 wk                                            |
| 8 Landing/branding             | 0.5–1 wk                                          |
| 9 Admin/analytics              | 0.5 wk                                            |
| 10 Hardening/launch            | 1 wk                                              |
| **Total**                      | **~8–10 weeks** (+ buffer for provider approvals) |

> Daraja **production** go-live approval and final brand/content assets are the
> most common external delays — start both early.

---

## Immediate Next Actions

1. Confirm the **open questions** in `project.md` §17 (price, currency, provider
   choices, credentials).
2. Start **provider onboarding** (Daraja, Paystack, video) — long lead times.
3. Execute **Phase 0** and stand up staging.
4. Get **first-course module content** (titles, objectives, video breakdown) so
   Phase 2 seeds aren't placeholders.
