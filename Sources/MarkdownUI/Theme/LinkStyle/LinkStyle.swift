import SwiftUI

/// A type that applies a custom appearance to links in a Markdown view.
///
/// You can customize the appearance of links by using the `markdownLinkStyle(_:)` modifier.
///
/// The following example applies a custom appearance to links in a ``Markdown`` view,
/// showing a favicon next to each link:
///
/// ```swift
/// Markdown {
///   """
///   Check out [Google](https://google.com) and [Apple](https://apple.com).
///   """
/// }
/// .markdownLinkStyle { configuration in
///   if let urlString = configuration.destination,
///      let url = URL(string: urlString) {
///     HStack(alignment: .center, spacing: 4) {
///       Favicon(url)
///         .frame(width: 16, height: 16)
///       configuration.label
///     }
///     .foregroundColor(.primary)
///   } else {
///     configuration.label
///   }
/// }
/// ```
public struct LinkStyle<Configuration>: Sendable {
  private let body: @Sendable (Configuration) -> AnyView

  /// Creates a link style that customizes a link by applying the given body.
  /// - Parameter body: A view builder that returns the customized link view.
  public init<Body: View>(@ViewBuilder body: @escaping (_ configuration: Configuration) -> Body) {
    self.body = { AnyView(body($0)) }
  }

  func makeBody(configuration: Configuration) -> AnyView {
    self.body(configuration)
  }
}
