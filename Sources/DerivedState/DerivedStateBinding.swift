public struct DerivedStateBinding<Storage, Binding>: DerivedStateBindingType
  where
  Storage: StateStorage,
  Binding: PropertyBinding,
  Storage.Source == Binding.Source,
  Storage.Destination == Binding.Destination
{
  public let storage: Storage
  public let propertyBinding: Binding

  public init(storage: Storage, binding: Binding) {
    self.storage = storage
    self.propertyBinding = binding
  }
  
  @inlinable
  public func get(_ source: Storage.Source) -> Storage.Destination {
    var destination = storage.get(source)
    propertyBinding.get(source, &destination)
    return destination
  }

  @inlinable
  public func set(_ source: inout Storage.Source, _ newValue: Storage.Destination) {
    storage.set(&source, newValue)
    propertyBinding.set(&source, newValue)
  }
}

public extension DerivedStateBinding {
  /// Append a read-write binding between a property from `Source` and a property from
  /// `Destination`.
  ///
  /// - Parameters:
  ///   - sourceValue: A `KeyPath` from `Source`.
  ///   - destinationValue: A `KeyPath` from `Destination`.
  /// - Returns: A `DerivedStateBinding` with these properties bound.
  @inlinable
  func rw<Value>(
    _ sourceValue: WritableKeyPath<Source, Value>,
    _ destinationValue: WritableKeyPath<Destination, Value>
  )
    -> DerivedStateBinding<
      Storage,
      ZipBinding<Binding, KeyPathBinding<Source, Destination, Value>>
    >
  {
    .init(
      storage: storage,
      binding: ZipBinding(
        propertyBinding,
        KeyPathBinding(sourceValue, destinationValue)
      )
    )
  }

  /// Append a read-only binding between a property from `Source` and a property from
  /// `Destination`.
  ///
  /// - Parameters:
  ///   - sourceValue: A `KeyPath` from `Source`.
  ///   - destinationValue: A `KeyPath` from `Destination`.
  /// - Returns: A `DerivedStateBinding` with these properties bound.
  @inlinable
  func ro<Value>(
    _ sourceValue: KeyPath<Source, Value>,
    _ destinationValue: WritableKeyPath<Destination, Value>
  )
    -> DerivedStateBinding<
      Storage, ZipBinding<Binding, ReadOnlyBinding<KeyPathBinding<Source, Destination, Value>>>
    >
  {
    .init(
      storage: storage,
      binding: ZipBinding(propertyBinding, KeyPathBinding(sourceValue, destinationValue).readOnly)
    )
  }
  
  /// Append a block binding between a property from `Source` and a property from
  /// `Destination`.
  ///
  /// - Parameters:
  ///   - get: A block that sets `Destination` from `Source`, by modifying the `Destination` inout
  ///   parameter.
  ///   - set: A block that sets `Source` from `Destination`, by modifying the `Source` inout
  ///   parameter.
  /// - Returns: A `DerivedStateBinding` with these properties bound.
  @inlinable
  func on(
    get: @escaping (Source, inout Destination) -> Void,
    set: @escaping (inout Source, Destination) -> Void = { _, _ in () }
  )
    -> DerivedStateBinding<
      Storage, ZipBinding<Binding, BlockBinding<Source, Destination>>
    >
  {
    let zippedBinding = ZipBinding(propertyBinding, BlockBinding(get: get, set: set))
    return .init(storage: storage, binding: zippedBinding)
  }
}

public extension DerivedStateBindingType {
  func eraseToAnyDerivedStateBinding() -> DerivedStateBinding<
    AnyStateStorage<Source, Destination>,
    AnyPropertyBinding<Source, Destination>
  >
    where Binding.Destination == Destination {
    DerivedStateBinding(
      storage: storage.eraseToAnyStateStorage,
      binding: propertyBinding.eraseToAnyPropertyBinding
    )
  }

  subscript(source: Source) -> Destination {
    self.get(source)
  }

  func callAsFunction(_ source: Source) -> Destination {
    self.get(source)
  }

  func callAsFunction(_ source: inout Source, _ destination: Destination) {
    self.set(&source, destination)
  }
}
