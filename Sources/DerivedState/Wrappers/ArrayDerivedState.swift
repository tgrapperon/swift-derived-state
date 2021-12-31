public struct ArrayDerivedState<Base, ElementBinding>: DerivedStateBindingType
  where
  Base: DerivedStateBindingType,
  ElementBinding: PropertyBinding,
  Base.Source == ElementBinding.Source,
  Base.Binding.Destination == [ElementBinding.Destination]
{
  @usableFromInline
  let base: Base

  @usableFromInline
  let mapPropertyBinding: ArrayBinding<ElementBinding>

  public var propertyBinding: ElementBinding { mapPropertyBinding.binding }
  public var storage: Base.Storage { base.storage }

  @usableFromInline
  init(base: Base, binding: ElementBinding) {
    self.base = base
    self.mapPropertyBinding = binding.forEachElement()
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
  func forEach<Element>()
    -> ArrayDerivedState<Self, IdentityBinding<Source, Element>>
    where Binding == IdentityBinding<Source, [Element]> {
    .init(base: self, binding: .identity)
  }
}

public extension ArrayDerivedState {
  @inlinable
  func ro<V>(
    _ sourceValue: KeyPath<Source, V>,
    _ destinationValue: WritableKeyPath<ElementBinding.Destination, V>
  )
    -> ArrayDerivedState<
      Base,
      ZipBinding<
        ElementBinding,
        ReadOnlyBinding<KeyPathBinding<Source, ElementBinding.Destination, V>>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, KeyPathBinding(sourceValue, destinationValue).readOnly)
    return .init(base: self.base, binding: zippedBinding)
  }

  @inlinable
  func on(get: @escaping (Source, inout ElementBinding.Destination) -> Void)
    -> ArrayDerivedState<
      Base,
      ZipBinding<
        ElementBinding,
        BlockBinding<Source, ElementBinding.Destination>
      >
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, BlockBinding(get: get))
    return .init(base: self.base, binding: zippedBinding)
  }
}

public extension ArrayDerivedState {
  func eraseToAnyDerivedStateBinding() -> DerivedStateBinding<
    AnyStateStorage<Source, Destination>,
    AnyPropertyBinding<Source, Destination>
  > where Base.Destination == [ElementBinding.Destination] {
    DerivedStateBinding(
      storage: storage.eraseToAnyStateStorage,
      binding: mapPropertyBinding.eraseToAnyPropertyBinding
    )
  }
}
