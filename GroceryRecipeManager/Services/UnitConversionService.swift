//
//  UnitConversionService.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 10/14/25.
//


//
//  UnitConversionService.swift
//  GroceryRecipeManager
//
//  M3 Phase 5 Enhancement: Kitchen unit conversions
//  Based on standard kitchen measurement conversions
//

import Foundation

class UnitConversionService {
    
    // MARK: - Unit Categories
    
    enum UnitCategory {
        case volume
        case weight
        case count
        case unknown
    }
    
    // MARK: - Conversion to Base Units
    
    /// Convert any volume unit to milliliters (base unit)
    private func toMilliliters(value: Double, unit: String) -> Double? {
        let unit = unit.lowercased()
        
        switch unit {
        // Metric
        case "ml", "milliliter", "milliliters": return value
        case "l", "liter", "liters": return value * 1000
        
        // US Volume - Teaspoons/Tablespoons
        case "tsp", "teaspoon", "teaspoons": return value * 5
        case "tbsp", "tablespoon", "tablespoons", "t": return value * 15
        
        // US Volume - Cups and larger
        case "cup", "cups", "c": return value * 240
        case "pint", "pints", "pt": return value * 473  // ~2 cups
        case "quart", "quarts", "qt": return value * 946  // ~4 cups
        case "gallon", "gallons", "gal": return value * 3785  // ~16 cups
        
        // Fluid ounces
        case "fl oz", "fluid ounce", "fluid ounces", "floz": return value * 30
        
        default: return nil
        }
    }
    
    /// Convert any weight unit to grams (base unit)
    private func toGrams(value: Double, unit: String) -> Double? {
        let unit = unit.lowercased()
        
        switch unit {
        // Metric
        case "g", "gram", "grams": return value
        case "kg", "kilogram", "kilograms": return value * 1000
        
        // US Weight
        case "oz", "ounce", "ounces": return value * 28
        case "lb", "lbs", "pound", "pounds": return value * 454
        
        default: return nil
        }
    }
    
    // MARK: - Unit Category Detection
    
    func getUnitCategory(_ unit: String) -> UnitCategory {
        let unit = unit.lowercased()
        
        // Volume units
        let volumeUnits = [
            "ml", "milliliter", "milliliters", "l", "liter", "liters",
            "tsp", "teaspoon", "teaspoons", "tbsp", "tablespoon", "tablespoons", "t",
            "cup", "cups", "c", "pint", "pints", "pt", "quart", "quarts", "qt",
            "gallon", "gallons", "gal", "fl oz", "fluid ounce", "fluid ounces", "floz"
        ]
        if volumeUnits.contains(unit) { return .volume }
        
        // Weight units
        let weightUnits = [
            "g", "gram", "grams", "kg", "kilogram", "kilograms",
            "oz", "ounce", "ounces", "lb", "lbs", "pound", "pounds"
        ]
        if weightUnits.contains(unit) { return .weight }
        
        // Count units
        let countUnits = [
            "piece", "pieces", "pc", "clove", "cloves", "slice", "slices",
            "can", "cans", "package", "packages", "pkg", "bunch", "bunches",
            "head", "heads"
        ]
        if countUnits.contains(unit) { return .count }
        
        return .unknown
    }
    
    // MARK: - Conversion Between Units
    
    func convert(value: Double, from fromUnit: String, to toUnit: String) -> Double? {
        let fromCategory = getUnitCategory(fromUnit)
        let toCategory = getUnitCategory(toUnit)
        
        // Must be same category
        guard fromCategory == toCategory, fromCategory != .unknown else {
            return nil
        }
        
        switch fromCategory {
        case .volume:
            guard let baseValue = toMilliliters(value: value, unit: fromUnit) else { return nil }
            return fromMilliliters(value: baseValue, to: toUnit)
            
        case .weight:
            guard let baseValue = toGrams(value: value, unit: fromUnit) else { return nil }
            return fromGrams(value: baseValue, to: toUnit)
            
        case .count:
            // Count units don't convert (1 clove ≠ 1 piece)
            return fromUnit.lowercased() == toUnit.lowercased() ? value : nil
            
        case .unknown:
            return nil
        }
    }
    
    /// Convert from milliliters to any volume unit
    private func fromMilliliters(value: Double, to unit: String) -> Double? {
        let unit = unit.lowercased()
        
        switch unit {
        case "ml", "milliliter", "milliliters": return value
        case "l", "liter", "liters": return value / 1000
        case "tsp", "teaspoon", "teaspoons": return value / 5
        case "tbsp", "tablespoon", "tablespoons", "t": return value / 15
        case "cup", "cups", "c": return value / 240
        case "pint", "pints", "pt": return value / 473
        case "quart", "quarts", "qt": return value / 946
        case "gallon", "gallons", "gal": return value / 3785
        case "fl oz", "fluid ounce", "fluid ounces", "floz": return value / 30
        default: return nil
        }
    }
    
    /// Convert from grams to any weight unit
    private func fromGrams(value: Double, to unit: String) -> Double? {
        let unit = unit.lowercased()
        
        switch unit {
        case "g", "gram", "grams": return value
        case "kg", "kilogram", "kilograms": return value / 1000
        case "oz", "ounce", "ounces": return value / 28
        case "lb", "lbs", "pound", "pounds": return value / 454
        default: return nil
        }
    }
    
    // MARK: - Smart Unit Selection
    
    /// Select the best unit for displaying combined quantities
    func selectBestUnit(quantities: [(value: Double, unit: String)]) -> String? {
        guard !quantities.isEmpty else { return nil }
        
        // Get category from first item
        let category = getUnitCategory(quantities[0].unit)
        
        // Find the unit with the largest total value (most "substance")
        var bestUnit = quantities[0].unit
        var bestTotal = quantities[0].value
        
        for item in quantities {
            if item.value > bestTotal {
                bestTotal = item.value
                bestUnit = item.unit
            }
        }
        
        // For very small volume amounts, prefer tsp over larger units
        if category == .volume {
            let totalML = quantities.compactMap { toMilliliters(value: $0.value, unit: $0.unit) }.reduce(0, +)
            
            if totalML < 15 { return "tsp" }  // Less than 1 tbsp
            if totalML < 240 { return "tbsp" }  // Less than 1 cup
            if totalML < 946 { return "cup" }  // Less than 1 quart
        }
        
        // For weight, similar logic
        if category == .weight {
            let totalGrams = quantities.compactMap { toGrams(value: $0.value, unit: $0.unit) }.reduce(0, +)
            
            if totalGrams < 28 { return "g" }  // Less than 1 oz
            if totalGrams < 454 { return "oz" }  // Less than 1 lb
        }
        
        return bestUnit
    }
    
    // MARK: - Compatibility Check
    
    func areUnitsCompatible(_ unit1: String, _ unit2: String) -> Bool {
        let cat1 = getUnitCategory(unit1)
        let cat2 = getUnitCategory(unit2)
        
        return cat1 == cat2 && cat1 != .unknown
    }
}