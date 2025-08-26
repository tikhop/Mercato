import Foundation
import os

// MARK: - Lock

package protocol Lock: Sendable {
    func lock()
    func unlock()
    func run<T: Sendable>(_ closure: @Sendable () throws -> T) rethrows -> T
}

// MARK: - DefaultLock

package final class DefaultLock: Lock {
    private nonisolated let defaultLock: Lock = {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return OSAUnfairLock()
        } else {
            return NSLock()
        }
    }()

    public init() { }

    public func lock() {
        defaultLock.lock()
    }

    public func unlock() {
        defaultLock.unlock()
    }

    public func run<T>(_ closure: @Sendable () throws -> T) rethrows -> T where T: Sendable {
        try defaultLock.run(closure)
    }
}

// MARK: - OSAUnfairLock

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

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
package final class OSAUnfairLock: Lock {
    private let unfairLock = OSAllocatedUnfairLock()

    public init() { }

    public func lock() {
        unfairLock.lock()
    }

    public func unlock() {
        unfairLock.unlock()
    }

    public func run<T: Sendable>(_ closure: @Sendable () throws -> T) rethrows -> T {
        try unfairLock.withLock {
            try closure()
        }
    }
}

// MARK: - NSLock + Lock

extension NSLock: Lock {
    public func run<T>(_ closure: @Sendable () throws -> T) rethrows -> T where T : Sendable {
        lock()
        let v = try closure()
        unlock()
        return v
    }
}
