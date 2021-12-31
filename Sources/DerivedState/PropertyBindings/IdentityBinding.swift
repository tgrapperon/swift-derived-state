public enum IdentityBinding<Source, Destination>: PropertyBinding {
  case identity
  @inlinable
  public func get(_ source: Source, _ destination: inout Destination) {}
  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {}
}
