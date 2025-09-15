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

import Foundation
import Testing

import class Foundation.Bundle

@testable import dealer

struct DealerTests {
  @Test
  func testUsage() throws {
    let (status, stdout, stderr) = try execute(with: ["--help"])
    let output = try #require(stdout)
    let error = try #require(stderr)

    #expect(status == EXIT_SUCCESS)
    #expect(
      output.starts(with: "OVERVIEW: Shuffles a deck of playing cards and deals a number of cards.")
    )
    #expect(error.isEmpty == true)
  }

  @Test(
    arguments: [
      (
        numCardsToDeal: ["1"],
        expectedNumberofCards: 1,
        id: "Deal 1 card",
      ),
      (
        numCardsToDeal: ["2"],
        expectedNumberofCards: 2,
        id: "Deal 2 card",
      ),
      (
        numCardsToDeal: ["10"],
        expectedNumberofCards: 10,
        id: "Deal 10 card",
      ),
      (
        numCardsToDeal: ["13", "13", "13", "13"],
        expectedNumberofCards: 52,
        id: "Deal 13 cards 4 times",
      ),
    ]
  )
  func testDealingNumberOfCardReturnsExpectedNumberOfCards(
    numCardsToDeal: [String],
    expectedNumberofCards: Int,
    id: String,
  ) throws {
    let (status, stdout, stderr) = try execute(with: numCardsToDeal)
    #expect(status == EXIT_SUCCESS)
    let output = try #require(stdout)
    let error = try #require(stderr)

    #expect(output.filter(\.isPlayingCardSuit).count == expectedNumberofCards)
    #expect(output.filter(\.isNewline).count == numCardsToDeal.count)
    #expect(error.isEmpty == true)
  }

  @Test
  func testDealOneHundredCards() throws {
    let (status, stdout, stderr) = try execute(with: ["100"])
    let output = try #require(stdout)
    let error = try #require(stderr)
    #expect(status != EXIT_SUCCESS)
    #expect(output.isEmpty == true)

    #expect(error == "Error: Not enough cards\n")
  }

  /// Returns path to the built products directory.
  var productsDirectory: URL {
    #if os(macOS)
      return Bundle(for: BundleMarker.self).bundleURL.deletingLastPathComponent()
    #else
      return Bundle.main.bundleURL
    #endif
  }

  private func execute(with arguments: [String] = []) throws -> (
    status: Int32, output: String?, error: String?
  ) {
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

extension Character {
  fileprivate var isPlayingCardSuit: Bool {
    switch self {
    case "♠︎", "♡", "♢", "♣︎":
      return true
    default:
      return false
    }
  }
}
