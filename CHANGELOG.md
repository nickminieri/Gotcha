# Changelog

A running log of notable changes to Gotcha.

## [Unreleased]

### Added
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
