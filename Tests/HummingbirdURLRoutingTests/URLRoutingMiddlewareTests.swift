import Hummingbird
import HummingbirdTesting
import HummingbirdURLRouting
import XCTest

@Sendable func testRouterHandler<C: RequestContext>(req: Request, ctx: C, route: TestRoute)
  async throws -> Response
{
  switch route {
  case .home:
    return Response(
      status: .ok,
      headers: [.accept: "home"],
      body: .init(byteBuffer: .init(string: "home"))
    )
  case .nested(.level2):
    return Response(
      status: .ok,
      headers: [.accept: "nested/level2"],
      body: .init(byteBuffer: .init(string: "nested/level2"))
    )
  }
}

final class URLRoutingMiddlewareTests: XCTestCase {
  var app: Application<RouterResponder<BasicRequestContext>>!

  override func setUp() async throws {
    let router = Router()
    router.middlewares.add(
      URLRoutingMiddleware(router: TestRouter(), testRouterHandler(req:ctx:route:))
    )
    app = Application(responder: router.buildResponder())
  }

  func testGetHome() async throws {
    try await app.test(.router) { client in
      try await client.execute(uri: "/", method: .get) { response in
        XCTAssertEqual(String(buffer: response.body), "home")
        XCTAssertEqual(response.headers[.accept], "home")
      }
    }
  }

  func testPostHome() async throws {
    try await app.test(.router) { client in
      try await client.execute(uri: "/", method: .post) { response in
        XCTAssertEqual(response.status, .notFound)
      }
    }
  }

  func testGetNestedLevel2() async throws {
    try await app.test(.router) { client in
      try await client.execute(uri: "/nested/level2", method: .get) { response in
        XCTAssertEqual(response.status, .notFound)
      }
    }
  }

  func testPostNestedLevel2() async throws {
    try await app.test(.router) { client in
      try await client.execute(uri: "/nested/level2", method: .post) { response in
        XCTAssertEqual(String(buffer: response.body), "nested/level2")
        XCTAssertEqual(response.headers[.accept], "nested/level2")
      }
    }
  }
}
