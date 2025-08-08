//===----------------------------------------------------------------------===//
//
// This source file is part of the example package dealer open source project
//
// Copyright (c) 2021-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//


import Testing
import Foundation
import class Foundation.Bundle

final class Marker {
}

struct DealerTests {
    @Test
    func testUsage() throws {
        let (status, output, error) = try execute(with: ["--help"])
        #expect(status == EXIT_SUCCESS)
        #expect(output?.starts(with: "OVERVIEW: Shuffles a deck of playing cards and deals a number of cards.") ?? false)
        #expect(error == "")
    }

    @Test
    func testDealOneCard() throws {
        let (status, output, error) = try execute(with: ["1"])
        #expect(status == EXIT_SUCCESS)
        #expect(output?.filter(\.isPlayingCardSuit).count == 1)
        
        #expect(error == "")
    }

    @Test
    func testDealTenCards() throws {
        let (status, output, error) = try execute(with: ["10"])
        #expect(status == EXIT_SUCCESS)
        #expect(output?.filter(\.isPlayingCardSuit).count == 10)
        
        #expect(error == "")
    }

    @Test
    func testDealThirteenCardsFourTimes() throws {
        let (status, output, error) = try execute(with: ["13", "13", "13", "13"])
        #expect(status == EXIT_SUCCESS)
        #expect(output?.filter(\.isPlayingCardSuit).count == 52)
        #expect(output?.filter(\.isNewline).count == 4)
        
        #expect(error == "")
    }

    @Test
    func testDealOneHundredCards() throws {
        let (status, output, error) = try execute(with: ["100"])
        #expect(status != EXIT_SUCCESS)
        #expect(output == "")
        #expect(error == "Error: Not enough cards\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    private func execute(with arguments: [String] = []) throws -> (status: Int32, output: String?, error: String?) {
        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("dealer")
        process.arguments = arguments

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let status = process.terminationStatus

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorData, encoding: .utf8)

        return (status, output, error)
    }
}

// MARK: -

private extension Character {
    var isPlayingCardSuit: Bool {
        switch self {
        case "♠︎", "♡", "♢", "♣︎":
            return true
        default:
            return false
        }
    }
}
