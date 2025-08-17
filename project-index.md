# 📌 Project Index — Grocery Recipe Manager

## 🧭 Project Vision
A mobile-first application to:
- Maintain a list of staple grocery purchases (auto-populated into weekly lists).  
- Build and manage a recipe catalog.  
- Track recipe usage frequency and last used date.  
- Tag recipes with categories like *leftovers* or *quick and easy*.  

## 📂 Repository Structure
- `/docs/requirements/requirements.md` → Functional requirements.  
- `/docs/development/roadmap.md` → Development roadmap & milestones.  
- `/learning-notes/` → Setup and Core Data learning steps.  
- `/planning/` → Stories, wireframes, and current progress.  
- `/GroceryRecipeManager/` → iOS app implementation (Swift, Core Data, UI).  
- `/project-index.md` → **You are here: canonical tracker of modules & status.**

## 🚦 Current Story Status
- **Story 1.1: Environment Setup** → ✅ Completed  
  - Xcode environment configured.  
  - Initial Core Data `GroceryItem` entity created.  

- **Story 1.2: Core Data Foundation** → 🚧 In Progress  
  - `GroceryItem` entity complete.  
  - `Recipe` entity started.  
  - Pending: `Ingredient`, `WeeklyList`, `Tag`.  
  - CloudKit integration pending.  

Next focus: finalize entities + relationships, test persistence layer.  

## 📊 Domain Model Progress
| Entity        | Status  | Notes |
|---------------|---------|-------|
| GroceryItem   | ✅ Done | Core entity for staples & individual groceries. |
| Recipe        | 🚧 In Progress | Title, instructions, usageCount. Needs CloudKit flag. |
| Ingredient    | ⏳ Not Started | Will connect Recipes → GroceryItems. |
| WeeklyList    | ⏳ Not Started | Represents weekly shopping list. |
| Tag           | ⏳ Not Started | Many-to-many relationship with Recipe. |

## 📅 Roadmap Sync
- [x] **1.1 Environment Setup**  
- [ ] **1.2 Core Data Foundation** *(active)*  
- [ ] 1.3 Recipe & Grocery List UI  
- [ ] 1.4 iCloud / CloudKit sync  
- [ ] 1.5 Testing, edge cases & polish  

👉 Full details in [`docs/development/roadmap.md`](./docs/development/roadmap.md).  

## ✅ Requirements Coverage
- Staple grocery list → **covered in GroceryItem**.  
- Recipe catalog + ingredients → **partially covered in Recipe (needs Ingredient)**.  
- Usage tracking → **covered in Recipe.usageCount & lastUsed**.  
- Tagging system → **not yet implemented**.  

👉 Full requirements in [`docs/requirements/requirements.md`](./docs/requirements/requirements.md).  