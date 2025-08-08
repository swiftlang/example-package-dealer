//===----------------------------------------------------------------------===//
//
// This source file is part of the example package dealer open source project
//
// Copyright (c) 2015-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import ArgumentParser
import DeckOfPlayingCards
import Foundation
import PlayingCard

#if os(Linux)
  import Glibc
#endif

@main
struct Dealer: ParsableCommand {
  enum Error: Swift.Error, CustomStringConvertible {
    case notEnoughCards

    var description: String {
      switch self {
      case .notEnoughCards:
        return "Not enough cards"
      }
    }
  }

  static let configuration = CommandConfiguration(
    abstract: "Shuffles a deck of playing cards and deals a number of cards.",
    discussion: """
      For each count argument, prints a line of tab-delimited cards to stdout,
      or if there aren't enough cards remaining,
      prints "Not enough cards" to stderr and exits with a nonzero status.
      """)

  @Argument(
    help: .init(
      "The number of cards to deal at a time.",
      valueName: "count"))
  var counts: [UInt]

  mutating func run() throws {
    #if os(Linux)
      srandom(UInt32(clock()))
    #endif

    var deck = Deck.standard52CardDeck()
    deck.shuffle()

    for count in counts {
      var cards: [PlayingCard] = []

      for _ in 0..<count {
        guard let card = deck.deal() else {
          Self.exit(withError: Error.notEnoughCards)
        }

        cards.append(card)
      }

      print(cards.map(\.description).joined(separator: "\t"))
    }
  }
}
