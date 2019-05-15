// !!! THIS CODE IS AUTOMATICALLY GENERATED, DO NOT EDIT BY HAND !!!
//
// Copyright 2018-19 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CTensorFlow

/// **WARNING:** After constructing a `TFE_Op`, any one of its `execute` methods must be called
/// *exactly once*. If not called, then a memory leak is introduced due to the underlying TensorFlow
/// eager op object not being freed. If called more than once, then a SEGFAULT may occur due to
/// trying to execute a TensorFlow eager op that has already been freed.
//@usableFromInline
/*internal*/ public struct TFE_Op {

  // enum AttrType {
  //   case Bool
  //   case Int
  //   case Int32
  //   case Int64
  //   case Float
  //   case Double
  //   case String
  //   case TensorDataType
  //   case TensorShape
  //   case BoolArray  
  //   case IntArray  
  //   case Int32Array  
  //   case Int64Array
  //   case FloatArray
  // }
  
  /// The `TF_Operation *` type.
  @usableFromInline typealias CTFOperation = OpaquePointer
  @usableFromInline /*internal*/ let status: CTFStatus
  @usableFromInline /*internal*/ let op: CTFEOp
  // @usableFromInline /*internal*/ let operands: [(_AnyTensorHandle, CTensorHandle?)]
  @usableFromInline /*internal*/ var operands: [(_AnyTensorHandle, TF_Output, CTensorHandle?)]
  @usableFromInline /*internal*/ var graphOp: CTFOperation?
  @usableFromInline /*internal*/ var outputs: [TF_Output]
  @usableFromInline /*internal*/ var attrs: [String: Any]

  // @usableFromInline /*internal*/ var results: [CTensorHandle?]
  @usableFromInline /*internal*/ static var placeHolderIndex: Int = 0
  @usableFromInline /*internal*/ static var traceGraphFunctionCounter: Int = 0


  public class Results {
    public var computedOutputs: [CTensorHandle]?
  }
  // TODO: When to clear cache?
  @usableFromInline /*internal*/ var results: Results
  @usableFromInline static var lazyCallback: (String) -> () = { (a:String) in return }

  static public func registerLazyCallback(f : @escaping (String) -> ()) {
    TFE_Op.lazyCallback = f
  }
  

  @usableFromInline
  /*internal*/ init(_ name: String) {
    self.status = TF_NewStatus()
    self.op = TFE_NewOp(_ExecutionContext.global.eagerContext, name, status)
    self.graphOp = nil
    self.operands = []
    self.outputs = []
    self.results = Results()
    self.attrs = [:]
  }

  @inlinable @inline(__always)
  func newPlaceholderInput(graph: CTFGraph?, handle: CTensorHandle) -> TF_Output {
    TFE_Op.lazyCallback("placeholder")
    TFE_TensorHandlePrintDebugString(handle)
    debugLog("Adding place holder for \(handle): \(TFE_Op.placeHolderIndex)")
    let desc = TF_NewOperation(graph, "Placeholder", "input_\(TFE_Op.placeHolderIndex)")
    let dtype = TFE_TensorHandleDataType(handle)
    TF_SetAttrType(desc, "dtype", dtype)
    let result = TF_FinishOperation(desc, status)
    checkOk(status)
    TFE_Op.placeHolderIndex += 1
    return TF_Output(oper: result, index: 0)
  }

  @inlinable @inline(__always)
  func newPlaceholderInput(graph: CTFGraph?, op: CTFEOp, handle: CTensorHandle) -> TF_Output {
    let input = newPlaceholderInput(graph: graph, handle: handle)
    let dtype = TFE_TensorHandleDataType(handle)
    TFE_OpAddInput(op, TFE_NewTensorHandleFromTFOutput(input, dtype), status)
    checkOk(status)
    return input
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func addInput(_ inputHandle: _AnyTensorHandle) -> Int {
    // print("Adding input")
    let graph = _ExecutionContext.global.traceContext.graph
    switch (inputHandle.lazyHandle) {
    case LazyTensorHandle.conc(let h): do {
        // print("Adding my placeholder..")
        // TFE_Op.lazyCallback("placeholder")
        // TFE_TensorHandlePrintDebugString(h)
        // debugLog("Adding place holder for \(h): \(TFE_Op.placeHolderIndex)")
        // let desc = TF_NewOperation(graph, "Placeholder", "input_\(TFE_Op.placeHolderIndex)")
        // let dtype = TFE_TensorHandleDataType(h)
        // TF_SetAttrType(desc, "dtype", dtype)
        // let result = TF_FinishOperation(desc, status)
        // checkOk(status)
        // TFE_Op.placeHolderIndex += 1
        // let input = TF_Output(oper: result, index: 0)
        let input = newPlaceholderInput(graph: graph, op: op, handle: h)
        operands.append((inputHandle, input, h))
      }
    case LazyTensorHandle.sym(let argOp, let idx): do {
        if let computedOutputs = argOp.results.computedOutputs {
          // If it is already computed.
          let h = computedOutputs[Int(idx)]
          let input = newPlaceholderInput(graph: graph, op: op, handle: h)
          operands.append((inputHandle, input, h))
        } else {        
          guard let graphOp = argOp.graphOp else { assert(false) }
          let tensorInput = TF_Output(oper: graphOp, index: idx)
          let dtype = TF_OperationOutputType(tensorInput)
          TFE_OpAddInput(op,
            TFE_NewTensorHandleFromTFOutput(tensorInput, dtype), self.status)
          checkOk(self.status)
          operands.append((inputHandle, tensorInput, nil))
        }
      }
    }
    return 1
  }

  // @inlinable @inline(__always)
  // /*internal*/ func addInput(_ inputHandle: ResourceHandle) -> Int {
  //   TFE_OpAddInput(op, inputHandle._cTensorHandle, status)
  //   checkOk(status)
  //   return 1
  // }

  // @inlinable @inline(__always)
  // /*internal*/ func addInput(_ inputHandle: VariantHandle) -> Int {
  //   TFE_OpAddInput(op, inputHandle._cTensorHandle, status)
  //   checkOk(status)
  //   return 1
  // }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyAddInput(_ inputHandle: ResourceHandle) -> Int {
    return addInput(inputHandle)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyAddInput(_ inputHandle: VariantHandle) -> Int {
    return addInput(inputHandle)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyAddInput<Scalar: TensorFlowScalar>(_ input: Tensor<Scalar>) -> Int {
    return addInput(input.handle)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyAddInput(_ input: StringTensor) -> Int {
    return addInput(input.handle)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating  func lazyAddInputList<T: TensorArrayProtocol>(_ input: T) -> Int {
    let count = input._tensorHandleCount
    var expectedCount = 0
    for handle in input._handles {
      expectedCount += addInput(handle)
    }
    assert(count == expectedCount)
    return Int(count)
  }

  @inlinable @inline(__always)
  /*internal*/ func addInput<Scalar: TensorFlowScalar>(_ input: Tensor<Scalar>) -> Int {
    TFE_OpAddInput(op, input.handle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  /*internal*/ func addInput(_ input: StringTensor) -> Int {
    TFE_OpAddInput(op, input.handle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  /*internal*/ func addInputList<T: TensorArrayProtocol>(_ input: T) -> Int {
    let count = input._tensorHandleCount
    var buffer = UnsafeMutableBufferPointer<CTensorHandle>.allocate(capacity: Int(count))
    defer { buffer.deallocate() }
    let pointer = UnsafeMutablePointer<OpaquePointer?>(buffer.baseAddress)
    input._unpackTensorHandles(into: buffer.baseAddress)
    TFE_OpAddInputList(op, pointer, count, status)
    // TODO: checkOk(status)
    return Int(count)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Bool) {
    TFE_OpSetAttrBool(op, name, value ? 1 : 0)
    attrs[name] =  value
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Int) {
    TFE_OpSetAttrInt(op, name, Int64(value))
    attrs[name] = Int64(value)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Int32) {
    TFE_OpSetAttrInt(op, name, Int64(value))
    attrs[name] = Int64(value)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Int64) {
    TFE_OpSetAttrInt(op, name, value)
    attrs[name] = value
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Float) {
    TFE_OpSetAttrFloat(op, name, value)
    attrs[name] = value
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: Double) {
    TFE_OpSetAttrFloat(op, name, Float(value))
    attrs[name] = Float(value)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: String) {
    attrs[name] = value
    value.utf8CString.withUnsafeBufferPointer { buffer in
      // utf8CString is null-terminated; TFE_OpSetAttrString wants
      // non-null-terminated.
      TFE_OpSetAttrString(op, name, buffer.baseAddress, buffer.count - 1)
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: TensorDataType) {
    attrs[name] = value
    TFE_OpSetAttrType(op, name, value._cDataType)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: TensorShape) {
    attrs[name] = value
    let dimensions: [Int64] = value.dimensions.map(Int64.init)
    dimensions.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrShape(op, name, buffer.baseAddress, Int32(buffer.count), status)
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: TensorShape?) {
    guard let shape = value else {
      TFE_OpSetAttrShape(op, name, nil, -1, status)
      return
    }
    attrs[name] = shape
    setAttr(name, shape)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Bool]) {
    attrs[name] = value
    value.map({ $0 ? UInt8(1) : UInt8(0) }).withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrBoolList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Int]) {
    attrs[name] = value
    setAttr(name, value.map(Int64.init))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Int32]) {
    attrs[name] = value
    setAttr(name, value.map(Int64.init))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Int64]) {
    attrs[name] = value
    value.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrIntList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Float]) {
    attrs[name] = value
    value.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrFloatList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [Double]) {
    attrs[name] = value
    setAttr(name, value.map(Float.init))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [String]) {
    // TODO:
    // attrs[name] = value

    // Collect all the strings' utf8 bytes into a single array so that we can
    // address all the strings with a single
    // `flattenedStringBytes.withUnsafeBufferPointer`.
    var flattenedStringBytes: [CChar] = []
    var lengths: [Int] = []
    for string in value {
      // Don't include the null-terminator because TFE_OpSetAttrStringList uses
      // lengths instead of null-terminators.
      let stringBytes = string.utf8CString.dropLast()
      flattenedStringBytes.append(contentsOf: stringBytes)
      lengths.append(stringBytes.count)
    }

    // Calculate the addresses of all the strings within our single buffer, and
    // then call TFE_OpSetAttrStringList.
    flattenedStringBytes.withUnsafeBufferPointer { flattenedStringBytesBuffer in
      var stringAddrs: [UnsafeRawPointer?] = []
      var currentStringAddr =
        flattenedStringBytesBuffer.baseAddress.map(UnsafeRawPointer.init)
      for length in lengths {
        stringAddrs.append(currentStringAddr)
        currentStringAddr = currentStringAddr?.advanced(by: length)
      }

      stringAddrs.withUnsafeBufferPointer { stringAddrsBuffer in
        lengths.withUnsafeBufferPointer { lengthsBuffer in
          TFE_OpSetAttrStringList(op, name, stringAddrsBuffer.baseAddress,
            lengthsBuffer.baseAddress, Int32(value.count))
        }
      }
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [TensorDataType]) {
    value.withUnsafeBufferPointer { buffer in
      buffer.withMemoryRebound(to: TF_DataType.self) { reboundBuffer in
        TFE_OpSetAttrTypeList(op, name, reboundBuffer.baseAddress, Int32(reboundBuffer.count))
      }
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [TensorShape]) {
    // TODO:
    // attrs[name] = value
    let flattenedDims = value.flatMap { $0.dimensions.map(Int64.init) }
    let ranks = value.map { Int32($0.rank) }
    flattenedDims.withUnsafeBufferPointer { flattenedDimsBuffer in
      var dimsPtr: UnsafePointer<Int64>? = flattenedDimsBuffer.baseAddress
      var dims: [UnsafePointer<Int64>?] = []
      for rank in ranks {
        dims.append(dimsPtr)
        if rank >= 0 {
          dimsPtr = dimsPtr.map { $0.advanced(by: Int(rank)) }
        }
      }
      dims.withUnsafeMutableBufferPointer { dimsBuffer in
        ranks.withUnsafeBufferPointer { ranksBuffer in
          TFE_OpSetAttrShapeList(
            op, name, dimsBuffer.baseAddress, ranksBuffer.baseAddress,
            Int32(ranksBuffer.count), status)
        }
      }
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr(_ name: String, _ value: [TensorShape?]) {
    // TODO:
    // attrs[name] = value
    let flattenedDims = value.flatMap { (tensorShapeOpt) -> [Int64] in
      if let tensorShape = tensorShapeOpt {
        return tensorShape.dimensions.map(Int64.init)
      }
      return []
    }
    let ranks = value.map { shape in (shape?.rank).map(Int32.init) ?? -1 }
    flattenedDims.withUnsafeBufferPointer { flattenedDimsBuffer in
      var dimsPtr: UnsafePointer<Int64>? = flattenedDimsBuffer.baseAddress
      var dims: [UnsafePointer<Int64>?] = []
      for rank in ranks {
        dims.append(dimsPtr)
        if rank >= 0 {
          dimsPtr = dimsPtr.map { $0.advanced(by: Int(rank)) }
        }
      }
      dims.withUnsafeMutableBufferPointer { dimsBuffer in
        ranks.withUnsafeBufferPointer { ranksBuffer in
          TFE_OpSetAttrShapeList(
            op, name, dimsBuffer.baseAddress, ranksBuffer.baseAddress,
            Int32(ranksBuffer.count), status)
        }
      }
    }
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func setAttr<In: TensorGroup, Out: TensorGroup>(_ name: String, _ value: (In) -> Out) {
    // TODO:
    // attrs[name] = value
    _tffunc(value).utf8CString.withUnsafeBufferPointer { buffer in
      // utf8CString is null-terminated; TFE_OpSetAttrFunctionName wants
      // non-null-terminated.
      TFE_OpSetAttrFunctionName(op, name, buffer.baseAddress, buffer.count - 1)
    }
  }

  /// **WARNING:** After constructing a `TFE_Op`, any one of its `execute` methods must be called
  /// *exactly once*. If not called, then a memory leak is introduced due to the underlying
  /// TensorFlow eager op object not being freed. If called more than once, then a SEGFAULT may
  /// occur due to trying to execute a TensorFlow eager op that has already been freed.

  // @inlinable @inline(__always)
  // /*internal*/ mutating func lazyExecute<T: Numeric & TensorFlowScalar>(
  //   _ count0: Int
  // ) -> (Tensor<T>) {
  //   // Initialize graphOp field..
  //   updateGraphOp(nOutputs: 1)
  //   return Tensor<T>(handle: TensorHandle<T>(_lazy: self, idx: 0))
  // }


  @inlinable @inline(__always)
  /*internal*/ func lazyExecute() {
    // TODO:
    assert(false)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol>(
    _ count0: Int
  ) -> (T0) {
    updateGraphOp(nOutputs: 1)
    return T0.init(_lazySingle: self, idx: 0)
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int
  ) -> (T0, T1) {
    updateGraphOp(nOutputs: 2)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int
  ) -> (T0, T1, T2) {
    updateGraphOp(nOutputs: 3)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2))
 }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int

  ) -> (T0, T1, T2, T3) {
    updateGraphOp(nOutputs: 4)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int
  ) -> (T0, T1, T2, T3, T4) {
    updateGraphOp(nOutputs: 5)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol, T5 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int
  ) -> (T0, T1, T2, T3, T4, T5) {
    updateGraphOp(nOutputs: 6)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4),
      T5.init(_lazySingle: self, idx: 5))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6) {
    updateGraphOp(nOutputs: 7)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4),
      T5.init(_lazySingle: self, idx: 5),
      T6.init(_lazySingle: self, idx: 6))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
    updateGraphOp(nOutputs: 6)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4),
      T5.init(_lazySingle: self, idx: 5),
      T6.init(_lazySingle: self, idx: 6),
      T7.init(_lazySingle: self, idx: 7))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
    updateGraphOp(nOutputs: 6)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4),
      T5.init(_lazySingle: self, idx: 5),
      T6.init(_lazySingle: self, idx: 6),
      T7.init(_lazySingle: self, idx: 7),
      T8.init(_lazySingle: self, idx: 8))
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func lazyExecute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol,  T2 : TensorArrayProtocol, T3 : TensorArrayProtocol,  T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol, T9 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int,
    _ count9: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    updateGraphOp(nOutputs: 6)
    return (
      T0.init(_lazySingle: self, idx: 0),
      T1.init(_lazySingle: self, idx: 1),
      T2.init(_lazySingle: self, idx: 2),
      T3.init(_lazySingle: self, idx: 3),
      T4.init(_lazySingle: self, idx: 4),
      T5.init(_lazySingle: self, idx: 5),
      T6.init(_lazySingle: self, idx: 6),
      T7.init(_lazySingle: self, idx: 7),
      T8.init(_lazySingle: self, idx: 8),
      T9.init(_lazySingle: self, idx: 9))
  }

  @inlinable @inline(__always)
  /*internal*/ func execute() {
    var count: Int32 = 0
    var unused: CTensorHandle?
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, &unused, &count, status)
    checkOk(status)
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol>(
    _ count0: Int
  ) -> (T0) {
    var count = Int32(count0)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int
  ) -> (T0, T1) {
    var count = Int32(count0) + Int32(count1)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int
  ) -> (T0, T1, T2) {
    var count = Int32(count0) + Int32(count1) + Int32(count2)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int
  ) -> (T0, T1, T2, T3) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int
  ) -> (T0, T1, T2, T3, T4) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int
  ) -> (T0, T1, T2, T3, T4, T5) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7) + Int32(count8)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let offset8 = offset7 + Int32(count7)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7),
      T8.init(_owning: buffer.advanced(by: Int(offset8)), count: count8))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  /*internal*/ func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol, T9 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int,
    _ count9: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7) + Int32(count8) + Int32(count9)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let offset8 = offset7 + Int32(count7)
    let offset9 = offset8 + Int32(count8)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7),
      T8.init(_owning: buffer.advanced(by: Int(offset8)), count: count8),
      T9.init(_owning: buffer.advanced(by: Int(offset9)), count: count9))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  func convertEagerToGraphOp(eagerOp: CTFEOp, nOutputs: Int32) -> CTFOperation {
    let cTraceContext = _ExecutionContext.global.traceContext.cTraceContext
    // Device?
    var count = Int32(nOutputs)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    let tfOp = TFE_AddEagerOpToGraph(eagerOp, cTraceContext,
      UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)

    // // TODO: Make sure this is correct way to delete all the handles.
    // for i in 0..<count {
    //   let output: CTensorHandle = buffer.advanced(by: Int(count))
    //   TFE_DeleteTensorHandle(output)
    // }
    buffer.deallocate()
    return tfOp!
  }

  @inlinable @inline(__always)
  /*internal*/ mutating func updateGraphOp(nOutputs: Int32)  {
    graphOp = convertEagerToGraphOp(eagerOp: op, nOutputs: nOutputs)
    for i in 0..<nOutputs {
      outputs.append(TF_Output(oper: graphOp, index: i))
    }
  }
  
  struct GraphDesc {
    // var opers: Set</*CTFOperation*/OpaquePointer?>
    var opers: [CTFEOp: /*CTFOperation*/OpaquePointer?]
    var processed: Set<CTFEOp>
    var inputs: [TF_Output]
    var values: [CTensorHandle]
    var outputs: [TF_Output]
  }

  func collectOperations(_ res: inout GraphDesc) -> (CTFOperation, Bool) {
    if let collectedOp = res.opers[self.op] {
      let wasRebuilt: Bool = (collectedOp != graphOp!)
      return (collectedOp!, wasRebuilt)
    }
    // let (inserted, _) = res.processed.insert(self.op)
    // // let (inserted, _) =  res.opers.insert(graphOp!)
    // if !inserted { return }
    let graph = _ExecutionContext.global.traceContext.graph
    var rebuildGraphOp: Bool = false
    var rebuildOperands: [TF_Output] = []
    for (anyHandle, inputOp, tensorHandle) in operands {
      switch (anyHandle.lazyHandle) {
      case LazyTensorHandle.conc(/*TODO: Is this right?*/_): do {
          rebuildOperands.append(inputOp)
          res.inputs.append(inputOp)
          res.values.append(tensorHandle!)
        }
        case LazyTensorHandle.sym(let argOp, let idx): do {
          if tensorHandle != nil  {
            rebuildOperands.append(inputOp)
            res.inputs.append(inputOp)
            res.values.append(tensorHandle!)
          } else {
            if let computedOutputs = argOp.results.computedOutputs {
              // Reuse results if they were already computed.
              // This forces us to create new graph op.
              rebuildGraphOp = true
              let handle  = computedOutputs[Int(idx)]
              let newOp = newPlaceholderInput(graph: graph, handle: handle)
              // Make this an input
              res.inputs.append(newOp)
              res.values.append(handle)
              rebuildOperands.append(newOp)
            } else {
              let (newOp, wasRebuilt) = argOp.collectOperations(&res)
              if wasRebuilt {
                rebuildGraphOp = true
              }
              rebuildOperands.append(TF_Output(oper: newOp, index: idx))
            }
          }
        }
      }
    }
    if !rebuildGraphOp {
      res.opers[self.op] = graphOp!
      return (graphOp!, false)
    } 
    // Rebuild the graph op now!
    // We are still building the eager op and adding to graph
    // We can create a graph node directly.
    let opName = TF_OperationOpType(graphOp!)
    let eagerContext = _TFCGetGlobalEagerContext()
    let newOpOptional = TFE_NewOp(eagerContext, opName, status)
    checkOk(status)
    let newOp = newOpOptional!
    defer { TFE_DeleteOp(newOp) }
    // Add inputs.
    for input in rebuildOperands {
      let dtype = TF_OperationOutputType(input)
      TFE_OpAddInput(newOp,
        TFE_NewTensorHandleFromTFOutput(input, dtype), status)
      checkOk(status)
    }
    // Set attributes
    for (name, attr) in attrs {
      switch attr {
        case let value as TensorDataType: do {
          TFE_OpSetAttrType(newOp, name, value._cDataType)
        }
        case let value as Bool: do {
          TFE_OpSetAttrBool(newOp, name, value ? 1 : 0)
        }
        case let value as Int64: do {
          TFE_OpSetAttrInt(newOp, name, value)
        }
        case let value as Float: do {
          TFE_OpSetAttrFloat(newOp, name, value)
        }
        case let value as String: do {
          value.utf8CString.withUnsafeBufferPointer { buffer in
            // utf8CString is null-terminated; TFE_OpSetAttrString wants
            // non-null-terminated.
            TFE_OpSetAttrString(newOp, name, buffer.baseAddress, buffer.count - 1)
          }
        }
        case let value as [Int32]: do {
          let values64 = value.map(Int64.init)
          values64.withUnsafeBufferPointer { buffer in
            TFE_OpSetAttrIntList(newOp, name, buffer.baseAddress, Int32(buffer.count))
          }
        }
        case let value as [Int64]: do {
          value.withUnsafeBufferPointer { buffer in
            TFE_OpSetAttrIntList(newOp, name, buffer.baseAddress, Int32(buffer.count))
          }
        }
        case let value as [Int]: do {
          let values64 = value.map(Int64.init)
          values64.withUnsafeBufferPointer { buffer in
            TFE_OpSetAttrIntList(newOp, name, buffer.baseAddress, Int32(buffer.count))
          }
        }
        default: do {
          // TODO
          print("Offending attribute of \(opName) is \(name):\(attr)")
          assert(false)
        }
      }
    }
    let newGraphOp = convertEagerToGraphOp(eagerOp: newOp, nOutputs: Int32(outputs.count))
    res.opers[self.op] = newGraphOp
    return (newGraphOp, true)
  }

  //@inlinable @inline(__always)
  func evaluate(idx : Int32) -> (CTensorHandle) {
    TFE_Op.lazyCallback("Evaluate")
    if let computedOutputs = results.computedOutputs {
      return computedOutputs[Int(idx)]
    }

    var desc = GraphDesc(opers: [:], processed: [], inputs: [], values: [], outputs: [])
    let (collectedOp, wasRebuilt) = collectOperations(&desc)
    if wasRebuilt {
      for i in 0..<outputs.count {
        desc.outputs.append(TF_Output(oper: collectedOp, index: Int32(i)))
      }
    } else {
      desc.outputs = outputs
    }
    let tracedFunctionName =
      "lazyTrace_\(TFE_Op.traceGraphFunctionCounter)"
    TFE_Op.traceGraphFunctionCounter += 1
    // print ("Inputs: \(desc.inputs.count)")
    // print ("opers: \(desc.opers.count)")

    let eagerContext = _TFCGetGlobalEagerContext()
    Array(desc.opers.values).withUnsafeBufferPointer {opers in
      let graph = _ExecutionContext.global.traceContext.graph
      let base = opers.baseAddress
      let tracedGraphFn =
      TF_GraphToFunction(graph, tracedFunctionName,
        /*append_hash_to_fn_name*/ 0,
        /*num_opers*/ Int32(desc.opers.count),
        /*opers*/ base,
        /*numinputs*/ Int32(desc.inputs.count),
        /*inputs*/ desc.inputs,
        /*noutputs*/ Int32(desc.outputs.count),
        /*outputs*/ desc.outputs,
        /*outputnames*/ nil,
        /*functionoptions*/ nil, "", status)
      checkOk(status)
      TFE_ContextAddFunction(eagerContext, tracedGraphFn, status)

      var len: Int = 0
      let funcDebugStr = TF_FunctionDebugString(tracedGraphFn, &len)!
      debugLog("The traced function is:\n\(String(cString: funcDebugStr))")
      free(funcDebugStr)
    }

    let eagerOp: CTFEOp! = TFE_NewOp(eagerContext, tracedFunctionName, status)
    defer { TFE_DeleteOp(eagerOp) }
    checkOk(status)

    let deviceName = _ExecutionContext.global.currentDeviceName
    if let deviceName = deviceName {
      debugLog("Placing the trace func on device \(deviceName).")
      TFE_OpSetDevice(eagerOp, deviceName, status)
      checkOk(status)
    }

    for input in desc.values {
      TFE_OpAddInput(eagerOp, input, status)
      checkOk(status)
    }

    // TODO: more than one return value.
    var returnValues = [CTensorHandle?](repeating: nil,
      count: outputs.count)
    var outputReturnValueCount = Int32(outputs.count)
    TFE_Execute(eagerOp, &returnValues, &outputReturnValueCount, status)
    // TODO: preallocate array.
    var computedOutputs: [CTensorHandle]  = []
    for value in returnValues {
      computedOutputs.append(value!) 
    }
    results.computedOutputs = computedOutputs
    return computedOutputs[Int(idx)]
    // TODO: Clean up, cache, etc...
  }
}
