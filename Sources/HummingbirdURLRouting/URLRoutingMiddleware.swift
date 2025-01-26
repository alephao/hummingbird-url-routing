import Hummingbird
import URLRouting

public struct URLRoutingMiddleware<R: Parser & Sendable, Context: RequestContext>: RouterMiddleware
where R.Input == URLRequestData {
  let router: R
  let throwErrorOnRoutingMismatch: Bool
  let respond:
    @Sendable (Hummingbird.Request, Context, R.Output) async throws -> Hummingbird.ResponseGenerator

  public init(
    router: R,
    throwErrorOnRoutingMismatch: Bool,
    _ respond: @Sendable @escaping (Hummingbird.Request, Context, R.Output) async throws ->
      Hummingbird.ResponseGenerator
  ) {
    self.router = router
    self.throwErrorOnRoutingMismatch = throwErrorOnRoutingMismatch
    self.respond = respond
  }

  public init(
    router: R,
    _ respond: @Sendable @escaping (Hummingbird.Request, Context, R.Output) async throws ->
      Hummingbird.ResponseGenerator
  ) {
    self.router = router
    #if DEBUG
      self.throwErrorOnRoutingMismatch = false
    #else
      self.throwErrorOnRoutingMismatch = true
    #endif
    self.respond = respond
  }

  public func handle(
    _ request: Hummingbird.Request,
    context: Context,
    next: (Hummingbird.Request, Context) async throws -> Hummingbird.Response
  ) async throws -> Hummingbird.Response {
    guard let requestData = await URLRequestData(request: request)
    else { return try await next(request, context) }
    let route: R.Output
    do {
      route = try self.router.parse(requestData)
    } catch let routingError {
      do {
        return try await next(request, context)
      } catch {
        context.logger.debug("\(routingError)")
        if self.throwErrorOnRoutingMismatch {
          throw error
        } else {
          return Response(
            status: .notFound,
            body: .init(byteBuffer: .init(string: "Routing Error: \(routingError)"))
          )
        }
      }
    }
    return try await self.respond(request, context, route).response(from: request, context: context)
  }
}
