public struct OptionalDerivedState<Base, WrappedBinding>: DerivedStateBindingType
  where
  Base: DerivedStateBindingType,
  WrappedBinding: PropertyBinding,
  Base.Source == WrappedBinding.Source,
  Base.Binding.Destination == WrappedBinding.Destination?
{
  @usableFromInline
  let base: Base

  @usableFromInline
  let mapPropertyBinding: OptionalBinding<WrappedBinding>

  public var propertyBinding: WrappedBinding { mapPropertyBinding.binding }
  public var storage: Base.Storage { base.storage }
  
  @usableFromInline
  init(base: Base, binding: WrappedBinding) {
    self.base = base
    self.mapPropertyBinding = .init(binding)
  }

  @inlinable
  public func get(_ source: Base.Storage.Source) -> Base.Storage.Destination {
    let destination = base.storage.get(source)
    guard var destination = destination as? Base.Binding.Destination else {
      fatalError()
    }
    mapPropertyBinding.get(source, &destination)
    return destination as! Destination
  }

  @inlinable
  public func set(_ source: inout Base.Storage.Source, _ newValue: Base.Storage.Destination) {
    storage.set(&source, newValue)
    guard let destination = newValue as? Base.Binding.Destination else {
      fatalError()
    }
    mapPropertyBinding.set(&source, destination)
  }
}

public extension DerivedStateBindingType {
  @inlinable
  func optional<Wrapped>() -> OptionalDerivedState<Self, IdentityBinding<Source, Wrapped>>
    where Binding == IdentityBinding<Source, Wrapped?> {
    .init(base: self, binding: .identity)
  }
}

public extension OptionalDerivedState {
  @inlinable
  func rw<Value>(
    _ sourceValue: KeyPath<Source, Value>,
    _ destinationValue: WritableKeyPath<WrappedBinding.Destination, Value>
  )
    -> OptionalDerivedState<
      Base,
      ZipBinding<
        WrappedBinding,
        KeyPathBinding<Source, WrappedBinding.Destination, Value>
      >
    >
  {
    let zippedBinding = ZipBinding(
      propertyBinding,
      KeyPathBinding(sourceValue, destinationValue)
    )
    return .init(base: self.base, binding: zippedBinding)
  }

  @inlinable
  func ro<Value>(
    _ sourceValue: KeyPath<Source, Value>,
    _ destinationValue: WritableKeyPath<WrappedBinding.Destination, Value>
  )
    -> OptionalDerivedState<
      Base,
      ZipBinding<
        WrappedBinding,
        ReadOnlyBinding<KeyPathBinding<Source, WrappedBinding.Destination, Value>>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, KeyPathBinding(sourceValue, destinationValue).readOnly)
    return .init(base: self.base, binding: zippedBinding)
  }

  @inlinable
  func on(
    get: @escaping (Source, inout WrappedBinding.Destination) -> Void,
    set: @escaping (inout Source, WrappedBinding.Destination) -> Void = { _, _ in () }
  )
    -> OptionalDerivedState<
      Base,
      ZipBinding<
        WrappedBinding,
        BlockBinding<Source, WrappedBinding.Destination>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, BlockBinding(get: get, set: set))
    return .init(base: self.base, binding: zippedBinding)
  }
}
