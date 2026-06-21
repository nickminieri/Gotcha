# Changelog

A running log of notable changes to Gotcha.

## [Unreleased]

### Added
- **In-app notifications / activity center**: the bell in the Explore header now
  opens an Activity feed of offers, messages, reviews, sales, and meetups, each
  with a color-coded icon, relative timestamp, and unread state. The bell shows
  an unread-count badge. Accepted offers and confirmed meetups generate live
  notifications; rows support mark-as-read / delete (swipe-free context menu),
  plus "Mark all as read" and "Clear all". Persisted to `UserDefaults`
  (`AppNotification`, `NotificationsViewModel`, `NotificationsView`).
- **Research-driven trust & safety suite** (see `RESEARCH.md`): `.edu`-gated
  login with **Student Verified** / **ID Verified** trust badges across the app;
  **report & block** flows (listings, sellers, conversations) that hide blocked
  sellers; a chat **safety banner**; in-chat **Make an Offer** (accept/decline)
  and **Schedule Safe Meetup** at curated campus spots, rendered as offer/meetup
  cards in the conversation.

### Changed
- **Premium UI redesign**: introduced a central `Theme` design system (layered
  near-black surfaces, a single violet accent + gradient, text/hairline tokens)
  and applied it across the app. Category art is now muted jewel-tones instead of
  saturated rainbows; the tab bar is a clean floating pill with a solid surface
  (fixing the translucent color bleed); cards gained hairline borders, soft
  shadows, an image scrim, and a condition pill; the Explore header, search bar,
  and category chips were refined for consistency.

### Added
- **Seller ratings & reviews**: tap a seller on a listing to open their profile
  with an average rating (half-star display) and a list of reviews; buyers can
  write a star rating + comment. The listing's seller card shows the rating, and
  the Profile tab's Rating/Reviews stats are computed from real reviews. Reviews
  persist to `UserDefaults` (`Review` model, `SellerProfileView`).
- **Profile editing**: edit your name and university and pick an avatar photo
  (PhotosPicker) from the Profile tab. The profile is persisted across launches,
  the avatar shows on the profile, and renaming re-attributes your listings to
  the new display name. `User` is now `Codable` with an `avatarFilename`.
- **Filters on Explore**: a filter sheet to narrow listings by condition
  (multi-select), max price (slider), and a "hide sold items" toggle, with an
  active-filter count badge on the filter button and a one-tap Clear. Filters
  compose with category, search, and sort.
- **Mark listings as sold**: owners can toggle "Mark as Sold" / "Mark as
  Available" from a listing's menu on the Profile tab. Sold listings get a red
  "SOLD" badge and dimmed art on cards, a struck-through price, and the detail
  screen's action button becomes a disabled "Item Sold".
- **Unread message badges**: a count badge on the Messages tab and on each
  conversation row, cleared when you open the thread. Replies that arrive while
  you're not viewing a thread increment its unread count.
- **Delete conversations**: long-press a conversation to remove it.
- **Messaging**: a real (local, persisted) messaging system replaces the
  "coming soon" placeholders. The Messages tab lists conversations (seller,
  item, last message, time); tapping opens a chat thread with bubbles and a
  send bar. "Message Seller" on a listing opens/creates that conversation.
  Sending a message gets a lightweight canned seller auto-reply. Conversations
  are saved to `UserDefaults` (`MessagingViewModel`, `Conversation`/`Message`).
- Navigation moved to a `NavigationPath`, so listings and conversations push
  consistently from any tab.
- **Listing photos via PhotosPicker**: pick a photo when creating or editing a
  listing. Images are downscaled/JPEG-compressed and stored on disk in an
  `ImageStore` (only the filename is saved in the listing), then shown on cards,
  the detail hero, and profile rows — with the category gradient as a fallback
  when there's no photo.
- **Local persistence**: listings (including your own and favorites) are saved
  to `UserDefaults` as JSON and restored on launch, so changes survive app
  restarts. `Item` and its enums are now `Codable`.
- **Sort & result count on Explore**: a sort menu (Newest / Price low→high /
  Price high→low) and a live "N listings" count above the grid.
- **Edit & delete your own listings**: each row in the Profile "My Listings"
  section has a "•••" menu (and context menu) for Edit / Delete. Editing reuses
  the listing form pre-filled with the item's values; deleting asks for
  confirmation. The "Listed" stat stays in sync.
- **User profile derived from login email**: signing in builds the current
  user's name and university from their campus email
  (e.g. `alex.rivera@nyu.edu` -> "Alex R." at "NYU") via
  `User.fromCampusEmail(_:)`.
- **DEBUG launch-argument hooks** (gated by `#if DEBUG`, never shipped) for
  deterministic runs/screenshots: `-uiAutoLogin`, `-uiSeedMyListings`,
  `-uiStartTab <Tab>`, `-uiPresentCreate`.

### Earlier in this cycle
- **Create Listing flow** (`CreateListingView`): a form sheet to post an item
  with title, price, category, condition, and description, including a live
  preview card that updates as you type. New listings are inserted at the top of
  the marketplace and attributed to the current user.
  - Entry points: a gradient "+" button in the Explore header and the
    "List an Item" button on the Profile tab.
- **"My Listings"** section on the Profile tab, showing the current user's posts.
  The "Listed" stat now updates live as items are published.
- **Dev bypass** on the login screen ("Skip sign-in (dev)") to enter the app
  without typing credentials during testing.
- `.gitignore` for macOS/Xcode artifacts and user-specific state.
- This `CHANGELOG.md`.

### Changed
- `MarketplaceViewModel` gained `currentUser`, `isPresentingCreateListing`,
  `myListings`, and `addListing(...)`.
- `UserProfileView` now reads from the shared view model instead of a static
  preview user.
