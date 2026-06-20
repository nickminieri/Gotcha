# Gotcha Marketplace App (In Progress)

Gotcha is a digital marketplace app designed specifically for college students. It provides a secure and user-friendly platform for buying, selling, and trading items within the college community. The app ensures safety by restricting access to users with verified college credentials.

## Features (Current Progress)

- **Search Functionality**: Search for items by name or category.
- **Categories**: Browse items across various categories like Clothing, Electronics, Furniture, Appliances, Books, and more.
- **Create Listings**: Post your own items for sale with a title, price, category, condition, description, and a photo (via PhotosPicker) — complete with a live preview of how the listing card will look. New listings appear instantly in the marketplace and on your profile.
- **Edit, Delete & Mark Sold**: Manage your own posts from the Profile tab, including marking items as sold (shown with a SOLD badge across the app).
- **Sort & Filter**: Sort listings by newest or price, and filter by condition, max price, or hide sold items — alongside category and keyword search.
- **Local Persistence**: Listings and favorites are saved on-device and restored across app launches.
- **Messaging**: Chat with sellers from any listing — conversations appear in the Messages tab and are saved between launches.
- **Favorite Items**: Mark items as favorites to save for later and view them on a dedicated Favorites page.
- **Interactive UI**:
  - Explore tab for browsing the marketplace.
  - Favorites tab for quick access to saved items.
  - Messages tab for future communication with sellers or buyers.
  - Profile tab for viewing and managing user details (future feature).
- **Responsive Design**: Uses SwiftUI for a clean and adaptive interface.

## Screens (Current Progress)

1. **Explore Page**:
   - Search bar with rounded edges for finding items.
   - Category selector for browsing by category.
   - Grid view displaying items with images, titles, and prices.
   - Favorite button on each item to save it.

2. **Favorites Page**:
   - Displays a grid of all favorited items.
   - Items can be unfavorited to remove them from this list.

3. **Messages Page**:
   - Placeholder for future implementation of user messaging functionality.

4. **Profile Page**:
   - Placeholder for future user profile management features.

## Technologies Used

- **SwiftUI**: For building a declarative and responsive user interface.
- **State Management**: Uses SwiftUI’s `@State` and `@Binding` for managing UI updates.
- **LazyVGrid**: Efficiently displays a grid of items.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nickminieri/Gotcha.git
   cd Gotcha
2. open the project in Xcode:
   ```bash
   open Gotcha.xcodeproj
3. Run the project:
  - Select a simulator or a connected device in Xcode.
  - Press Cmd + R to build and run the app.

## Future Improvements

- **User Authentication**:
  - Wire the login/signup flow to a real auth provider with student-email verification (the UI is built; it currently logs in locally).
- **Message System**:
  - Sync conversations to a backend so messages reach real sellers in real time (local messaging is implemented).
- **Enhanced Profile Management**:
  - Allow users to edit their profile and upload a profile picture (viewing your listings is implemented).
- **Backend Integration**:
  - Store listings, user data, and favorites in a backend database.
- **Improved Search**:
  - Add advanced filters and sorting options for better search functionality.
 
## Contributing
We welcome contributions! To contribute:
1. Fork the repository.
2. Create a new branch for your feature
   ```bash
   git checkout -b feature-name
3. Commit your changes:
   ```bash
   git commit -m "Add a meaningful commit message"
5. Push your fork:
   ```bash
   git push origin feature-name
6. Create a Pull Request on the [Gotcha Repository](https://github.com/nickminieri/Gotcha)

## **This project is a work in progress. Stay tuned for updates! 🚀**

