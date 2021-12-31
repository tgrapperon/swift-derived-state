import Foundation

public struct ArrayBinding<Binding>: PropertyBinding
  where Binding: PropertyBinding {
  
  @usableFromInline
  let binding: Binding

  init(_ binding: Binding) {
    self.binding = binding
  }

  @inlinable
  public func get(_ source: Binding.Source, _ destination: inout [Binding.Destination]) {
    for idx in destination.indices {
      binding.get(source, &destination[idx])
    }
  }

  @inlinable
  public func set(_ source: inout Binding.Source, _ destination: [Binding.Destination]) {
    #if DEBUG
      fputs(
        """
        ---
        Warning: Calling setter on an Array binding from \(Binding.Source.self) to \(Destination.self)

        * TODO: Explain why this is problematic.
        ---

        """,
        stderr
      )
      raise(SIGTRAP)
    #endif
  }
}

extension PropertyBinding {
  func forEachElement() -> ArrayBinding<Self> {
    ArrayBinding(self)
  }
}
