//
//  DeviceUtility.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import UIKit

struct DeviceUtility {
    
    // MARK: - Device Type
    enum DeviceType: Equatable {
        case iPhone(generation: Int)
        case iPad(generation: Int)
        case unknown
    }
    
    // MARK: - Public
    static var deviceType: DeviceType {
        let identifier = modelIdentifier
        let marketingName = marketingModelName
        return parseDeviceType(identifier: identifier, marketingName: marketingName)
    }
    
    /// Returns the generation number for iPhone or iPad (nil if unknown or other device)
    static var deviceGeneration: Int? {
        switch deviceType {
        case .iPhone(let gen), .iPad(let gen):
            return gen
        case .unknown:
            return nil
        }
    }
    
    /// Returns "iPhone" or "iPad" as a string (nil if unknown)
    static var deviceName: String? {
        switch deviceType {
        case .iPhone:
            return "iPhone"
        case .iPad:
            return "iPad"
        case .unknown:
            return nil
        }
    }
    
    /// Convenience: true when running on a specific generation
    static func isDevice(generation: Int) -> Bool {
        deviceGeneration == generation
    }
    
    // MARK: - Private helpers
    
    /// Returns the raw hardware identifier from the kernel, e.g. "iPhone16,2"
    private static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
    }
    
    /// Best-effort marketing name via sysctlbyname (works on device; simulator returns host Mac name)
    private static var marketingModelName: String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    /// Maps hardware identifier → DeviceType
    /// Source: https://www.theiphonewiki.com/wiki/Models
    private static func parseDeviceType(identifier: String, marketingName: String) -> DeviceType {
        
        // Simulator
        if identifier == "i386" || identifier == "x86_64" || identifier == "arm64" {
            // On simulator, fall back to parsing the marketing-style name from
            // ProcessInfo or use the SIMULATOR_MODEL_IDENTIFIER env var
            let simId = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
            if !simId.isEmpty {
                return parseDeviceType(identifier: simId, marketingName: "")
            }
            return .unknown
        }
        
        if identifier.hasPrefix("iPhone") {
            return .iPhone(generation: iPhoneGeneration(from: identifier))
        }
        
        if identifier.hasPrefix("iPad") {
            return .iPad(generation: iPadGeneration(from: identifier))
        }
        
        return .unknown
    }
    
    // MARK: - iPhone generation table
    // Maps the hardware identifier → iPhone marketing generation
    private static func iPhoneGeneration(from identifier: String) -> Int {
        // Full model mapping based on actual hardware identifiers
        // Source: https://www.theiphonewiki.com/wiki/Models
        
        switch identifier {
            // iPhone 1
        case "iPhone1,1": return 1
            
            // iPhone 3G
        case "iPhone1,2": return 3
            
            // iPhone 3GS
        case "iPhone2,1": return 3
            
            // iPhone 4
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return 4
            
            // iPhone 4S
        case "iPhone4,1": return 4
            
            // iPhone 5
        case "iPhone5,1", "iPhone5,2": return 5
            
            // iPhone 5c
        case "iPhone5,3", "iPhone5,4": return 5
            
            // iPhone 5s
        case "iPhone6,1", "iPhone6,2": return 5
            
            // iPhone 6
        case "iPhone7,2": return 6
            
            // iPhone 6 Plus
        case "iPhone7,1": return 6
            
            // iPhone 6s
        case "iPhone8,1": return 6
            
            // iPhone 6s Plus
        case "iPhone8,2": return 6
            
            // iPhone SE (1st gen)
        case "iPhone8,4": return 5  // SE 1st gen is based on iPhone 5s
            
            // iPhone 7
        case "iPhone9,1", "iPhone9,3": return 7
            
            // iPhone 7 Plus
        case "iPhone9,2", "iPhone9,4": return 7
            
            // iPhone 8
        case "iPhone10,1", "iPhone10,4": return 8
            
            // iPhone 8 Plus
        case "iPhone10,2", "iPhone10,5": return 8
            
            // iPhone X
        case "iPhone10,3", "iPhone10,6": return 10
            
            // iPhone XR
        case "iPhone11,8": return 10
            
            // iPhone XS
        case "iPhone11,2": return 10
            
            // iPhone XS Max
        case "iPhone11,4", "iPhone11,6": return 10
            
            // iPhone 11
        case "iPhone12,1": return 11
            
            // iPhone 11 Pro
        case "iPhone12,3": return 11
            
            // iPhone 11 Pro Max
        case "iPhone12,5": return 11
            
            // iPhone SE (2nd gen)
        case "iPhone12,8": return 8  // SE 2nd gen is based on iPhone 8
            
            // iPhone 12 mini
        case "iPhone13,1": return 12
            
            // iPhone 12
        case "iPhone13,2": return 12
            
            // iPhone 12 Pro
        case "iPhone13,3": return 12
            
            // iPhone 12 Pro Max
        case "iPhone13,4": return 12
            
            // iPhone 13 mini
        case "iPhone14,4": return 13
            
            // iPhone 13
        case "iPhone14,5": return 13
            
            // iPhone 13 Pro
        case "iPhone14,2": return 13
            
            // iPhone 13 Pro Max
        case "iPhone14,3": return 13
            
            // iPhone SE (3rd gen)
        case "iPhone14,6": return 8  // SE 3rd gen is based on iPhone 8
            
            // iPhone 14
        case "iPhone14,7": return 14
            
            // iPhone 14 Plus
        case "iPhone14,8": return 14
            
            // iPhone 14 Pro
        case "iPhone15,2": return 14
            
            // iPhone 14 Pro Max
        case "iPhone15,3": return 14
            
            // iPhone 15
        case "iPhone15,4": return 15
            
            // iPhone 15 Plus
        case "iPhone15,5": return 15
            
            // iPhone 15 Pro
        case "iPhone16,1": return 15
            
            // iPhone 15 Pro Max
        case "iPhone16,2": return 15
            
            // iPhone 16
        case "iPhone16,3": return 16
            
            // iPhone 16 Plus
        case "iPhone16,4": return 16
            
            // iPhone 16 Pro
        case "iPhone17,1": return 16
            
            // iPhone 16 Pro Max
        case "iPhone17,2": return 16
            
            // iPhone 17 series (future proofing)
        case let id where id.hasPrefix("iPhone17,"): return 17
        case let id where id.hasPrefix("iPhone18,"): return 18
        case let id where id.hasPrefix("iPhone19,"): return 19
        case let id where id.hasPrefix("iPhone20,"): return 20
            
        default:
            // Fallback: try to extract major version
            guard let major = extractMajor(from: identifier, prefix: "iPhone") else { return 0 }
            return major
        }
    }
    
    // MARK: - iPad generation table
    private static func iPadGeneration(from identifier: String) -> Int {
        guard let major = extractMajor(from: identifier, prefix: "iPad") else { return 0 }
        switch major {
        case 1:  return 1
        case 2:  return 2
        case 3:  return 3
        case 4:  return 4    // iPad mini / Air
        case 5:  return 5
        case 6:  return 6    // iPad mini 4 / Air 2
        case 7:  return 7
        case 8:  return 8
        case 9:  return 9
        case 11: return 10   // iPad Pro 11"
        case 12: return 10   // iPad Pro 12.9" gen 4+
        case 13: return 11   // iPad Air M1 / Pro M2
        case 14: return 12
        default: return major
        }
    }
    
    // Extracts the number after the prefix, e.g. "iPhone16,2" → 16
    private static func extractMajor(from identifier: String, prefix: String) -> Int? {
        let stripped = identifier.dropFirst(prefix.count)
        let majorStr = stripped.prefix(while: { $0.isNumber })
        return Int(majorStr)
    }
}
