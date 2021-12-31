import XCTest
import DerivedState

final class DerivedStateTests: XCTestCase {
  func testKeyPathStorageBinding() {

    struct Parent {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2
      var child_: Child = .init()
      static let child = DerivedState.from(\Self.child_)
        .rw(\.string, \.string)
        .rw(\.int, \.int)
        .rw(\.double, \.double)
        
      var child: Child {
        get { Self.child(self) }
        set { Self.child(&self, newValue) }
      }
    }

    struct Child {
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    var parent = Parent()
    XCTAssertEqual(parent.child.string, parent.string)
    XCTAssertEqual(parent.child.int, parent.int)
    XCTAssertEqual(parent.child.double, parent.double)

    parent.string = "Updated"
    parent.int += 1
    parent.double += 1

    XCTAssertEqual(parent.child.string, parent.string)
    XCTAssertEqual(parent.child.int, parent.int)
    XCTAssertEqual(parent.child.double, parent.double)

    parent.child.string = "Updated Again"
    parent.child.int += 1
    parent.child.double += 1
    parent.child.internalValue = -2

    XCTAssertEqual(parent.child.string, parent.string)
    XCTAssertEqual(parent.child.int, parent.int)
    XCTAssertEqual(parent.child.double, parent.double)
    XCTAssertEqual(parent.child_.internalValue, -2)
    XCTAssertEqual(parent.child.internalValue, -2)

  }
  
  func testOptionalKeyPathStorageBinding() {

    struct Parent {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2
      var child_: Child? = .init()
      static let child = DerivedState.from(\Self.child_)
        .optional()
        .rw(\.string, \.string)
        .rw(\.int, \.int)
        .rw(\.double, \.double)

      var child: Child? {
        get { Self.child.get(self) }
        set { Self.child.set(&self, newValue) }
      }
    }

    struct Child {
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    var parent = Parent()
    XCTAssertEqual(parent.child?.string, parent.string)
    XCTAssertEqual(parent.child?.int, parent.int)
    XCTAssertEqual(parent.child?.double, parent.double)

    parent.string = "Updated"
    parent.int += 1
    parent.double += 1

    XCTAssertEqual(parent.child?.string, parent.string)
    XCTAssertEqual(parent.child?.int, parent.int)
    XCTAssertEqual(parent.child?.double, parent.double)

    parent.child?.string = "Updated Again"
    parent.child?.int += 1
    parent.child?.double += 1
    parent.child?.internalValue = -2

    XCTAssertEqual(parent.child?.string, parent.string)
    XCTAssertEqual(parent.child?.int, parent.int)
    XCTAssertEqual(parent.child?.double, parent.double)
    XCTAssertEqual(parent.child_?.internalValue, -2)
    XCTAssertEqual(parent.child?.internalValue, -2)

  }

  func testNilOptionalKeyPathStorageBinding() {

    struct Parent {
      var string: String = "Root"
      var int: Int = 1
      var double: Double = 2
      var child_: Child? = nil
      static let child = DerivedState.from(\Self.child_)
        .optional()
        .rw(\.string, \.string)
        .rw(\.int, \.int)
        .rw(\.double, \.double)

      var child: Child? {
        get { Self.child.get(self) }
        set { Self.child.set(&self, newValue) }
      }
    }

    struct Child {
      var string: String = "Child"
      var int: Int = 3
      var double: Double = 4
      var internalValue: Int = -1
    }

    var parent = Parent()
    XCTAssertEqual(parent.child?.string, nil)
    XCTAssertEqual(parent.child?.int, nil)
    XCTAssertEqual(parent.child?.double, nil)

    parent.string = "Updated"
    parent.int += 1
    parent.double += 1

    XCTAssertEqual(parent.child?.string, nil)
    XCTAssertEqual(parent.child?.int, nil)
    XCTAssertEqual(parent.child?.double, nil)

    parent.child?.string = "Updated Again"
    parent.child?.int += 1
    parent.child?.double += 1
    parent.child?.internalValue = -2

    XCTAssertEqual(parent.string, "Updated")
    XCTAssertEqual(parent.int, 2)
    XCTAssertEqual(parent.double, 3)
  }
}
