public enum DerivedState<Source, Destination> {
  @inlinable
  /// Create a `DerivedStateBinding` basing its storage on a stored property of `Source`.
  ///
  /// This variant should be used when the derived state has internal properties that are
  /// not set from `Source`.
  ///
  /// - Parameters:
  ///   - storage: A `KeyPath` to the storage.
  /// - Returns: A `DerivedStateBinding` with internal storage in `Source`.
  public static func from(_ storage: KeyPath<Source, Destination>) ->
    DerivedStateBinding<
      KeyPathStorage<Source, Destination>,
      IdentityBinding<Source, Destination>
    > {
    DerivedStateBinding(
      storage: KeyPathStorage(keyPath: storage),
      binding: IdentityBinding.identity
    )
  }
  
  /// Create a `DerivedStateBinding` without internal storage.
  ///
  /// This variant should be used when the derived state has no internal properties and `Source`
  /// is able to set all the properties of `Destination`.
  ///
  /// - Parameters:
  ///   - source: The source's type.
  ///   - updating: An argument-less closure that create a standard instance of `Destination`.
  /// - Returns: A `DerivedStateBinding` without internal storage, where `Source` hosts explicitly
  /// all the information.
  @inlinable
  public static func from(_ source: Source.Type, updating value: @escaping () -> Destination) ->
    DerivedStateBinding<
      BlockStorage<Source, Destination>,
      IdentityBinding<Source, Destination>
    > {
    DerivedStateBinding(
      storage: BlockStorage(get: { _ in value() }),
      binding: IdentityBinding.identity
    )
  }

  /// Create a `DerivedStateBinding` without internal storage
  ///
  /// This variant should be used when the derived state has no internal properties, `Source`
  /// is able to set all the properties of `Destination`, and the initial value of `Destination`
  /// may depend on `Source`'s state.
  ///
  /// - Parameters:
  ///   - extract: A function of `Source` that returns an unconfigured instance of `Destination`.
  ///   - embed: A function that update `Source`'s storage when a new value of `Destination` is set.
  /// - Returns: A `DerivedStateBinding` without internal storage, where `Source` hosts explicitly
  /// all the information.
  @inlinable
  public static func with(
    extract: @escaping (Source) -> Destination,
    embed: @escaping (_ source: inout Source, _ newValue: Destination) -> Void = { _, _ in () }
  ) ->
    DerivedStateBinding<
      BlockStorage<Source, Destination>,
      IdentityBinding<Source, Destination>
    > {
    DerivedStateBinding(
      storage: BlockStorage(get: extract, set: embed),
      binding: IdentityBinding.identity
    )
  }
}
