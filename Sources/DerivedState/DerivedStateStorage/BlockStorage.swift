public struct BlockStorage<Source, Destination>: StateStorage {
  @usableFromInline
  let _get: (Source) -> Destination
  @usableFromInline
  let _set: (_ source: inout Source, _ destination: Destination) -> Void
  @usableFromInline
  init(
    get: @escaping (Source) -> Destination,
    set: @escaping (_ source: inout Source, _ destination: Destination) -> Void = { _, _ in () }
  ) {
    _get = get
    _set = set
  }

  @inlinable
  public func get(_ source: Source) -> Destination {
    _get(source)
  }

  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {
    _set(&source, destination)
  }
}
