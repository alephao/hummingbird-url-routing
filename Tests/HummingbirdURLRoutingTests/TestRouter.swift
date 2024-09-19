import URLRouting

enum TestRoute: Equatable {
  case home
  case nested(NestedRoute)

  enum NestedRoute: Equatable {
    case level2
  }
}

struct TestRouter: ParserPrinter {
  init() {}
  var body: some Router<TestRoute> {
    OneOf {
      Route(.case(TestRoute.home))

      Route(.case(TestRoute.nested)) {
        Path { "nested" }
        OneOf {
          Route(.case(TestRoute.NestedRoute.level2)) {
            Method.post
            Path { "level2" }
          }
        }
      }
    }
  }
}
