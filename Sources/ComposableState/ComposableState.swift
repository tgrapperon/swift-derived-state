@_exported import ComposableArchitecture
@_exported import DerivedState
@_exported import IdentifiedCollectionsDerivedState

public extension Store {
  func scope<DerivedState, LocalAction>(
    state toLocalState: DerivedState,
    action fromLocalAction: @escaping (LocalAction) -> Action
  ) -> Store<DerivedState.Destination, LocalAction>
    where DerivedState: DerivedStateType, DerivedState.Source == State {
    self.scope(state: toLocalState.get, action: fromLocalAction)
  }

  func scope<DerivedState>(state toLocalState: DerivedState)
    -> Store<DerivedState.Destination, Action>
    where DerivedState: DerivedStateType, DerivedState.Source == State {
    self.scope(state: toLocalState.get, action: { $0 })
  }
}

public extension Reducer {
  func pullback<DerivedState, GlobalAction, GlobalEnvironment>(
    state toLocalState: DerivedState,
    action toLocalAction: CasePath<GlobalAction, Action>,
    environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
  ) -> Reducer<DerivedState.Source, GlobalAction, GlobalEnvironment>
    where DerivedState: DerivedStateType, DerivedState.Destination == State {
    .init { globalState, globalAction, globalEnvironment in
      guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
      var localState = toLocalState.get(globalState)
      let effets = self.run(
        &localState,
        localAction,
        toLocalEnvironment(globalEnvironment)
      )
      .map(toLocalAction.embed)
      toLocalState.set(&globalState, localState)
      return effets
    }
  }

  func forEach<DerivedState, GlobalAction, GlobalEnvironment, ID>(
    state toLocalState: DerivedState,
    action toLocalAction: CasePath<GlobalAction, (ID, Action)>,
    environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
    breakpointOnNil: Bool = true,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Reducer<DerivedState.Source, GlobalAction, GlobalEnvironment> where DerivedState: DerivedStateType, DerivedState.Destination == IdentifiedArray<ID, State> {
    .init { globalState, globalAction, globalEnvironment in
      guard let (id, localAction) = toLocalAction.extract(from: globalAction) else { return .none }
      var identifiedArray = toLocalState.get(globalState)
      if identifiedArray[id: id] == nil {
        if breakpointOnNil {
          breakpoint(
            """
            ---
            Warning: Reducer.forEach@\(file):\(line)

            "\(debugCaseOutput(localAction))" was received by a "forEach" reducer at id \(id) when \
            its state contained no element at this id. This is generally considered an application \
            logic error, and can happen for a few reasons:

            * This "forEach" reducer was combined with or run from another reducer that removed \
            the element at this id when it handled this action. To fix this make sure that this \
            "forEach" reducer is run before any other reducers that can move or remove elements \
            from state. This ensures that "forEach" reducers can handle their actions for the \
            element at the intended id.

            * An in-flight effect emitted this action while state contained no element at this id. \
            It may be perfectly reasonable to ignore this action, but you also may want to cancel \
            the effect it originated from when removing an element from the identified array, \
            especially if it is a long-living effect.

            * This action was sent to the store while its state contained no element at this id. \
            To fix this make sure that actions for this reducer can only be sent to a view store \
            when its state contains an element at this id. In SwiftUI applications, use \
            "ForEachStore".
            ---
            """
          )
        }
        return .none
      }
      
      var localState = identifiedArray[id: id]!

      let effets =
        self
          .run(
            &localState,
            localAction,
            toLocalEnvironment(globalEnvironment)
          )
          .map { toLocalAction.embed((id, $0)) }
      
      identifiedArray[id: id] = localState
      
      toLocalState.set(&globalState, identifiedArray)
      return effets
    }
  }
  
  func forEach<DerivedState, GlobalAction, GlobalEnvironment, Key>(
    state toLocalState: DerivedState,
    action toLocalAction: CasePath<GlobalAction, (Key, Action)>,
    environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
    breakpointOnNil: Bool = true,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> Reducer<DerivedState.Source, GlobalAction, GlobalEnvironment> where DerivedState: DerivedStateType, DerivedState.Destination == [Key: State] {
    .init { globalState, globalAction, globalEnvironment in
      guard let (key, localAction) = toLocalAction.extract(from: globalAction) else { return .none }
      var dictionary = toLocalState.get(globalState)
      if dictionary[key] == nil {
        if breakpointOnNil {
          breakpoint(
            """
            ---
            Warning: Reducer.forEach@\(file):\(line)

            "\(debugCaseOutput(localAction))" was received by a "forEach" reducer at id \(key) when \
            its state contained no element at this id. This is generally considered an application \
            logic error, and can happen for a few reasons:

            * This "forEach" reducer was combined with or run from another reducer that removed \
            the element at this id when it handled this action. To fix this make sure that this \
            "forEach" reducer is run before any other reducers that can move or remove elements \
            from state. This ensures that "forEach" reducers can handle their actions for the \
            element at the intended id.

            * An in-flight effect emitted this action while state contained no element at this id. \
            It may be perfectly reasonable to ignore this action, but you also may want to cancel \
            the effect it originated from when removing an element from the identified array, \
            especially if it is a long-living effect.

            * This action was sent to the store while its state contained no element at this id. \
            To fix this make sure that actions for this reducer can only be sent to a view store \
            when its state contains an element at this id. In SwiftUI applications, use \
            "ForEachStore".
            ---
            """
          )
        }
        return .none
      }
      
      var localState = dictionary[key]!

      let effets =
        self
          .run(
            &localState,
            localAction,
            toLocalEnvironment(globalEnvironment)
          )
          .map { toLocalAction.embed((key, $0)) }
      
      dictionary[key] = localState
      
      toLocalState.set(&globalState, dictionary)
      return effets
    }
  }
}

/// From https://github.com/pointfreeco/swift-composable-architecture
/// Raises a debug breakpoint if a debugger is attached.
@inline(__always) func breakpoint(_ message: @autoclosure () -> String = "") {
  #if DEBUG
    // https://github.com/bitstadium/HockeySDK-iOS/blob/c6e8d1e940299bec0c0585b1f7b86baf3b17fc82/Classes/BITHockeyHelper.m#L346-L370
    var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var info = kinfo_proc()
    var info_size = MemoryLayout<kinfo_proc>.size

    let isDebuggerAttached = name.withUnsafeMutableBytes {
      $0.bindMemory(to: Int32.self).baseAddress
        .map {
          sysctl($0, 4, &info, &info_size, nil, 0) != -1 && info.kp_proc.p_flag & P_TRACED != 0
        }
        ?? false
    }

    if isDebuggerAttached {
      fputs(
        """
        \(message())

        Caught debug breakpoint. Type "continue" ("c") to resume execution.

        """,
        stderr
      )
      raise(SIGTRAP)
    }
  #endif
}

/// From https://github.com/pointfreeco/swift-composable-architecture
func debugCaseOutput(_ value: Any) -> String {
  func debugCaseOutputHelp(_ value: Any) -> String {
    let mirror = Mirror(reflecting: value)
    switch mirror.displayStyle {
    case .enum:
      guard let child = mirror.children.first else {
        let childOutput = "\(value)"
        return childOutput == "\(type(of: value))" ? "" : ".\(childOutput)"
      }
      let childOutput = debugCaseOutputHelp(child.value)
      return ".\(child.label ?? "")\(childOutput.isEmpty ? "" : "(\(childOutput))")"
    case .tuple:
      return mirror.children.map { label, value in
        let childOutput = debugCaseOutputHelp(value)
        return
          "\(label.map { isUnlabeledArgument($0) ? "_:" : "\($0):" } ?? "")\(childOutput.isEmpty ? "" : " \(childOutput)")"
      }
      .joined(separator: ", ")
    default:
      return ""
    }
  }

  return "\(type(of: value))\(debugCaseOutputHelp(value))"
}

/// From https://github.com/pointfreeco/swift-composable-architecture
private func isUnlabeledArgument(_ label: String) -> Bool {
  label.firstIndex(where: { $0 != "." && !$0.isNumber }) == nil
}

