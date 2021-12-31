public struct OptionalBinding<Binding>: PropertyBinding
where Binding: PropertyBinding {
  @usableFromInline
  let binding: Binding
  @usableFromInline
  init(_ binding: Binding) {
    self.binding = binding
  }

  public func get(_ source: Binding.Source, _ destination: inout Binding.Destination?) {
    guard var unwrappedDestination = destination else { return }
    binding.get(source, &unwrappedDestination)
    destination = unwrappedDestination
  }

  public func set(_ source: inout Binding.Source, _ destination: Binding.Destination?) {
    guard let destination = destination else { return }
    binding.set(&source, destination)
  }
}

extension PropertyBinding {
  func optional() -> OptionalBinding<Self> {
    OptionalBinding(self)
  }
}
