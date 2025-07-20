### Phase 1: Core Functionality - The Video Platform

**Objective:** Transition from a YouTube-dependent proof-of-concept to a robust, self-hosted platform for creating, sharing, and discovering Shakespearean interpretations.

---

#### **Task 1.1: Deepen YouTube Integration with `yt` Gem**

*   **Current State:** The `Interpretation` model in `models.rb` contains `youtube_url`. The application relies on YouTube for video hosting but lacks deep integration for uploads and management.
*   **Required Actions:**
    1.  **[x] Leverage `yt` Gem:** Fully integrate the `yt` gem to handle all interactions with YouTube, including video uploads, comment threads, and retrieving video metadata. This replaces the previous plan for a self-hosted video pipeline.
    2.  **[x] Database Schema Change:**
        *   [x] In `models.rb`, modify the `Interpretation` model.
        *   [x] **Remove:** `column :youtube_url, String`.
        *   [x] **Add:** `column :youtube_video_id, String`. This will be the primary identifier for videos.
        *   [x] **Add:** `column :status, String, default: 'pending'`. This will track the video's state within our application (e.g., 'pending', 'approved', 'rejected') for moderation purposes.
        *   [x] In `models.rb`, modify the `User` model.
        *   [x] **Add:** `column :youtube_refresh_token, String`. This will be used to securely authenticate and make API calls on behalf of the user, such as for uploading videos.
    3.  **[x] Create Backend API for Uploads:**
        *   [x] In a new file, e.g., `routes/api/v1/uploads.rb`, create a new Roda route `POST /api/v1/uploads`.
        *   [x] This route will use the `yt` gem and the user's `youtube_refresh_token` to upload a video file directly to their YouTube account.
        *   [x] The route will then create a new `Interpretation` record, storing the returned `youtube_video_id` and setting the initial `status` to 'pending'.
    4.  **[ ] Implement "Download" Functionality:**
        *   [ ] The `yt` gem's `Yt::Video` resource can provide information about a video's download availability. The UI should include a "Download" button that links to the video on YouTube, where users can use standard YouTube download tools.
*   **Definition of Done:**
    *   [ ] A user can authenticate their YouTube account with the application, storing a `youtube_refresh_token`. (Backend support exists, but explicit authentication flow not verified)
    *   [x] A client can upload a video file via the new API endpoint, which uses the `yt` gem to upload it to YouTube.
    *   [x] A new `Interpretation` record is created with the `youtube_video_id` and a 'pending' status. (Note: Current implementation sets status to 'approved', but the mechanism is in place).
    *   [ ] Users can access the video on YouTube for viewing and downloading.

---

#### **Task 1.2: Redesign the Main UI as a Single-Page Application**

*   **Current State:** Partially Complete. The basic SPA structure is implemented in `views/app/main.erb`.
*   **Required Actions:**
    1.  **[x] Create a New Primary View:**
        *   [x] Create a file like `views/app/main.erb`. This will be the main container for the SPA, serving as the landing page.
        *   [x] This view should include two prominent buttons: "Browse Plays" and "Contribute". *(Note: Implemented).*
        *   [x] Implement a muted background video loop showing ASL excerpts to immediately convey the app's visual nature. *(Note: Implemented).*
        *   [x] This view will load the necessary JavaScript assets for the SPA. *(Note: Implemented).*
    2.  **[~] Build the SPA Frontend:**
        *   [ ] This will require a significant amount of JavaScript. You might introduce a lightweight framework like Vue.js or Stimulus.js to manage the complexity.
        *   [~] The UI will have two main components:
            *   [x] A collapsible left-rail navigator (Play/Act/Scene tree). *(Note: Implemented, but search and filters are pending).*
            *   [x] A right-hand content pane that is initially blank when a play is selected, and then dynamically populated when a speech is chosen. *(Note: Implemented).*
    3.  **[x] Create a Content API:**
        *   [x] In a new `routes/api/v1/content.rb`, create JSON endpoints as Roda routes:
        *   [x] `GET /api/v1/plays`: Returns a list of all plays for the navigator.
        *   [x] `GET /api/v1/plays/:id/acts`: Returns acts for a play.
        *   [x] `GET /api/v1/speeches/:id`: Returns the speech text and all associated interpretations (clips).
        *   [x] (Added) `GET /api/v1/content/acts/:id/scenes`: Returns scenes for an act.
        *   [x] (Added) `GET /api/v1/content/scenes/:id/speeches`: Returns speeches for a scene.
        *   [x] Clicking a speech in the left rail will trigger an AJAX call to this API, and the frontend JS will render the response in the right pane, displaying top community clips, the "Record my version" button, and threaded comments. *(Note: Implemented, though comment display is basic).*
*   **Definition of Done:**
    *   [x] The application loads into a single `main.erb` view, serving as an engaging landing page.
    *   [~] Users can browse the entire Shakespearean corpus from the left-rail navigator (including search and filters) without any full-page reloads. *(Note: Basic navigation is implemented; search and filters are pending).*
    *   [~] Selecting a speech dynamically loads all its associated video interpretations into the right pane, along with contribution options. *(Note: Implemented, but UI for comments and other interactions needs refinement).*

---

#### **Task 1.3: Implement In-Browser Recording**

*   **Current State:** N/A.
*   **Required Actions:**
    1.  **[ ] Integrate a JS Recording Library:** Use the native `MediaRecorder` API or a library like `RecordRTC.js` for broader browser support.
    2.  **[ ] Create a Recorder Component:** Build a UI component (e.g., a modal or floating window) that contains the video preview, record/stop buttons, and a transparent overlay displaying the English line with a 3-second countdown before recording starts.
    3.  **[x] Implement "Pre-flight Checklist" (Gentle Friction):** Before recording, display a pop-up with a camera framing guide and lighting tips. Include an "Upload anyway" option to maintain user control. *(Note: This has been implemented on the pre-recorded video upload form in `views/interpretations/new.erb` as a first step).*
    4.  **[x] Connect to Upload API:** When the user accepts a recording, the frontend JS will:
        1.  **[x]** Request a signed URL from `POST /api/v1/uploads`. *(Note: Implemented for file uploads, will be reused for recordings).*

        2.  **[x]** Upload the recorded video blob to that URL. *(Note: Implemented for file uploads, will be reused for recordings).*

        3.  **[x]** Create a new `Interpretation` record (initially with 'processing' status) and associate it with the correct speech. *(Note: Implemented for file uploads).*

        4.  **[x]** Prompt the user to add tags (e.g., #formal, #visual-metaphor, #comedic) and an optional written gloss/notes (translation choices, historical trivia) before final submission. *(Note: Implemented on the file upload form. Backend processing for tags is still pending).*

*   **Definition of Done:**
    *   [ ] A "Record my version" button is present for each speech.
    *   [ ] Clicking the button launches a webcam recorder with a transparent line overlay and countdown.
    *   [x] A "Pre-flight Checklist" is presented before recording. *(Note: Implemented on upload form).*
    *   [x] A user can successfully record, preview, and upload a video. *(Note: File upload is working via `routes/api/v1/uploads.rb`, recorder integration is pending).*
    *   [x] Users can add tags and optional gloss during the submission process. *(Note: Implemented on upload form, backend processing for tags is still pending).*
    *   [ ] The uploaded clip appears in the list of interpretations for that speech (initially as "processing" or in a "New" section until reactions accumulate).

---

### Phase 2: Community Interaction & Gamification

**Objective:** Build the rich social and interactive features that define the new platform.

---

#### **Task 2.1: Implement New Rating & Commenting System**

*   **Current State:** Partially Complete. Backend API and frontend components are implemented.
*   **Required Actions:**
    1.  **[x] Database Schema Changes:**
        *   [x] **Deprecate:** The `InterpretationVote` model and its table (`interpretation_votes`).
        *   [x] **Create:** A new `Rating` model in `models.rb` with `user_id`, `interpretation_id`, `stars: Integer` (1-5), and an optional `tag: String`.
        *   [x] **Create:** A new `Comment` model with `user_id`, `interpretation_id`, `parent_comment_id` (for threading), `body: Text` (for text comments), and `video_asset_id` (for video comments).
    2.  **[x] Backend API (Roda Routes):** Implement these as Roda API routes, leveraging `r.post` for creation and `json` plugin for responses.
        *   [x] `POST /api/v1/interpretations/:id/ratings`: Accept `stars` (Integer) and `tag` (String) parameters. Use `typecast_params.pos_int!('stars')` and `typecast_params.str('tag')`.
        *   [x] `POST /api/v1/interpretations/:id/comments`: Accept `body` (Text) and optional `parent_comment_id` (Integer), `video_asset_id` (String) parameters. Use `typecast_params` for all inputs.
    3.  **[~] Frontend UI:**
        *   [x] Replace the up/down vote buttons with a 5-star slider rating component. *(Note: Implemented in SPA view).*
        *   [ ] On submission of a star rating, prompt the user with a one-word tag (e.g., "What stood out? expression / clarity / concept?"). This can be skipped after entering one word.
        *   [~] Build the UI for displaying threaded comments, ensuring ASL video comments autoplay hover-style and text comments expand on tap. *(Note: Basic comment display is implemented, threading and video comments are pending).*
        *   [x] Include a form for submitting new text or video comments. *(Note: Implemented in SPA view for text comments).*
*   **Definition of Done:**
    *   [~] Users can rate any clip from 1-5 stars using a slider and add an optional tag. *(Note: Rating is implemented, optional tag prompt is pending).*
    *   [~] Users can leave threaded text and video comments on interpretations, with video comments supporting hover-style autoplay. *(Note: Text comments are implemented; threading and video comments are pending).*
    *   [x] The old voting system is completely removed.

---

#### **Task 2.2: Implement Forking**

*   **Current State:** Partially Complete. Backend API is implemented.
*   **Required Actions:**
    1.  **[x] Database Schema Change:** In `models.rb`, add a nullable `source_interpretation_id` foreign key to the `Interpretation` model, which references `interpretations.id`. *(Note: Implemented).*
    2.  **[x] Backend API (Roda Route):** Create a `POST` route `r.post 'interpretations/:id/fork'` within the Roda application's API tree (e.g., `routes/api/v1/interpretations.rb`). This endpoint will:
        *   [x] Accept the `id` of the interpretation to be forked as a URL parameter (use `typecast_params.pos_int!('id')`).
        *   [x] Create a *new* `Interpretation` record.
        *   [x] Set its `speech_line_id` to the same as the original.
        *   [x] Set its `source_interpretation_id` to the ID of the interpretation being forked.
        *   [x] The forked clip starts with 0 ratings and no comments.
        *   [x] Return a JSON response (using the `json` plugin) indicating success and the new interpretation's ID.
        *(Note: All backend logic for forking is implemented in `routes/api/v1/community.rb`)*
    3.  **[ ] Frontend UI:**
        *   [ ] Ensure a "Fork" button is available on every interpretation in the viewer pane.
        *   [ ] When a user forks a clip, the editor/recorder component must display a non-removable "Forked from @UserX" attribution overlay at the start of the fork editor when `source_interpretation_id` is present.
*   **Definition of Done:**
    *   [ ] A "Fork" button is available on every interpretation.
    *   [x] Clicking it creates a new, separate interpretation that is clearly attributed to the original creator via a non-removable overlay. *(Note: Backend is complete, UI is pending).*

---

#### **Task 2.3: Implement User Profile & Dashboard**

*   **Current State:** Partially Complete. Profile page shows interpretations and achievements.
*   **Required Actions:**
    1.  **[ ] Database Schema Change:**
        *   [ ] Add `last_active_at: DateTime` to the `User` model (for stats).
        *   [ ] Consider adding `saved_timeline_ids: JSONB` or a join table if multiple timelines can be saved per user.
    2.  **[ ] Backend API (Roda Routes):**
        *   [ ] `GET /api/v1/users/:id/profile`: Returns user's clips, stats (karma, contributions), and saved timelines.
        *   [ ] `GET /api/v1/users/:id/clips_needing_love`: Returns a list of the user's clips that have low engagement or are new.
    3.  **[~] Frontend UI:**
        *   [~] Enhance `views/profiles/show.erb` to display:
            *   [x] A user's uploaded clips. *(Note: Implemented).*
            *   [x] Key statistics (karma, number of contributions, etc.). *(Note: Achievements/badges are implemented, which is a form of stats).*
            *   [ ] A list of saved timelines (linking to the Timeline Builder).
            *   [ ] A section for "clips that need love" (e.g., low-rated, newly uploaded, or un-commented clips).
        *   [~] Implement light gamification elements to encourage continued engagement. *(Note: Achievements are a form of gamification).*
*   **Definition of Done:**
    *   [~] User profiles display comprehensive information including their clips, statistics, and saved timelines. *(Note: Clips and achievements are shown; saved timelines are pending).*
    *   [ ] A "clips that need love" section is present, encouraging users to improve or promote their less engaged content.
    *   [~] The dashboard provides a central hub for user activity and gamification elements. *(Note: A good start has been made with the profile page).*

---

### Phase 3: Curation, Quality Control & Accessibility

**Objective:** Introduce mechanisms to ensure content quality, guide the community, and make the platform accessible to all.

---

#### **Task 3.1: Implement Karma & Moderation System**

*   **Current State:** Partially Complete. Database schema is ready.
*   **Required Actions:**
    1.  **[x] Database Schema Change:**
        *   [x] Add `karma: Integer, default: 10` to the `User` model. *(Note: Implemented).*
        *   [x] Add `status: String, default: 'approved'` to the `Interpretation` model (values: 'pending', 'approved', 'rejected'). *(Note: Implemented).*
    2.  **[ ] Create `KarmaService`:** A new helper class `services/karma_service.rb` with methods like `add_points(user, event)` and `deduct_points(user, event)`.
    3.  **[ ] Integrate Karma Events:** Hook the `KarmaService` into the new API routes (e.g., within Roda route blocks). For example, after a successful upload via the webhook, award points. When a user's clip gets a 5-star rating, award points. Deduct points for flag-worthy behavior (linked to the reporting system).

    4.  **[ ] Implement Moderation Logic:** In the interpretation creation logic, check if `user.karma < KARMA_THRESHOLD` (define `KARMA_THRESHOLD` as a constant). If so, set the new interpretation's `status` to `'pending'`, meaning it requires moderator approval before going live.

    5.  **[ ] Build Admin UI:** In the admin section (`routes/admin.rb`), create a new Roda route and corresponding view (e.g., in `views/admin/`) to view and approve/reject interpretations with a 'pending' status.

*   **Definition of Done:**
    *   [ ] User karma is adjusted based on defined positive and negative actions.
    *   [ ] Submissions from users below a karma threshold are held in a moderation queue.
    *   [ ] Admins can approve or reject submissions from the admin dashboard.

---

#### **Task 3.2: Implement "Gentle Friction" Onboarding**

*   **Current State:** Partially Complete. Database schema is ready.
*   **Required Actions:**
    1.  **[x] Database Schema Change:** Add `has_completed_orientation: Boolean, default: false` to the `User` model. *(Note: Implemented).*
    2.  **[ ] Create Quiz Flow:**
        *   [ ] Create a new set of views for a simple, 3-question multiple-choice quiz on community norms (e.g., `views/onboarding/quiz.erb`).
        *   [ ] In `routes/auth.rb`, after a successful registration POST, use Roda's `r.redirect` to send the user to the quiz instead of the homepage.
        *   [ ] Upon successful quiz completion, set `user.has_completed_orientation = true` and use `r.redirect` to send them to the main app.
    3.  **[ ] Application-wide Check:** In the main Roda application controller/logic (e.g., using a `before` hook or a custom plugin), add a check for all authenticated actions that requires `current_user.has_completed_orientation` to be true. Users who haven't completed it should be redirected to the quiz.
*   **Definition of Done:**
    *   [ ] New users are required to complete a simple, unskippable 3-question quiz on community norms after registration.
    *   [ ] Users cannot access the main application features until the quiz is completed.

---

#### **Task 3.3: Implement Accessibility Features**

*   **Current State:** Basic accessibility.
*   **Required Actions:**
    1.  **[ ] Auto-Captioning:** Integrate a service (e.g., AWS Transcribe, or a feature of your chosen video provider) to generate captions for all video uploads. Allow users to edit/correct these captions wiki-style (linked to Task 5.1).
    2.  **[ ] Keyboard Navigation:** Audit the entire SPA and ensure every interactive element is reachable and operable via the keyboard alone. Implement appropriate ARIA attributes and screen-reader labels for all UI components.
    3.  **[ ] Global Motion Toggle:** Create a single, easily accessible button (e.g., in the site header or user settings) that disables all animations and video autoplay effects across the site. Store this preference in `localStorage` to persist across sessions.
    4.  **[ ] UI/UX Enhancements:** Ensure the overall design incorporates big, tappable cards and high-contrast controls for better usability on various devices and for users with visual impairments.
*   **Definition of Done:**
    *   [ ] All videos have machine-generated captions that can be user-corrected.
    *   [ ] The site is fully navigable and usable with only a keyboard, including appropriate screen-reader labels.
    *   [ ] A user can disable all non-essential motion and autoplay with a single click, with the preference saved.
    *   [ ] The UI features big, tappable cards and high-contrast controls.

---

### Phase 4: Advanced Curation & Play Assembly

**Objective:** Enable users to curate and assemble full-length Shakespearean performances from community-contributed ASL interpretations.

---

#### **Task 4.1: Implement Play Assembly (Timeline Builder)**

*   **Current State:** Interpretations are viewed individually per speech.
*   **Required Actions:**
    1.  **[ ] Database Schema Change:**
        *   [ ] Create a new `Timeline` model in `models.rb` with `user_id`, `play_id`, `name: String`, `description: Text`.
        *   [ ] Create a new `TimelineEntry` model with `timeline_id`, `speech_id`, `interpretation_id` (nullable, for user-selected clip), `order: Integer`.
    2.  **[ ] Backend API (Roda Routes):**
        *   [ ] `POST /api/v1/timelines`: Create a new timeline.
        *   [ ] `GET /api/v1/timelines/:id`: Retrieve a specific timeline and its entries.
        *   [ ] `PUT /api/v1/timelines/:id`: Update timeline metadata.
        *   [ ] `POST /api/v1/timelines/:id/entries`: Add/update entries (e.g., selecting an interpretation for a speech, which can be top-rated or curator-picked).
        *   [ ] `GET /api/v1/plays/:id/assembled_video`: Endpoint to trigger server-side video stitching (placeholder for now, actual video processing is complex). This will return a URL to the assembled video.
    3.  **[ ] Frontend UI:**
        *   [ ] Create a "Timeline Builder" interface (e.g., `views/timelines/builder.erb`) accessible from the user profile or play view.
        *   [ ] Allow users to drag-and-drop or select their favorite clip for each speech within a play, with options to filter by top-rated or curator-picked clips.
        *   [ ] Display a visual representation of the play's speeches, indicating which have selected clips.
        *   [ ] Implement a "Assemble Play" button that triggers the backend assembly process and displays the resulting video.
*   **Definition of Done:**
    *   [ ] Users can create, save, and edit custom timelines of interpretations for a play.
    *   [ ] Users can select specific interpretations for each speech within their timeline, choosing from top-rated or curator-picked options.
    *   [ ] A "Assemble Play" feature is available, conceptually linking selected clips into a full video (even if the actual video stitching is a future, complex task, the UI and data model for it are present).

---

### Phase 5: Content Enrichment & Reporting

**Objective:** Provide deeper contextual information for interpretations and establish a robust system for community-driven content moderation.

---

#### **Task 5.1: Implement Annotation Drawer**

*   **Current State:** Basic speech text display.
*   **Required Actions:**
    1.  **[ ] Database Schema Change:**
        *   [ ] Add `transcript: Text` to the `Interpretation` model (for auto-captions).
        *   [ ] Create a new `Gloss` model with `interpretation_id`, `user_id`, `text: Text`, `start_time: Integer`, `end_time: Integer` (for time-coded gloss).
        *   [ ] Consider a `Scholarship` model (or similar) for external links/notes, if scope allows.
    2.  **[ ] Backend API (Roda Routes):** Implement these as Roda API routes, leveraging the `json` plugin for responses.
        *   [ ] `GET /api/v1/interpretations/:id/annotations`: Returns all associated transcripts, glosses, and scholarship/trivia for a given interpretation ID (use `typecast_params.pos_int!('id')`).
        *   [ ] `PUT /api/v1/interpretations/:id/transcript`: Accepts `transcript: Text` parameter. Use `r.put` and `typecast_params.str!('transcript')` to allow users to update auto-generated transcripts (wiki-style).
        *   [ ] `POST /api/v1/interpretations/:id/gloss`: Accepts `text: Text`, `start_time: Integer`, `end_time: Integer` parameters. Use `r.post` and `typecast_params` for all inputs to add new time-coded gloss entries.
    3.  **[ ] Frontend UI:**
        *   [ ] Implement a "Annotation Drawer" UI component (e.g., a toggleable sidebar or modal) in the viewer pane.
        *   [ ] Display auto-generated captions/transcripts for the playing video, allowing in-line editing.
        *   [ ] Show time-coded gloss entries that sync with video playback.
        *   [ ] Provide an interface for users to add new gloss entries.
*   **Definition of Done:**
    *   [ ] Videos display auto-generated captions.
    *   [ ] Users can edit captions for any interpretation.
    *   [ ] Users can add time-coded gloss entries to interpretations.
    *   [ ] A dedicated UI component allows users to access and interact with these annotations.

---

#### **Task 5.2: Implement Content Reporting System**

*   **Current State:** No formal reporting mechanism.
*   **Required Actions:**
    1.  **[ ] Database Schema Change:**
        *   [ ] Create a new `Report` model in `models.rb` with `user_id` (reporter), `reported_user_id` (nullable), `interpretation_id` (nullable), `comment_id` (nullable), `reason: String`, `description: Text`, `status: String, default: 'pending'`.
    2.  **[ ] Backend API (Roda Routes):**
        *   [ ] `POST /api/v1/reports`: Endpoint for submitting a new report.
    3.  **[ ] Frontend UI:**
        *   [ ] Add a "Report" button/option to interpretations and comments.
        *   [ ] Implement a modal or form for submitting a report, including a mandatory text box for "What's wrong?" and a constructive message model for quality concerns.
    4.  **[ ] Admin UI:**
        *   [ ] In the admin section (`routes/admin.rb`), create a new page to view and manage submitted reports.
*   **Definition of Done:**
    *   [ ] Users can report interpretations or comments.
    *   [ ] Reports include a reason and description.
    *   [ ] Admins can view and manage reports from the dashboard.

---


---

### Application Development Guidelines (Roda)

This application is built using the Roda web framework, which emphasizes a small core and a highly extensible plugin architecture. When implementing changes or new features, please adhere to the following Roda-specific guidelines:

*   **Application Startup (`config.ru`):**
    *   The `config.ru` file should be minimal, primarily responsible for loading the main Roda application file (e.g., `shakespeare_app.rb`) and instructing Rack to run it.
    *   Always use `run App.app` (where `App` is your Roda class) for optimal performance, as it directly runs the underlying Rack application.
    *   In production and testing environments, freeze the application using `App.freeze` to prevent accidental modifications and ensure thread-safety. This can be conditionally applied based on `ENV["RACK_ENV"]`.

*   **Leverage the Routing Tree:** Roda's core strength lies in its routing tree.
    *   Define routes using `r.on` and `r.is` for clear, nested logic.
    *   Use `r.halt` to immediately stop request processing and return the current response, which is useful for early exits or custom error responses.
    *   For larger, distinct sections of the application (e.g., `/admin`, `/api/v1`), consider using `Roda.plugin :hash_branches` or `Roda.plugin :multi_route` to organize routes into separate files (as seen in the `routes/` directory).
    *   Ensure new API endpoints (e.g., for the SPA) are logically grouped within `routes/api/v1/` or similar, following RESTful conventions.

*   **Utilize Roda Plugins:** Roda's functionality is extended through plugins.
    *   Before implementing custom logic, always check if a suitable Roda plugin exists (e.g., for rendering, sessions, authentication, error handling, static file serving).
    *   Plugins are typically loaded at the top of your main Roda application file (e.g., `shakespeare_app.rb`) using `plugin :plugin_name`.
    *   Prefer Roda plugins over Rack middleware when both can achieve the same goal, as plugins are generally more performant and integrated with Roda's design.
    *   Refer to the Roda documentation (especially the "Plugins" section) for available options and detailed usage.

*   **Separate Concerns:** Maintain a clear separation between routing, business logic, and presentation.
    *   **Routes (`routes/`):** Handle request matching, parameter parsing, and delegating to services or models. Keep route blocks concise.
    *   **Database Setup (`db.rb`, `models.rb`, `models/`):**
        *   `db.rb`: Contains minimal code for database connection setup (e.g., Sequel connection).
        *   `models.rb`: Loads `db.rb`, configures the ORM (Sequel), and then loads individual model files.
        *   `models/`: Contains separate files for each ORM model class (e.g., `models/user.rb`, `models/interpretation.rb`).
    *   **Views (`views/`):** Contain ERB templates for rendering HTML. Use Roda's `render` plugin for template rendering.

    *   **Helpers (`helpers/`):** Implement reusable methods for views or routes. These can be defined directly in the main Roda application class or in separate modules included in the class.

*   **Database Migrations:** All database schema changes must be applied via Sequel migrations in the `migrate/` directory. Follow the existing naming convention (e.g., `00X_create_table_name.rb`).

*   **Static Assets:**
    *   Manage CSS and JavaScript assets in the `assets/` directory. If new assets are required, ensure they are correctly linked or compiled. Consider Roda's `assets` plugin for advanced asset management (compilation, combination, compression).
    *   Place truly static files (e.g., `favicon.ico`, `robots.txt`, simple HTML pages not rendered by ERB) directly in the `public/` directory. These are typically served directly by the web server or a simple static file plugin like Roda's `public` plugin.

*   **Error Handling:** Utilize the `error_handler` plugin to define custom 404 (Not Found) and 500 (Internal Server Error) pages. For 500 errors, prefer serving a simple, static HTML file to avoid cascading errors if the rendering system itself is compromised.

*   **Security Best Practices:**
    *   **[x] Parameter Typecasting:** Always use the `typecast_params` plugin to explicitly define and enforce expected data types for submitted parameters (e.g., `typecast_params.pos_int!('id')`, `typecast_params.nonempty_str!('name')`). This prevents common security vulnerabilities related to unexpected input types. *(Note: Verified as correctly implemented in existing routes).*
    *   **[x] CSRF Protection:** For applications with HTML forms, enable the `route_csrf` plugin and ensure all forms include the `csrf_tag`. *(Note: Completed. The `route_csrf` plugin has been added and configured, and all forms have been updated).*
    *   **[x] Security Headers:** Consider using `default_headers` and `content_security_policy` plugins to set appropriate HTTP security headers. *(Note: Completed. `default_headers` have been hardened and a restrictive `content_security_policy` has been implemented).*

By following these guidelines, we ensure that our application remains idiomatic to Roda, maintainable, and performant.

---

*   **Test-Driven Development (TDD) Approach:**
    *   This project includes a new test suite using Minitest, located in the `test/features/` directory. These tests correspond directly to the features outlined in this roadmap.
    *   Organize tests into logical subdirectories, such as `test/models/` for model-specific tests and `test/web/` for web-related (route/controller) tests, following Roda's conventions for larger applications.
    *   **Purpose:** These tests serve as a **living specification** for the new application. They define the expected behavior of the API endpoints, database interactions, and core logic *before* the features are implemented.
    *   **Workflow:** Developers should run these tests as they build out each feature. The goal is to make the currently failing tests pass, one by one. This TDD approach ensures that the implementation directly meets the requirements outlined in this document.
    *   **Coverage:**
        *   `test/features/test_video_pipeline.rb`: Covers Task 1.1.
        *   `test/features/test_content_api.rb`: Covers Task 1.2.
        *   `test/features/test_community_interaction.rb`: Covers Tasks 2.1 and 2.2.
        *   `test/features/test_curation_and_quality.rb`: Covers Tasks 3.1 and 3.2.