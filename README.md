# Grocery & Recipe Manager

An iOS app that transforms grocery shopping from a time-consuming chore into an efficient, personalized experience through smart automation and custom store layouts.

## Features

### Core Functionality
- **Smart Grocery Lists**: Auto-generate weekly shopping lists from your regular staples
- **Custom Store Layout**: Organize items by your actual shopping path for maximum efficiency
- **Recipe Management**: Build and maintain a personal recipe collection with usage tracking
- **Intelligent Categories**: Create unlimited custom categories with personalized ordering
- **Real-time Search**: Instant search across all items and recipes

### Advanced Features
- **Drag-and-Drop Organization**: Reorder categories to match your store layout
- **Usage Analytics**: Track recipe usage patterns and shopping frequency
- **Smart Shopping Workflow**: Check off items with progress tracking
- **Performance Optimized**: Sub-100ms response times with Core Data optimization

## Screenshots

*Coming soon - Screenshots of the main tabs and key features*

## Getting Started

### Requirements
- iOS 14.0+
- Xcode 14.0+
- macOS Big Sur 11.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rfhayn/grocery-recipe-manager.git
cd grocery-recipe-manager
```

2. Open the project in Xcode:
```bash
open GroceryRecipeManager/GroceryRecipeManager.xcodeproj
```

3. Build and run:
   - Select your target device or simulator
   - Press ⌘+R to build and run
   - The app launches with sample data for immediate testing

## App Structure

The app consists of five main tabs:

- **Lists**: View and manage auto-generated grocery lists
- **Staples**: Manage your regular grocery items
- **Recipes**: Browse and manage your recipe collection
- **Categories**: Customize your store layout and organization
- **Test**: Performance validation and metrics

## Architecture

### Technology Stack
- **SwiftUI** for modern, declarative UI
- **Core Data** for local data persistence
- **CloudKit** ready for family sharing (future feature)

### Data Model
- 8-entity Core Data model supporting recipes, ingredients, and custom categories
- Performance-optimized queries with compound indexes
- Template-based ingredient normalization to prevent duplication

### Performance
- **Sub-millisecond response times** for most operations
- **Background processing** for non-blocking UI operations
- **Memory efficient** relationship handling

## Development Status

### Completed (Milestone 1)
- ✅ Professional staples management with CRUD operations
- ✅ Custom category system with drag-and-drop reordering
- ✅ Auto-generated grocery lists organized by store layout
- ✅ Real-time search and filtering
- ✅ Professional shopping workflow with check-off functionality

### In Progress (Milestone 2)
- 🔄 Enhanced recipe integration with usage tracking
- 🔄 Recipe-to-grocery list functionality
- 🔄 Smart ingredient templating system

### Planned Features
- 📋 CloudKit family sharing
- 📋 Advanced usage analytics
- 📋 Meal planning capabilities
- 📋 Health and budget optimization features

## Project Structure

```
grocery-recipe-manager/
├── GroceryRecipeManager/           # iOS Xcode project
│   ├── Views/                      # SwiftUI views
│   ├── Services/                   # Data services
│   └── Core Data/                  # Data model
├── docs/                           # Documentation
│   ├── requirements/               # Feature specifications
│   ├── architecture/               # Technical decisions
│   └── development/                # Development guides
├── planning/                       # Project management
└── learning-notes/                 # Development journey
```

## Contributing

This is a personal learning project focused on iOS development skills. The extensive documentation in the `docs/` folder tracks the development journey and architectural decisions.

### Development Approach
- **Incremental Development**: Features built in small, validated increments
- **Performance First**: All features maintain strict performance standards
- **User Experience Focus**: Native iOS patterns and accessibility compliance
- **Quality Assurance**: Comprehensive testing and validation

## Technical Highlights

### Performance Engineering
- N+1 query prevention with batch relationship fetching
- Indexed Core Data queries for instant search results
- Background operations preventing UI blocking

### User Experience Innovation
- Revolutionary custom store layout optimization
- Drag-and-drop category personalization
- Professional iOS design patterns throughout

### Architecture Excellence
- Service-oriented architecture with clear separation of concerns
- Scalable data model supporting future advanced features
- Performance monitoring and validation systems

## License

This project is available under the MIT License.

## Contact

For questions about the project or iOS development approaches used, please open an issue or check the extensive documentation in the `docs/` folder.

---

*Transform your grocery shopping experience with intelligent automation and personalized organization.*