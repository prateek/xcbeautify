//
// OutputHandler.swift
//
// Copyright (c) 2026 Charles Pisciotta and other contributors
// Licensed under MIT License
//
// See https://github.com/cpisciotta/xcbeautify/blob/main/LICENSE for license information
//

import Foundation

/// Filters formatted output by `OutputType` only if `quiet` or `quieter` are specified.
package final class OutputHandler {
    let quiet: Bool
    let quieter: Bool
    let isCI: Bool
    let writer: (String) -> Void

    /// In quiet mode, lastFormatted will record last output and whether it will be
    /// printed is determined by the current output type. In this way, if we encounter
    /// warnings or errors, we get a chance to print last output as their banner. So now
    /// the output is in following form:
    /// [Target] Doing Something
    /// warnings or errors
    ///
    /// Ref: https://github.com/cpisciotta/xcbeautify/pull/15
    private var lastFormatted: String?

    package init(quiet: Bool, quieter: Bool, isCI: Bool = false, _ writer: @escaping (String) -> Void = { _ in }) {
        self.quiet = quiet
        self.quieter = quieter
        self.isCI = isCI
        self.writer = writer
    }

    package func consume(_ type: OutputType, _ content: String?, _ sink: (String) throws -> Void) rethrows {
        guard let content else { return }

        if !quiet, !quieter {
            try sink(content)
            return
        }

        switch type {
        case OutputType.warning:
            if quieter { return }
            fallthrough
        case OutputType.error:
            try flushLastIfNeeded(with: content, sink)
        case OutputType.issue:
            try sink(content)
        case OutputType.result:
            try sink(content)
        case OutputType.testCaseFailure:
            try flushLastIfNeeded(with: content, sink)
        case OutputType.testCasePass, OutputType.testCaseSkip:
            if isCI {
                try sink(content)
            }
        case OutputType.nonContextualError:
            try sink(content)
        case OutputType.test:
            if isCI {
                lastFormatted = nil
                try sink(content)
                return
            }
            fallthrough
        default:
            lastFormatted = content
        }
    }

    package func write(_ type: OutputType, _ content: String?) {
        consume(type, content, writer)
    }

    private func flushLastIfNeeded(with content: String, _ sink: (String) throws -> Void) rethrows {
        if let last = lastFormatted {
            lastFormatted = nil
            try sink(last)
        }

        try sink(content)
    }
}
