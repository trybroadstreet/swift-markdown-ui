import SwiftUI

/// A view that renders inline content with custom link styling using a flow layout.
///
/// This view breaks apart inline nodes into segments (text and links) and arranges them
/// using a flow layout, allowing custom link views to be rendered inline with text.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct LinkFlow: View {
  @Environment(\.baseURL) private var baseURL
  @Environment(\.theme) private var theme

  private enum Item {
    case text(String)
    case link(destination: String?, text: String)
    case softBreak
    case lineBreak
  }

  private let items: [Indexed<Item>]

  var body: some View {
    TextStyleAttributesReader { attributes in
      let spacing = RelativeSize.rem(0.1).points(relativeTo: attributes.fontProperties)

      FlowLayout(horizontalSpacing: spacing, verticalSpacing: spacing) {
        ForEach(self.items, id: \.index) { item in
          self.makeView(for: item.value, attributes: attributes)
        }
      }
    }
  }

  @ViewBuilder
  private func makeView(for item: Item, attributes: AttributeContainer) -> some View {
    switch item {
    case .text(let string):
      Text(AttributedString(string, attributes: attributes))
    case .link(let destination, let text):
      if let linkStyle = self.theme.linkStyle {
        linkStyle.makeBody(
          configuration: .init(
            destination: destination,
            label: .init(Text(text))
          )
        )
      } else {
        // Fallback to text-only rendering with link styling
        let linkText = {
          var linkAttributes = attributes
          self.theme.link._collectAttributes(in: &linkAttributes)
          return Text(AttributedString(text, attributes: linkAttributes))
        }()
        linkText
      }
    case .softBreak:
      Text(" ")
    case .lineBreak:
      Spacer()
    }
  }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension LinkFlow {
  /// Creates a LinkFlow view if the theme has a custom linkStyle set.
  /// Returns nil if there's no custom linkStyle, allowing fallback to InlineText.
  init?(_ inlines: [InlineNode], theme: Theme) {
    // Only use LinkFlow if a custom linkStyle is set
    guard theme.linkStyle != nil else {
      return nil
    }

    var items: [Item] = []

    func addInline(_ inline: InlineNode) {
      switch inline {
      case let .text(text) where !text.isEmpty:
        items.append(.text(text))
      case .softBreak:
        items.append(.softBreak)
      case .lineBreak:
        items.append(.lineBreak)
      case let .link(destination, children):
        let linkText = children.renderPlainText()
        items.append(.link(destination: destination, text: linkText))
      case let .code(text):
        items.append(.text(text))
      case let .emphasis(children):
        for child in children {
          addInline(child)
        }
      case let .strong(children):
        for child in children {
          addInline(child)
        }
      case let .strikethrough(children):
        for child in children {
          addInline(child)
        }
      case let .image(_, children):
        // For now, just render image alt text
        let alt = children.renderPlainText()
        items.append(.text(alt))
      case .html:
        // Skip HTML
        break
      case .text:
        // Already handled above
        break
      }
    }

    for inline in inlines {
      addInline(inline)
    }

    self.items = items.indexed()
  }
}
