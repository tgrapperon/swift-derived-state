import DerivedState
import Foundation
import IdentifiedCollections

public struct IdentifiedArrayBinding<Binding, ID>: PropertyBinding
  where Binding: PropertyBinding, ID: Hashable {
  @usableFromInline
  let binding: Binding

  init(_ binding: Binding) {
    self.binding = binding
  }

  @inlinable
  public func get(_ source: Binding.Source, _ destination: inout IdentifiedArray<ID, Binding.Destination>) {
    for id in destination.ids {
      binding.get(source, &destination[id: id]!)
    }
  }

  @inlinable
  public func set(_ source: inout Binding.Source, _ destination: IdentifiedArray<ID, Binding.Destination>) {
    #if DEBUG
      fputs(
        """
        ---
        Warning: Calling setter on an IdentifiedArray binding from \(Binding.Source.self) to \(Destination.self)

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
  func forEachIdentifiedElement<ID>() -> IdentifiedArrayBinding<Self, ID> {
    IdentifiedArrayBinding(self)
  }
}
