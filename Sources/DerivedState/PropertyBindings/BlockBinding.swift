public struct BlockBinding<Source, Destination>: PropertyBinding {
  @usableFromInline
  let _get: (Source, inout Destination) -> Void
  @usableFromInline
  let _set: (inout Source, Destination) -> Void

  @inlinable
  public init(
    get: @escaping (Source, inout Destination) -> Void,
    set: @escaping (inout Source, Destination) -> Void = { _, _ in () }
  ) {
    _get = get
    _set = set
  }

  @inlinable
  public func get(_ source: Source, _ destination: inout Destination) {
    _get(source, &destination)
  }

  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {
    _set(&source, destination)
  }
}
