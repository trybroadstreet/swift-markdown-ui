import SwiftUI

extension View {
  /// Sets the current ``Theme`` for the Markdown contents in a view hierarchy.
  /// - Parameter theme: The theme to set.
  public func markdownTheme(_ theme: Theme) -> some View {
    self.environment(\.theme, theme)
  }

  /// Replaces a specific text style of the current ``Theme`` with the given text style.
  /// - Parameters:
  ///   - keyPath: The ``Theme`` key path to the text style to replace.
  ///   - textStyle: A text style builder that returns the new text style to use for the given key path.
  public func markdownTextStyle<S: TextStyle>(
    _ keyPath: WritableKeyPath<Theme, TextStyle>,
    @TextStyleBuilder textStyle: () -> S
  ) -> some View {
    self.environment((\EnvironmentValues.theme).appending(path: keyPath), textStyle())
  }

  /// Sets a URL-aware text style provider for links in the current ``Theme``.
  /// - Parameter provider: A closure that receives the link's URL and citation status, returning the appropriate TextStyle.
  ///
  /// Use this modifier to style links conditionally based on their destination URL and context:
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
  ///   } else if url?.host == "google.com" {
  ///     ForegroundColor(.blue)
  ///   } else if url?.host == "amazon.com" {
  ///     ForegroundColor(.orange)
  ///   } else {
  ///     ForegroundColor(.purple)
  ///   }
  /// }
  /// ```
  ///
  /// This maintains inline text flow while allowing URL-based and context-aware conditional styling.
  /// Citations are links surrounded by parentheses: `([link text](url))`
  public func markdownLinkTextStyle(
    @TextStyleBuilder provider: @escaping @Sendable (URL?, Bool) -> any TextStyle
  ) -> some View {
    self.transformEnvironment(\.theme) { theme in
      theme.linkTextStyleProvider = .init(provider: provider)
    }
  }

  /// Replaces a specific block style on the current ``Theme`` with a block style initialized with the given body closure.
  /// - Parameters:
  ///   - keyPath: The ``Theme`` key path to the block style to replace.
  ///   - body: A view builder that returns the customized block.
  public func markdownBlockStyle<Body: View>(
    _ keyPath: WritableKeyPath<Theme, BlockStyle<Void>>,
    @ViewBuilder body: @escaping () -> Body
  ) -> some View {
    self.environment((\EnvironmentValues.theme).appending(path: keyPath), .init(body: body))
  }

  /// Replaces a specific block style on the current ``Theme`` with a block style initialized with the given body closure.
  /// - Parameters:
  ///   - keyPath: The ``Theme`` key path to the block style to replace.
  ///   - body: A view builder that receives the block configuration and returns the customized block.
  public func markdownBlockStyle<Configuration, Body: View>(
    _ keyPath: WritableKeyPath<Theme, BlockStyle<Configuration>>,
    @ViewBuilder body: @escaping (_ configuration: Configuration) -> Body
  ) -> some View {
    self.environment((\EnvironmentValues.theme).appending(path: keyPath), .init(body: body))
  }

  /// Sets a custom link style for rendering Markdown links with custom views.
  /// - Parameter body: A view builder that receives the link configuration and returns the customized link view.
  ///
  /// Use this modifier to provide custom rendering for links, such as adding favicons:
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
  ///     HStack(spacing: 4) {
  ///       Favicon(url).frame(width: 16, height: 16)
  ///       configuration.label
  ///     }
  ///   } else {
  ///     configuration.label
  ///   }
  /// }
  /// ```
  public func markdownLinkStyle<Body: View>(
    @ViewBuilder body: @escaping (_ configuration: LinkConfiguration) -> Body
  ) -> some View {
    self.transformEnvironment(\.theme) { theme in
      theme.linkStyle = .init(body: body)
    }
  }

  /// Replaces the current ``Theme`` task list marker with the given list marker.
  public func markdownTaskListMarker(
    _ value: BlockStyle<TaskListMarkerConfiguration>
  ) -> some View {
    self.environment(\.theme.taskListMarker, value)
  }

  /// Replaces the current ``Theme`` bulleted list marker with the given list marker.
  public func markdownBulletedListMarker(
    _ value: BlockStyle<ListMarkerConfiguration>
  ) -> some View {
    self.environment(\.theme.bulletedListMarker, value)
  }

  /// Replaces the current ``Theme`` numbered list marker with the given list marker.
  public func markdownNumberedListMarker(
    _ value: BlockStyle<ListMarkerConfiguration>
  ) -> some View {
    self.environment(\.theme.numberedListMarker, value)
  }
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}

private struct ThemeKey: EnvironmentKey {
  static let defaultValue: Theme = .basic
}
