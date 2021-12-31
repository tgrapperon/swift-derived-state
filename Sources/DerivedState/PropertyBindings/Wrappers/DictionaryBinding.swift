import Foundation

public struct DictionaryBinding<Binding, Key>: PropertyBinding
  where Binding: PropertyBinding, Key: Hashable {
  
  @usableFromInline
  let binding: Binding

  init(_ binding: Binding) {
    self.binding = binding
  }

  @inlinable
  public func get(_ source: Binding.Source, _ destination: inout [Key: Binding.Destination]) {
    for key in destination.keys {
      binding.get(source, &destination[key]!)
    }
  }

  @inlinable
  public func set(_ source: inout Binding.Source, _ destination: [Key: Binding.Destination]) {
    #if DEBUG
      fputs(
        """
        ---
        Warning: Calling setter on an Dictionary binding from \(Binding.Source.self) to \(Destination.self)

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
  func forEachValue<Key>() -> DictionaryBinding<Self, Key> {
    DictionaryBinding(self)
  }
}
