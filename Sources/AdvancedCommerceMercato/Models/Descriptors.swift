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

// MARK: - Descriptors

/// The description and display name of the subscription to migrate to that you manage.
public struct Descriptors: Decodable, Encodable {
    /// A string you provide that describes a SKU.
    ///
    /// [Description](https://developer.apple.com/documentation/appstoreserverapi/description)
    public var description: String

    /// A string with a product name that you can localize and is suitable for display to customers.
    ///
    /// [DisplayName](https://developer.apple.com/documentation/appstoreserverapi/displayname)
    public var displayName: String

    public init(description: String, displayName: String) {
        self.description = description
        self.displayName = displayName
    }

    public enum CodingKeys: String, CodingKey {
        case description
        case displayName
    }
}

// MARK: Validatable

extension Descriptors: Validatable {
    public func validate() throws {
        try ValidationUtils.validateDescription(description)
        try ValidationUtils.validateDisplayName(displayName)
    }
}
