import Foundation

/// Detects which links in an array of inline nodes are citations.
/// A citation is a link surrounded by parentheses: `([link text](url))`
struct LinkCitationDetector {
  struct Result {
    let citations: Set<Int>
    let processedNodes: [InlineNode]
  }

  /// Detects citations and returns processed nodes with parentheses removed.
  /// - Parameter nodes: The original inline nodes
  /// - Returns: A result containing citation indices and nodes with stripped parentheses
  static func detectAndStripCitations(in nodes: [InlineNode]) -> Result {
    var citations: Set<Int> = []
    var processedNodes = nodes

    // First pass: detect citations
    for (index, node) in nodes.enumerated() {
      guard case .link = node else { continue }

      let hasPrecedingParen = index > 0 && nodes[index - 1].endsWithOpenParen
      let hasFollowingParen = index < nodes.count - 1 && nodes[index + 1].startsWithCloseParen

      if hasPrecedingParen && hasFollowingParen {
        citations.insert(index)
      }
    }

    // Second pass: strip parentheses around citations
    for citationIndex in citations {
      // Strip trailing "(" from preceding text node
      if citationIndex > 0,
         case .text(let text) = processedNodes[citationIndex - 1] {
        processedNodes[citationIndex - 1] = .text(String(text.dropLast()))
      }

      // Strip leading ")" from following text node
      if citationIndex < processedNodes.count - 1,
         case .text(let text) = processedNodes[citationIndex + 1] {
        processedNodes[citationIndex + 1] = .text(String(text.dropFirst()))
      }
    }

    return Result(citations: citations, processedNodes: processedNodes)
  }
}

private extension InlineNode {
  /// Returns true if this node is text ending with "("
  var endsWithOpenParen: Bool {
    guard case .text(let string) = self else { return false }
    return string.hasSuffix("(")
  }

  /// Returns true if this node is text starting with ")"
  var startsWithCloseParen: Bool {
    guard case .text(let string) = self else { return false }
    return string.hasPrefix(")")
  }
}
