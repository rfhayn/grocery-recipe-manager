# Project Naming Standards
**Project**: Grocery & Recipe Manager iOS App  
**Version**: 2.0 - Simplified Naming Convention  
**Last Updated**: September 27, 2025  

---

## 📋 **NAMING CONVENTION FRAMEWORK**

### **3-Level Hierarchy Structure**

#### **Level 1: Major Features (M1, M2, M3...)**
- **Format**: M[Number]: [Feature Name]
- **Purpose**: High-level functional areas
- **Examples**: 
  - M1: Grocery Management
  - M2: Recipe Integration  
  - M3: Testing Framework

#### **Level 2: Feature Components (M2.1, M2.2, M2.3...)**
- **Format**: M[Major].[Component]: [Component Name]
- **Purpose**: Distinct functional components within a major feature
- **Examples**:
  - M2.1: Recipe Architecture Services
  - M2.2: Recipe Catalog
  - M2.3: Recipe Creation & Editing

#### **Level 3: Implementation Tasks (M2.2.1, M2.2.2, M2.2.3...)**
- **Format**: M[Major].[Component].[Task]: [Task Name]
- **Purpose**: Specific implementation tasks or development steps
- **Examples**:
  - M2.2.1: Basic Recipe List
  - M2.2.2: Recipe Detail View
  - M2.2.3: Ingredient Templates

---

## 🎯 **CURRENT PROJECT MAPPING**

### **Completed Features**
- **M1: Grocery Management** ✅ **COMPLETE**
  - M1.1: Core Data Foundation ✅
  - M1.2: Performance Architecture ✅
  - M1.3: Staples Management ✅
  - M1.4: Custom Category System ✅
  - M1.5: Auto-Generated Lists ✅

### **Active Development**
- **M2: Recipe Integration** 🔄 **ACTIVE**
  - M2.1: Recipe Architecture Services ✅ **COMPLETE**
  - M2.2: Recipe Catalog 🔄 **ACTIVE**
    - M2.2.1: Basic Recipe List ✅
    - M2.2.2: Recipe Detail View ✅
    - M2.2.3: Ingredient Templates ✅
    - M2.2.4: Add to List Enhancement ✅
    - M2.2.5: Unified Ingredients View ✅
    - M2.2.6: Custom Category Integration 🚀 **READY**
  - M2.3: Recipe Creation & Editing ⏳ **PLANNED**

### **Future Development**
- **M3: Testing Framework** ⏳ **PLANNED**
- **M4: Analytics Dashboard** ⏳ **PLANNED**
- **M5: CloudKit Family Sharing** ⏳ **PLANNED**

---

## 📝 **DOCUMENTATION STANDARDS**

### **Status Indicators**
- ✅ **COMPLETE**: Fully implemented and validated
- 🔄 **ACTIVE**: Currently in development
- 🚀 **READY**: Ready to start implementation
- ⏳ **PLANNED**: Planned for future development

### **Time Tracking Format**
- Use actual time spent: "M2.2.5 (4.5 hours) - COMPLETE"
- Include estimates for planned work: "M2.2.6 (45 minutes) - READY"

### **Reference Format**
- **In text**: "Currently working on M2.2.6"
- **In headers**: "## M2.2.6: Custom Category Integration"
- **In file names**: Use descriptive names, reference numbers in content

---

## 🔧 **IMPLEMENTATION GUIDELINES**

### **When Creating New Work**
1. Identify the appropriate Major Feature (M1, M2, etc.)
2. Determine if it's a new Component or Task
3. Assign next sequential number
4. Use descriptive names that clearly indicate functionality

### **When Referencing Work**
- Use the full identifier: "M2.2.6" not "Step 6" or "Phase 3"
- Include descriptive name when helpful: "M2.2.6: Custom Category Integration"
- Keep status current: update from READY → ACTIVE → COMPLETE

### **Documentation Updates**
- Update all files when status changes
- Maintain consistency across current-story.md, project-index.md, requirements.md, roadmap.md
- Use the same naming convention in all documentation

---

## 🎯 **BENEFITS OF THIS SYSTEM**

### **Clarity & Navigation**
- **Linear progression**: M2.2.1 → M2.2.2 → M2.2.3
- **Clear hierarchy**: Major → Component → Task
- **Easy reference**: "M2.2.6" is unambiguous

### **Scalability**
- **Unlimited expansion**: Can add M2.2.7, M2.3.1, M6.4.12, etc.
- **Logical grouping**: Related tasks stay together
- **Easy reorganization**: Can move tasks between components if needed

### **Project Management**
- **Progress tracking**: Clear completion percentage per component
- **Dependency management**: Easy to see what blocks what
- **Timeline estimation**: Granular time tracking at task level

---

## 📊 **CURRENT STATUS EXAMPLE**

**M2: Recipe Integration (75% Complete)**
- M2.1: Recipe Architecture Services ✅ (1 hour)
- M2.2: Recipe Catalog 🔄 (5.5/7 hours)
  - M2.2.1-M2.2.5: ✅ Complete (9.25 hours total)
  - M2.2.6: 🚀 Ready (45 minutes estimated)
  - M2.2.7-M2.2.8: ⏳ Planned (1.5 hours estimated)
- M2.3: Recipe Creation & Editing ⏳ (4-5 hours estimated)

**Next Active Development**: M2.2.6: Custom Category Integration

---

**Key Rule**: Always use this naming convention in all documentation and references going forward. No more overlapping "Milestone/Phase/Step" terminology.