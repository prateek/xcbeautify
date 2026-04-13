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

    package func outputs(_ type: OutputType, _ content: String?) -> [String] {
        guard let content else { return [] }

        if !quiet, !quieter {
            return [content]
        }

        switch type {
        case OutputType.warning:
            if quieter { return [] }
            fallthrough
        case OutputType.error:
            return flushLastIfNeeded(with: content)
        case OutputType.issue:
            return [content]
        case OutputType.result:
            return [content]
        case OutputType.testCaseFailure:
            return flushLastIfNeeded(with: content)
        case OutputType.testCasePass, OutputType.testCaseSkip:
            if isCI {
                return [content]
            }
            return []
        case OutputType.nonContextualError:
            return [content]
        case OutputType.test:
            if isCI {
                lastFormatted = nil
                return [content]
            }
            fallthrough
        default:
            lastFormatted = content
            return []
        }
    }

    package func write(_ type: OutputType, _ content: String?) {
        for line in outputs(type, content) {
            writer(line)
        }
    }

    private func flushLastIfNeeded(with content: String) -> [String] {
        if let last = lastFormatted {
            lastFormatted = nil
            return [last, content]
        }

        return [content]
    }
}
