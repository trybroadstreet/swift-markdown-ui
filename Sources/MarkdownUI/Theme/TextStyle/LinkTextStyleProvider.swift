import Foundation

/// A provider that returns a TextStyle based on the link's destination URL and context.
///
/// Use this to conditionally style links based on their URL or whether they are citations:
///
/// ```swift
/// Markdown {
///   """
///   Visit [Google](https://google.com) and see ([this article](https://example.com)).
///   """
/// }
/// .markdownLinkTextStyle { url, isCitation in
///   if isCitation {
///     ForegroundColor(.secondary)
///       .fontWeight(.regular)
///   } else if url?.host == "google.com" {
///     ForegroundColor(.blue)
///   } else {
///     ForegroundColor(.purple)
///   }
/// }
/// ```
///
/// A citation is a link surrounded by parentheses: `([link text](url))`
public struct LinkTextStyleProvider {
  private let provider: (URL?, Bool) -> any TextStyle

  /// Creates a link text style provider with the given closure.
  /// - Parameter provider: A closure that receives the link's URL and citation status, returning the TextStyle to apply.
  public init(@TextStyleBuilder provider: @escaping (URL?, Bool) -> any TextStyle) {
    self.provider = provider
  }

  /// Returns the TextStyle for the given URL and citation status.
  /// - Parameters:
  ///   - url: The link's destination URL
  ///   - isCitation: Whether the link is a citation (surrounded by parentheses)
  func textStyle(for url: URL?, isCitation: Bool) -> any TextStyle {
    self.provider(url, isCitation)
  }
}
