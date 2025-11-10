//
//  ObfuscateFields.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 10/11/2025.
//

import Foundation

// MARK: - Public API (Readable output; no format preservation)

/// Obfuscate the value of given field names in a body and return a **readable** string.
///
/// Strategy:
/// 1. If `body` is JSON (Data/String/Dictionary/Array), recursively redact the fields and
///    return **pretty-printed JSON** (keys optionally sorted when available).
/// 2. Otherwise, return a readable `String(describing:)` of the original value.
///
/// Notes:
/// - Field name matches are **case-insensitive**.
/// - For non-string field values, the replacement becomes the literal string "REDACTED".
/// - No attempt is made to preserve original spacing/formatting; goal is readability.
public func obfuscateFields(
    _ fields: [String],
    in body: Any,
    mask: (String) -> String = { _ in "hidden" }
) -> String {
    // Fast paths for already-structured inputs
    if let dict = body as? [String: Any] {
        let red = redact(fields: fields, in: dict, mask: mask)
        return prettyJSONString(red)
    }
    if let arr = body as? [Any] {
        let red = redact(fields: fields, in: arr, mask: mask)
        return prettyJSONString(red)
    }

    // If it's Data, try to parse as JSON
    if let data = body as? Data {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            let red = redact(fields: fields, in: json, mask: mask)
            return prettyJSONString(red)
        }
        // Fallback readable dump
        return String(data: data, encoding: .utf8) ?? String(describing: body)
    }

    // If it's a String, try to parse as JSON
    if let str = body as? String {
        if let data = str.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            let red = redact(fields: fields, in: json, mask: mask)
            return prettyJSONString(red)
        }
        // Fallback readable dump (unstructured); no redaction applied
        return str
    }
    
    // Catch-all fallback
    return String(describing: body)
}

// MARK: - Helpers

/// Recursively redact fields in any JSON-like structure (Dictionary/Array/scalars).
/// - Non-string matches are replaced by the literal string "REDACTED".
private func redact(fields: [String], in any: Any, mask: (String) -> String) -> Any {
    let targets = Set(fields.map { $0.lowercased() })

    // Dictionary branch
    if let dict = any as? [String: Any] {
        var out: [String: Any] = [:]
        out.reserveCapacity(dict.count)
        for (k, v) in dict {
            if targets.contains(k.lowercased()) {
                if let s = v as? String { out[k] = mask(s) }
                else { out[k] = "REDACTED" }
            } else {
                out[k] = redact(fields: fields, in: v, mask: mask)
            }
        }
        return out
    }

    // Array branch
    if let arr = any as? [Any] {
        return arr.map { redact(fields: fields, in: $0, mask: mask) }
    }

    // Scalars unchanged
    return any
}

/// Pretty-print JSON (Dictionary/Array). If not JSON-serializable, falls back to `String(describing:)`.
private func prettyJSONString(_ any: Any) -> String {
    guard JSONSerialization.isValidJSONObject(any) else {
        return String(describing: any)
    }
    var options: JSONSerialization.WritingOptions = [.prettyPrinted]
    if #available(iOS 11.0, *) { options.insert(.sortedKeys) }
    if let data = try? JSONSerialization.data(withJSONObject: any, options: options),
       let str = String(data: data, encoding: .utf8) {
        return str
    }
    
    return String(describing: any)
}

// MARK: - Convenience overloads

/// Overload for Data bodies. Returns a readable string (pretty JSON when possible).
public func obfuscateFields(
    _ fields: [String],
    in body: Data,
    mask: (String) -> String = { _ in "hidden" }
) -> String {
    obfuscateFields(fields, in: body as Any, mask: mask)
}

/// Overload for String bodies. Returns a readable string (pretty JSON when possible).
public func obfuscateFields(
    _ fields: [String],
    in body: String,
    mask: (String) -> String = { _ in "hidden" }
) -> String {
    obfuscateFields(fields, in: body as Any, mask: mask)
}
