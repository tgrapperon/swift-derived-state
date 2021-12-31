public struct DictionaryDerivedState<Base, Key, ValueBinding>: DerivedStateBindingType
  where
  Base: DerivedStateBindingType,
  ValueBinding: PropertyBinding,
  Base.Source == ValueBinding.Source,
  Base.Binding.Destination == [Key: ValueBinding.Destination] {
  @usableFromInline
  let base: Base

  @usableFromInline
  let mapPropertyBinding: DictionaryBinding<ValueBinding, Key>

  public var propertyBinding: ValueBinding { mapPropertyBinding.binding }
  public var storage: Base.Storage { base.storage }

  @usableFromInline
  init(base: Base, binding: ValueBinding) {
    self.base = base
    self.mapPropertyBinding = binding.forEachValue()
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
  func forEach<Key, Element>()
    -> DictionaryDerivedState<Self, Key, IdentityBinding<Source, Element>>
    where Binding == IdentityBinding<Source, [Key: Element]> {
    .init(base: self, binding: .identity)
  }
}

public extension DictionaryDerivedState {
  @inlinable
  func ro<V>(
    _ sourceValue: KeyPath<Source, V>,
    _ destinationValue: WritableKeyPath<ValueBinding.Destination, V>
  )
    -> DictionaryDerivedState<
      Base,
      Key,
      ZipBinding<
        ValueBinding,
        ReadOnlyBinding<KeyPathBinding<Source, ValueBinding.Destination, V>>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, KeyPathBinding(sourceValue, destinationValue).readOnly)
    return .init(base: self.base, binding: zippedBinding)
  }

  @inlinable
  func on(get: @escaping (Source, inout ValueBinding.Destination) -> Void)
    -> DictionaryDerivedState<
      Base,
      Key,
      ZipBinding<
        ValueBinding,
        BlockBinding<Source, ValueBinding.Destination>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, BlockBinding(get: get))
    return .init(base: self.base, binding: zippedBinding)
  }
}

public extension DictionaryDerivedState {
  func eraseToAnyDerivedStateBinding() -> DerivedStateBinding<
    AnyStateStorage<Source, Destination>,
    AnyPropertyBinding<Source, Destination>
  > where Base.Destination == [Key: ValueBinding.Destination] {
    DerivedStateBinding(
      storage: storage.eraseToAnyStateStorage,
      binding: mapPropertyBinding.eraseToAnyPropertyBinding
    )
  }
}
