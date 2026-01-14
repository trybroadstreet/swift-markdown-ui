import SwiftUI

/// The properties of a Markdown link.
///
/// The theme ``Theme/linkStyle`` link style receives a `LinkConfiguration`
/// input in its `body` closure.
public struct LinkConfiguration: Sendable {
  /// A type-erased view of a Markdown link's content.
  public struct Label: View {
    init<L: View>(_ label: L) {
      self.body = AnyView(label)
    }

    public let body: AnyView
  }

  /// The link destination URL string.
  public let destination: String?

  /// The link content view (the clickable text/label).
  public let label: Label
}
