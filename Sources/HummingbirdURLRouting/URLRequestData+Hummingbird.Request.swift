import Foundation
import Hummingbird
import URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequestData {
  /// Initializes parseable request data from a Hummingbird request.
  ///
  /// - Parameter request: A Hummingbird request.
  public init?(request: Hummingbird.Request) async {
    guard
      let url = URL(string: request.uri.string),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }

    self.init(
      method: request.method.rawValue,
      scheme: request.uri.scheme?.rawValue,
      // TODO: Get user from basic authorization header
      user: nil,
      // TODO: Get pass from basic authorization header
      password: nil,
      host: request.uri.host,
      port: request.uri.port,
      path: request.uri.path,
      query: components.queryItems?
        .reduce(into: [:]) { query, item in
          query[item.name, default: []].append(item.value)
        } ?? [:],
      headers: .init(
        request.headers.map { field in
          (
            field.name.canonicalName,
            field.value.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
          )
        },
        uniquingKeysWith: { $0 + $1 }
      ),
      // TODO: Body
      body: nil
    )
  }
}
