// MIT License
//
// Copyright (c) 2021-2025 Pavel T
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation

// MARK: - SubscriptionModifyDescriptors

/// Descriptors for Advanced Commerce subscription modifications.
///
/// [SubscriptionModifyDescriptors](https://developer.apple.com/documentation/advancedcommerceapi/SubscriptionModifyDescriptors)
public struct SubscriptionModifyDescriptors: Codable, Hashable, Sendable {
    /// The description of the item.
    ///
    /// [Description](https://developer.apple.com/documentation/advancedcommerceapi/description)
    public var description: String?

    /// The display name of the item.
    ///
    /// [Display Name](https://developer.apple.com/documentation/advancedcommerceapi/displayname)
    public var displayName: String?

    /// When the modification takes effect.
    ///
    /// [Effective](https://developer.apple.com/documentation/advancedcommerceapi/effective)
    public var effective: Effective

    init(description: String? = nil, displayName: String? = nil, effective: Effective) {
        self.description = description
        self.displayName = displayName
        self.effective = effective
    }
}

// MARK: Validatable

extension SubscriptionModifyDescriptors: Validatable {
    public func validate() throws {
        if let description { try ValidationUtils.validateDescription(description) }
        if let displayName { try ValidationUtils.validateDisplayName(displayName) }
    }
}
