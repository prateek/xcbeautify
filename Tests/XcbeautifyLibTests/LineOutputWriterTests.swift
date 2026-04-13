//
// LineOutputWriterTests.swift
//
// Copyright (c) 2026 Charles Pisciotta and other contributors
// Licensed under MIT License
//
// See https://github.com/cpisciotta/xcbeautify/blob/main/LICENSE for license information
//

import Foundation
import Testing
@testable import XcbeautifyLib

struct LineOutputWriterTests {
    @Test func writesToFileHandleWithoutWaitingForClose() throws {
        let pipe = Pipe()
        let writer = LineOutputWriter(fileHandle: pipe.fileHandleForWriting)
        let expected = "Build Succeeded\n"

        defer {
            try? pipe.fileHandleForReading.close()
            try? pipe.fileHandleForWriting.close()
        }

        try writer.write("Build Succeeded")

        let data = try #require(pipe.fileHandleForReading.read(upToCount: expected.utf8.count))
        #expect(String(decoding: data, as: UTF8.self) == expected)
    }

    @Test func honorsCustomTerminator() throws {
        let pipe = Pipe()
        let writer = LineOutputWriter(fileHandle: pipe.fileHandleForWriting)
        let expected = "Version: test"

        defer {
            try? pipe.fileHandleForReading.close()
            try? pipe.fileHandleForWriting.close()
        }

        try writer.write(expected, terminator: "")

        let data = try #require(pipe.fileHandleForReading.read(upToCount: expected.utf8.count))
        #expect(String(decoding: data, as: UTF8.self) == expected)
    }

    @Test func throwsWhenWritingToClosedHandle() throws {
        let pipe = Pipe()
        let writer = LineOutputWriter(fileHandle: pipe.fileHandleForWriting)
        var didThrow = false

        defer {
            try? pipe.fileHandleForReading.close()
        }

        try pipe.fileHandleForWriting.close()

        do {
            try writer.write("Build Succeeded")
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }
}
