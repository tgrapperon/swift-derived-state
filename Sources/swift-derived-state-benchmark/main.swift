import Benchmark
import DerivedState
import IdentifiedCollectionsDerivedState
import Foundation

struct Parent {
  var string: String = "Root"
  var int: Int = 1
  var double: Double = 2

  var child_: Child = .init()
  var childAdHoc: Child {
    get {
      var value = child_
      value.string = string
      value.int = int
      value.double = double
      return value
    }
    set {
      child_ = newValue
      string = newValue.string
      int = newValue.int
      double = newValue.double
    }
  }

  var childKeyPath: Child {
    get {
      var value = child_
      value[keyPath: \.string] = self[keyPath: \.string]
      value[keyPath: \.int] = self[keyPath: \.int]
      value[keyPath: \.double] = self[keyPath: \.double]
      return value
    }
    set {
      child_ = newValue
      self[keyPath: \.string] = newValue[keyPath: \.string]
      self[keyPath: \.int] = newValue[keyPath: \.int]
      self[keyPath: \.double] = newValue[keyPath: \.double]
    }
  }

  static let child = DerivedState.from(\Self.child_)
    .rw(\.string, \.string)
    .rw(\.int, \.int)
    .rw(\.double, \.double)
  
    

  var childDerived: Child {
    get { Self.child.get(self) }
    set { Self.child.set(&self, newValue) }
  }
  
  static let childBlock = DerivedState<Self, Child>.with(extract: { $0.child_ }, embed: { $0.child_ = $1 })
    .on(get: { $1.string = $0.string }, set: { $0.string = $1.string })
    .on(get: { $1.int = $0.int }, set: { $0.int = $1.int })
    .on(get: { $1.double = $0.double }, set: { $0.double = $1.double })
  
  var childDerivedBlock: Child {
    get { Self.childBlock.get(self) }
    set { Self.childBlock.set(&self, newValue) }
  }

  static let erasedChild = child.eraseToAnyDerivedStateBinding()
  var childErasedDerived: Child {
    get { Self.erasedChild.get(self) }
    set { Self.erasedChild.set(&self, newValue) }
  }
}

struct Child: Identifiable {
  var id = UUID()
  var string: String = "Child"
  var int: Int = 3
  var double: Double = 4
  var internalValue: Int = -1
}

let derivedState = BenchmarkSuite(name: "Derived State") {
  var parent = Parent()
  $0.benchmark("Ad hoc") {
    parent.childAdHoc.int += 1
  }
  
  $0.benchmark("Ad hoc - get") {
    _ = parent.childAdHoc.int
  }
  
  $0.benchmark("Ad hoc - set") {
    parent.childAdHoc.int = 1
  }

  $0.benchmark("Ad hoc with KeyPaths") {
    parent.childKeyPath.int += 1
  }

  $0.benchmark("Derived State - KeyPaths") {
    parent.childDerived.int += 1
  }
  
  $0.benchmark("Derived State - KeyPaths - get") {
    _ = parent.childDerived.int
  }
  
  $0.benchmark("Derived State - KeyPaths - set") {
    parent.childDerived.int = 1
  }
  
  $0.benchmark("Derived State - Blocks") {
    parent.childDerivedBlock.int += 1
  }
  
  $0.benchmark("Derived State - Blocks - get") {
    _ = parent.childDerivedBlock.int
  }
  
  $0.benchmark("Derived State - Blocks - set") {
    parent.childDerivedBlock.int = 1
  }
  
  $0.benchmark("Erased KeyPaths Derived State") {
    parent.childErasedDerived.int += 1
  }
}

Benchmark.main([
  derivedState,
])
