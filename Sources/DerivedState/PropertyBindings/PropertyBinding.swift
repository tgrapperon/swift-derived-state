public protocol PropertyBinding {
  associatedtype Source
  associatedtype Destination
  func get(_ source: Source, _ destination: inout Destination)
  func set(_ source: inout Source, _ destination: Destination)
}

public struct AnyPropertyBinding<Source, Destination>: PropertyBinding {
  @usableFromInline
  let _get: (_ source: Source, _ destination: inout Destination) -> Void
  @usableFromInline
  let _set: (_ source: inout Source, _ newValue: Destination) -> Void

  public init<Binding>(_ propertyBinding: Binding) where Binding: PropertyBinding,
  Binding.Source == Source, Binding.Destination == Destination {
    self._get = propertyBinding.get
    self._set = propertyBinding.set
  }

  public func get(_ source: Source, _ destination: inout Destination) {
    _get(source, &destination)
  }

  public func set(_ source: inout Source, _ destination: Destination) {
    _set(&source, destination)
  }
}

extension PropertyBinding {
  public var eraseToAnyPropertyBinding: AnyPropertyBinding<Source, Destination> {
    AnyPropertyBinding(self)
  }
}

public struct ReadOnlyBinding<Binding>: PropertyBinding where Binding: PropertyBinding {
  @usableFromInline
  let binding: Binding
  
  public init(_ binding: Binding) {
    self.binding = binding
  }
  
  public func get(_ source: Binding.Source, _ destination: inout Binding.Destination) {
    binding.get(source, &destination)
  }
  public func set(_ source: inout Binding.Source, _ destination: Binding.Destination) {}
}

extension PropertyBinding {
  public var readOnly: ReadOnlyBinding<Self> { ReadOnlyBinding(self) }
}
