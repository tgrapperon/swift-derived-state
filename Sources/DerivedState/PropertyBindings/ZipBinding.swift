public struct ZipBinding<P1, P2>: PropertyBinding
  where
  P1: PropertyBinding, P2: PropertyBinding,
  P1.Source == P2.Source, P1.Destination == P2.Destination {
  public typealias Source = P1.Source
  public typealias Destination = P1.Destination

  @usableFromInline
  let p1: P1
  @usableFromInline
  let p2: P2

  @inlinable
  public init(_ p1: P1, _ p2: P2) {
    self.p1 = p1
    self.p2 = p2
  }

  @inlinable
  public func get(_ source: Source, _ destination: inout Destination) {
    p1.get(source, &destination)
    p2.get(source, &destination)
  }

  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {
    p1.set(&source, destination)
    p2.set(&source, destination)
  }
}
