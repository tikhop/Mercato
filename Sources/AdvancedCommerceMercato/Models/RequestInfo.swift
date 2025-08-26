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

// MARK: - RequestInfo

/// The metadata to include in server requests.
///
/// [RequestInfo](https://developer.apple.com/documentation/advancedcommerceapi/requestinfo)
public struct RequestInfo: Decodable, Encodable, Hashable, Sendable {
    /// The app account token for the request.
    ///
    /// [App Account Token](https://developer.apple.com/documentation/advancedcommerceapi/appaccounttoken)
    public var appAccountToken: UUID?

    /// The consistency token for the request.
    ///
    /// [Consistency Token](https://developer.apple.com/documentation/advancedcommerceapi/consistencytoken)
    public var consistencyToken: String?

    /// The request reference identifier.
    ///
    /// [Request Reference ID](https://developer.apple.com/documentation/advancedcommerceapi/requestreferenceid)
    public var requestReferenceId: UUID

    public init(appAccountToken: UUID? = nil, consistencyToken: String? = nil, requestReferenceId: UUID) {
        self.appAccountToken = appAccountToken
        self.consistencyToken = consistencyToken
        self.requestReferenceId = requestReferenceId
    }

    public enum CodingKeys: CodingKey {
        case appAccountToken
        case consistencyToken
        case requestReferenceId
    }
}

// MARK: Validatable

extension RequestInfo: Validatable {
    public func validate() throws {
        if let appAccountToken { try ValidationUtils.validUUID(appAccountToken) }
        try ValidationUtils.validUUID(requestReferenceId)
    }
}
