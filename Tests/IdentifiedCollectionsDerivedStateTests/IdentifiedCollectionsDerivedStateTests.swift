import DerivedState
import IdentifiedCollections
import IdentifiedCollectionsDerivedState
import XCTest

final class IdentifiedCollectionsDerivedStateTests: XCTestCase {
  func testIdentifiedArrayKeyPathStorageBinding() {
    struct Parent {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2
      var child_: IdentifiedArrayOf<Child> = [.init(), .init()]
      static let child = DerivedState.from(\Self.child_)
        .forEach()
        .ro(\.string, \.string)
        .ro(\.int, \.int)
        .ro(\.double, \.double)
        .eraseToAnyDerivedStateBinding()

      var child: IdentifiedArrayOf<Child> {
        get { Self.child.get(self) }
        set { Self.child.set(&self, newValue) }
      }
    }

    struct Child: Identifiable {
      var id = UUID()
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    var parent = Parent()
    XCTAssertEqual(parent.child[0].string, parent.string)
    XCTAssertEqual(parent.child[0].int, parent.int)
    XCTAssertEqual(parent.child[0].double, parent.double)

    XCTAssertEqual(parent.child[1].string, parent.string)
    XCTAssertEqual(parent.child[1].int, parent.int)
    XCTAssertEqual(parent.child[1].double, parent.double)

    parent.string = "Updated"
    parent.int += 1
    parent.double += 1

    XCTAssertEqual(parent.child[0].string, parent.string)
    XCTAssertEqual(parent.child[0].int, parent.int)
    XCTAssertEqual(parent.child[0].double, parent.double)

    XCTAssertEqual(parent.child[1].string, parent.string)
    XCTAssertEqual(parent.child[1].int, parent.int)
    XCTAssertEqual(parent.child[1].double, parent.double)
  }

  func testOptionalArrayKeyPathStorageBinding() {
    struct Parent {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2
      var child_: IdentifiedArrayOf<Child>? = [.init(), .init()]

      static let child = DerivedState.from(\Self.child_)
        .optional()
        .forEach()
        .ro(\.string, \.string)
        .ro(\.int, \.int)
        .ro(\.double, \.double)

      var child: IdentifiedArrayOf<Child>? {
        get { Self.child.get(self) }
        set { Self.child.set(&self, newValue) }
      }
    }

    struct Child: Identifiable {
      var id = UUID()
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    var parent = Parent()
    XCTAssertEqual(parent.child?[0].string, parent.string)
    XCTAssertEqual(parent.child?[0].int, parent.int)
    XCTAssertEqual(parent.child?[0].double, parent.double)

    XCTAssertEqual(parent.child?[1].string, parent.string)
    XCTAssertEqual(parent.child?[1].int, parent.int)
    XCTAssertEqual(parent.child?[1].double, parent.double)

    parent.string = "Updated"
    parent.int += 1
    parent.double += 1

    XCTAssertEqual(parent.child?[0].string, parent.string)
    XCTAssertEqual(parent.child?[0].int, parent.int)
    XCTAssertEqual(parent.child?[0].double, parent.double)

    XCTAssertEqual(parent.child?[1].string, parent.string)
    XCTAssertEqual(parent.child?[1].int, parent.int)
    XCTAssertEqual(parent.child?[1].double, parent.double)
  }
}
