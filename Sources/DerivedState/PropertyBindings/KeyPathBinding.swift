public struct KeyPathBinding<Source, Destination, Value>: PropertyBinding {
  @usableFromInline
  let sourceValue: KeyPath<Source, Value>
  @usableFromInline
  let destinationValue: WritableKeyPath<Destination, Value>
  @inlinable
  public init(
    _ sourceValue: KeyPath<Source, Value>,
    _ destinationValue: WritableKeyPath<Destination, Value>
  ) {
    self.sourceValue = sourceValue
    self.destinationValue = destinationValue
  }

  @inlinable
  public func get(_ source: Source, _ destination: inout Destination) {
    destination[keyPath: destinationValue] = source[keyPath: sourceValue]
  }

  @inlinable
  public func set(_ source: inout Source, _ destination: Destination) {
    guard let sourceValue = sourceValue as? WritableKeyPath else { return }
    source[keyPath: sourceValue] = destination[keyPath: destinationValue]
  }
}
