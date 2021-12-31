import ComposableState
import XCTest

final class ComposableStateTests: XCTestCase {
  func testComposableStateScope() {
    struct Parent: Equatable {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2

      var child_: Child = .init()
      static let child = DerivedState
        .from(Self.self, updating: Child.init)
        .rw(\.string, \.string)
        .rw(\.int, \.int)
        .rw(\.double, \.double)
    }

    enum ParentAction {
      case child(ChildAction)
      case negateInt(Int)
    }

    struct Child: Equatable {
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    enum ChildAction {
      case int(Int)
    }

    let childReducer = Reducer<Child, ChildAction, Void> {
      state, action, _ in
      switch action {
      case let .int(value):
        state.int = value
        return .none
      }
    }

    let parentReducer = Reducer<Parent, ParentAction, Void>.combine(
      childReducer.pullback(
        state: Parent.child,
        action: /ParentAction.child,
        environment: { _ in () }
      ),
      Reducer<Parent, ParentAction, Void> {
        state, action, _ in
        switch action {
        case .child:
          return .none
        case let .negateInt(value):
          state.int = -value
          return .none
        }
      }
    )

    let parentStore = Store(initialState: .init(), reducer: parentReducer, environment: ())
    let childStore = parentStore.scope(state: Parent.child, action: ParentAction.child)

    let parent = ViewStore(parentStore)
    let child = ViewStore(childStore)

    XCTAssertEqual(parent.int, child.int)
    XCTAssertEqual(parent.string, child.string)
    XCTAssertEqual(parent.double, child.double)

    child.send(.int(100))
    XCTAssertEqual(child.int, 100)
    XCTAssertEqual(parent.int, child.int)
    XCTAssertEqual(parent.string, child.string)
    XCTAssertEqual(parent.double, child.double)

    parent.send(.negateInt(1000))
    XCTAssertEqual(parent.int, -1000)
    XCTAssertEqual(parent.int, child.int)
    XCTAssertEqual(parent.string, child.string)
    XCTAssertEqual(parent.double, child.double)
  }
}
