public protocol StateStorage {
  associatedtype Source
  associatedtype Destination
  func get(_ source: Source) -> Destination
  func set(_ source: inout Source, _ destination: Destination)
}

public struct AnyStateStorage<Source, Destination>: StateStorage {
  @usableFromInline
  let _get: (Source) -> Destination
  @usableFromInline
  let _set: (inout Source, Destination) -> Void

  public init<Storage>(_ stateStorage: Storage) where Storage: StateStorage,
    Storage.Source == Source, Storage.Destination == Destination {
    self._get = stateStorage.get
    self._set = stateStorage.set
  }

  public func get(_ source: Source) -> Destination {
    _get(source)
  }

  public func set(_ source: inout Source, _ destination: Destination) {
    _set(&source, destination)
  }
}

public extension StateStorage {
  var eraseToAnyStateStorage: AnyStateStorage<Source, Destination> {
    AnyStateStorage(self)
  }
}

public struct ReadOnlyStorage<Storage>: StateStorage where Storage: StateStorage {
  @usableFromInline
  let storage: Storage

  public init(_ storage: Storage) {
    self.storage = storage
  }

  public func get(_ source: Storage.Source) -> Storage.Destination {
    storage.get(source)
  }

  public func set(_ source: inout Storage.Source, _ destination: Storage.Destination) {}
}

public extension StateStorage {
  var readOnly: ReadOnlyStorage<Self> { ReadOnlyStorage(self) }
}
