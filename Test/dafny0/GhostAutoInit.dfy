// RUN: %dafny /compile:0 "%s" > "%t"
// RUN: %diff "%s.expect" "%t"

module DeclaredTypes {
  // type KnownToBeEmpty = x: int | false  // TODO
  trait MaybeEmpty { }
  type GhostAutoInit = x: MaybeEmpty? | true ghost witness null
  type CompileAutoInit = MaybeEmpty?

  method NotUsed() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
  }

  method Used() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      var x := a;  // error: a has not been initialized
    case true =>
      var x := b;  // error: b has not been initialized
    case true =>
      var x := c;
  }

  method GhostUsed() {
    ghost var a: MaybeEmpty;
    ghost var b: GhostAutoInit;
    ghost var c: CompileAutoInit;
    if
    case true =>
      ghost var x := a;  // error: a has not been initialized
    case true =>
      ghost var x := b;
    case true =>
      ghost var x := c;
  }

  method UsedByGhost() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      ghost var x := a;  // error: a has not been initialized
    case true =>
      ghost var x := b;  // error: b has not been initialized
    case true =>
      ghost var x := c;
  }

  method PassToCompiled() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      TakeParameter(a);  // error: a has not been initialized
    case true =>
      TakeParameter(b);  // error: b has not been initialized
    case true =>
      TakeParameter(c);
  }
  method TakeParameter<G>(g: G) {
  }

  method PassToGhost() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      TakeGhostParameter(a);  // error: a has not been initialized
    case true =>
      TakeGhostParameter(b);  // error: a has not been initialized
    case true =>
      TakeGhostParameter(c);
  }
  method TakeGhostParameter<G>(ghost g: G) {
  }

  method GhostPassToGhost() {
    ghost var a: MaybeEmpty;
    ghost var b: GhostAutoInit;
    ghost var c: CompileAutoInit;
    if
    case true =>
      TakeGhostParameter(a);  // error: a has not been initialized
    case true =>
      TakeGhostParameter(b);
    case true =>
      TakeGhostParameter(c);
  }
}

module TypeParameters {
  method NotUsed<MaybeEmpty, GhostAutoInit(0)/*TODO*/, CompileAutoInit(0)>() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
  }

  method Used<MaybeEmpty, GhostAutoInit(0)/*TODO*/, CompileAutoInit(0)> () {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      var x := a;  // error: a has not been initialized
    case true =>
      // TODO: var x := b;
    case true =>
      var x := c;
  }

  method GhostUsed<MaybeEmpty, GhostAutoInit(0)/*TODO*/, CompileAutoInit(0)>() {
    var a: MaybeEmpty;
    var b: GhostAutoInit;
    var c: CompileAutoInit;
    if
    case true =>
      ghost var x := a;  // error: a has not been initialized
    case true =>
      // TODO: ghost var x := b;
    case true =>
      ghost var x := c;
  }
}