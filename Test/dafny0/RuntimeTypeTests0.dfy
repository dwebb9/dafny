// RUN: %dafny /compile:0 "%s" > "%t"
// RUN: %dafny /noVerify /compile:4 /compileTarget:cs "%s" >> "%t"
// RUN: %dafny /noVerify /compile:4 /compileTarget:java "%s" >> "%t"
// RUN: %dafny /noVerify /compile:4 /compileTarget:js "%s" >> "%t"
// RUN: %dafny /noVerify /compile:4 /compileTarget:go "%s" >> "%t"
// RUN: %diff "%s.expect" "%t"

// The code in this file demonstrates complications in sorting out covariance in some
// compilation target languages. Compilation support is currently spotty, where C# and
// Java only supports sets, multisets, and sequences (not maps or datatypes), and
// only in the "upcast" direction.
//
// The solution in C# is to ensure the Dafny type is mapped to a C# interface with the "out"
// type parameter modifier, which allows covariance under the condition that the type parameter
// is only used in return types in the interface methods and not as parameter types.
// This has only been implemented for sets, multisets, and sequences so far, but will apply to
// the other cases in this test case as well.
//
// The solution in Java is to use Java's wildcard types: a "Dafny.Sequence<T>"" is assignable to
// a "Dafny.Sequence<? extends T>".
//
// Covariance is not a problem in JavaScript, since JavaScript has no static types. It's also
// not a problem in Go, because Go has no type parameters and Dafny therefore encodes all
// type parameters as interface{}.

method G()
{
  var s: set<int>;
  var t: set<nat>;
  // the following assignments are fine, because "s" and "t" are represented
  // the same way in the target language
  s := {5, 7};
  t := s;
  s := t;
  print s, " and ", t, "\n";
}

trait Tr { var u: char }

class Class0 extends Tr { var x: int }

class Class1 extends Tr { var y: real }

datatype Dt<+A> = Atom(get: A)

method H() {
  var c := new Class0;
  var a: Dt<Class0> := Atom(c);
  var b: Dt<object>; // compilation error: compilation does not support trait types as a type parameter; consider introducing a ghost
  b := a;
  print a, " and ", b, "\n";
}

method I()
{
  var c := new Class0;
  var a: Dt<Class0> := Atom(c);
  var b: Dt<object>; // compilation error: compilation does not support trait types as a type parameter; consider introducing a ghost
  b := a;
  print a, " and ", b, "\n";
}

method J()
{
  var c0 := new Class0;
  var c1 := new Class1;
  var s: set<Tr> := {c0, c1}; // fine, this is supported
  var t: set<Class0> := {c0};
  s := t;
  print s, " and ", t, "\n";
}

method K()
{
  var c0 := new Class0;
  var c1 := new Class1;
  var s: seq<Tr> := [c0, c1]; // fine, this is supported
  var t: seq<Class0> := [c0];
  s := t;
  print s, " and ", t, "\n";
}

method L()
{
  var c0 := new Class0;
  var c1 := new Class1;
  var s: multiset<Tr> := multiset{c0, c1}; // fine, this is supported
  var t: multiset<Class0> := multiset{c0};
  s := t;
  print s, " and ", t, "\n";
}

method M()
{
  var c0 := new Class0;
  var c1 := new Class1;
  var s: map<int, Tr> := map[8 := c0, 9 := c1]; // compilation error: not yet supported
  var t: map<int, Class0> := map[7 := c0];
  s := t;
  print s, " and ", t, "\n";
}

method Downcast()
{
  var c0 := new Class0;
  var s: seq<Class0> := [c0, c0];
  var t: seq<Tr> := s;
  t := s;  // TODO
  print s, " and ", t, "\n";
}

method Main()
{
  G();
  H();
  I();
  J();
  K();
  L();
  M();
  Downcast();
}
