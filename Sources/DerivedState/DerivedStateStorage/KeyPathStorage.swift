public struct KeyPathStorage<Source, Destination>: StateStorage {
  @usableFromInline
  let keyPath: KeyPath<Source, Destination>

  @usableFromInline
  init( keyPath: KeyPath<Source, Destination> ) {
    self.keyPath = keyPath
  }

  @inlinable
  public func get(_ source: Source) -> Destination {
    source[keyPath: keyPath]
  }

  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {
    guard let keyPath = keyPath as? WritableKeyPath else { return }
    source[keyPath: keyPath] = destination
  }
}

