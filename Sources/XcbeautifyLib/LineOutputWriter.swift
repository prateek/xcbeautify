//
// LineOutputWriter.swift
//
// Copyright (c) 2026 Charles Pisciotta and other contributors
// Licensed under MIT License
//
// See https://github.com/cpisciotta/xcbeautify/blob/main/LICENSE for license information
//

package import Foundation

/// Writes complete output lines directly to a `FileHandle`.
package struct LineOutputWriter {
    private let fileHandle: FileHandle

    package init(fileHandle: FileHandle = .standardOutput) {
        self.fileHandle = fileHandle
    }

    package func write(_ content: String, terminator: String = "\n") {
        fileHandle.write(Data((content + terminator).utf8))
    }
}
