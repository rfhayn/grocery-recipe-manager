# PROJECT_INDEX.md

## 📌 Project Overview
**Grocery & Recipe Manager (Mobile App)**  
A mobile-first application that helps users manage grocery staples, plan recipes, and streamline weekly shopping.  

**Core Value:** Reduce friction in grocery planning by:  
- Auto-populating weekly grocery lists with staple items  
- Linking recipes directly to grocery lists  
- Tracking recipe usage history and tags  

---

## 🧭 Domains
1. **Grocery Management**  
   - Staple list maintenance  
   - Weekly grocery list generation (auto + manual)  

2. **Recipe Management**  
   - Recipe catalog storage  
   - Ingredient-to-grocery-list integration  
   - Tagging system for recipes  

3. **Meal Planning Insights**  
   - Recipe usage tracking (last used, frequency)  
   - Filtering/search by tags, recency, or frequency  

---

## 📦 Modules
### Grocery Management Domain
- **staples/**: CRUD for recurring grocery items  
- **weekly-list/**: Generation and customization of weekly grocery lists  

### Recipe Management Domain
- **recipes/**: Catalog of recipes (title, steps, ingredients)  
- **ingredients/**: Ingredient mapping to grocery items  
- **tags/**: Tagging system (e.g., “leftovers”, “quick & easy”)  

### Meal Planning Insights Domain
- **usage-tracking/**: Store usage events (when recipe was cooked)  
- **history/**: Query last-used and frequency  

---

## 📚 Epics
- **Epic 1: Grocery Automation** → Auto-populate weekly lists with staple items  
- **Epic 2: Recipe Integration** → Recipes push ingredients into shopping lists  
- **Epic 3: Usage Insights** → Track and display recipe usage patterns  
- **Epic 4: Tagging & Discovery** → Flexible recipe categorization for filtering/search  

---

## 📂 Documentation Map
- `/docs/requirements/` → Business requirements (PRD-style)  
- `/docs/design/` → UX flows & wireframes (Claude-generated artifacts)  
- `/docs/development/` → Tech specs (to be generated here with Architect GPT)  
- `/planning/stories/` → User stories (Claude artifacts)  
- `/planning/wireframes/` → UI wireframes (Claude artifacts)  
- `/learning-notes/` → Research & technical references  

---

## 🛠 Implementation Plan
### Backend (to be scaffolded under `/backend/`)