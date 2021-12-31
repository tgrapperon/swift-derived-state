@_exported import DerivedState
import IdentifiedCollections

public struct IdentifiedArrayDerivedState<Base, ID, ElementBinding>: DerivedStateBindingType
  where
  Base: DerivedStateBindingType,
  ElementBinding: PropertyBinding,
  Base.Source == ElementBinding.Source,
  Base.Binding.Destination == IdentifiedArray<ID, ElementBinding.Destination>
{
  @usableFromInline
  let base: Base

  @usableFromInline
  let mapPropertyBinding: IdentifiedArrayBinding<ElementBinding, ID>

  public var propertyBinding: ElementBinding { mapPropertyBinding.binding }
  public var storage: Base.Storage { base.storage }

  @usableFromInline
  init(base: Base, binding: ElementBinding) {
    self.base = base
    self.mapPropertyBinding = binding.forEachIdentifiedElement()
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
  func forEach<ID, Element>()
    -> IdentifiedArrayDerivedState<Self, ID, IdentityBinding<Source, Element>>
    where Binding == IdentityBinding<Source, IdentifiedArray<ID, Element>> {
    .init(base: self, binding: .identity)
  }
}

public extension IdentifiedArrayDerivedState {
  @inlinable
  func ro<V>(
    _ sourceValue: KeyPath<Source, V>,
    _ destinationValue: WritableKeyPath<ElementBinding.Destination, V>
  )
    -> IdentifiedArrayDerivedState<
      Base,
      ID,
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
    -> IdentifiedArrayDerivedState<
      Base,
      ID,
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

public extension IdentifiedArrayDerivedState {
  func eraseToAnyDerivedStateBinding() -> DerivedStateBinding<
    AnyStateStorage<Source, Destination>,
    AnyPropertyBinding<Source, Destination>
  > where Base.Destination == IdentifiedArray<ID, ElementBinding.Destination> {
    DerivedStateBinding(
      storage: storage.eraseToAnyStateStorage,
      binding: mapPropertyBinding.eraseToAnyPropertyBinding
    )
  }
}
