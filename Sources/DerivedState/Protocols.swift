public protocol DerivedStateType {
  associatedtype Source
  associatedtype Destination
  func get(_ source: Source) -> Destination
  func set(_ source: inout Source, _ newValue: Destination)
}

public protocol DerivedStateBindingType: DerivedStateType {
  associatedtype Storage: StateStorage
    where Storage.Source == Source, Storage.Destination == Destination
  associatedtype Binding: PropertyBinding
    where Binding.Source == Source
  var storage: Storage { get }
  var propertyBinding: Binding { get }
}
