import Foundation
import URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct BaseURLRouter<R: ParserPrinter & Sendable>: ParserPrinter, Sendable
where R.Input == URLRequestData {
  public typealias Input = R.Input
  public typealias Output = R.Output

  private let baseURL: URL
  private let router: R

  public init(baseURL: URL, router: R) {
    self.baseURL = baseURL
    self.router = router
  }

  public func parse(_ input: inout Input) throws -> Output {
    try router.parse(&input)
  }

  public func print(_ output: Output, into input: inout Input) throws {
    try router
      .baseURL(self.baseURL.absoluteString)
      .print(output, into: &input)
  }

  public func url(for route: Output) -> String {
    self.url(for: route).absoluteString
  }
}
