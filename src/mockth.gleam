//// A module for mocking functions in Erlang modules - wrapper around [meck](https://github.com/eproxus/meck).

import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/erlang/process.{type Pid}
import gleam/list
import gleam/result
import gleeunit/should

pub type History {
  /// Module, function and arguments that the mock module got called with.
  History(pid: Pid, module: String, function: String, arguments: List(Dynamic))
}

pub type MockError {
  NoFunctionError(function: String)
  NoModuleError(module: String)
  NoExpectError
}

@external(erlang, "meck", "expect")
fn do_expect(module: Atom, function: Atom, fun: fun) -> Atom

/// Mock a function.
/// The function `fun` should return the value that the function will return when called.
/// ```gleam
/// pub fn expect1_test() {
///  let assert Ok(_) =
///    mockth.expect("gleam@function", "identity", fn(_) { "hello" })
///
///  mockth.validate("gleam@function")
///  |> should.equal(True)
///
///  mockth.mocked()
///  |> should.equal(["gleam@function"])
///
///  function.identity("world")
///  |> should.equal("hello")
/// }
pub fn expect(
  module module: String,
  function function: String,
  with fun: fun,
) -> Result(Bool, MockError) {
  use #(module, function) <- result.then(load_expect_atoms(module, function))

  do_expect(module, function, fun)
  |> is_ok_atom()
}

@external(erlang, "meck", "validate")
fn do_validate(module: Atom) -> Bool

// The function returns true if the mocked module(s) has been used according to its expectations. It returns false if a call has failed in some way. Reasons for failure are wrong number of arguments or non-existing function (undef), wrong arguments (function clause) or unexpected exceptions.
/// Validate the state of the mock module(s).
/// Validation can detect:
/// - When a function was called with the wrong argument types (function_clause)
/// - When an exception was thrown
/// - When an exception was thrown and expected (via meck:exception/2), which still results in true being returned
///
/// Validation cannot detect:
/// - When you didn't call a function
/// - When you called a function with the wrong number of arguments (undef)
/// - When you called an undefined function (undef)
pub fn validate(module module: String) -> Bool {
  case to_module_atom(module) {
    Ok(module) -> do_validate(module)
    Error(_) -> False
  }
}

@external(erlang, "meck", "unload")
fn do_unload_all() -> List(Atom)

/// The function returns the list of mocked modules that were unloaded in the process.
/// Unloads all mocked modules from memory.
pub fn unload_all() -> List(String) {
  do_unload_all()
  |> module_atoms_to_strings()
}

@external(erlang, "meck", "unload")
fn do_unload(module: Atom) -> Atom

/// Unload a mocked module or a list of mocked modules.
/// This will purge and delete the module(s) from the Erlang virtual machine. If the mocked module(s) replaced an existing module, this module will still be in the Erlang load path and can be loaded manually or when called.
pub fn unload(module: String) -> Result(Bool, MockError) {
  module
  |> to_module_atom
  |> result.then(fn(module) {
    do_unload(module)
    |> is_ok_atom()
  })
}

@external(erlang, "meck", "mocked")
fn do_mocked() -> List(Atom)

/// Returns the currently mocked modules.
pub fn mocked() -> List(String) {
  do_mocked()
  |> module_atoms_to_strings()
}

type Mfa =
  #(Atom, Atom, List(Dynamic))

@external(erlang, "meck", "history")
fn do_history(module: Atom) -> List(#(Pid, Mfa, result))

/// Returns the history of calls to the mocked module.
/// Don't support exception handling.
pub fn history(module: String) -> Result(List(History), MockError) {
  module
  |> to_module_atom
  |> result.map(fn(module) { do_history(module) })
  |> result.then(fn(histories) {
    histories
    |> list.map(fn(histoy) {
      let #(pid, mfa, _result) = histoy
      let #(module, function, arguments) = mfa

      let module = atom.to_string(module)
      let function = atom.to_string(function)

      History(
        pid: pid,
        module: module,
        function: function,
        arguments: arguments,
      )
    })
    |> Ok
  })
}

/// Utility function to set up mocks with the `use` sugar.
/// ```gleam
///  pub fn with_mock_test() {
///   use mock <- mockth.with_mock(
///     module: "gleam@function",
///     function: "identity",
///     replacement: fn(_) { "hello" },
///   )
///
///   function.identity("world")
///   |> should.equal("hello")
///
///   // the mocked module is available here as `mocks`
///   // for example to be able to call `mockth.history` with it.
/// }
/// ```
pub fn with_mock(
  module module: String,
  function function: String,
  replacement fun: a,
  testcase f: fn(String) -> b,
) {
  let assert Ok(_) = expect(module, function, fun)

  validate(module)
  |> should.be_true()

  mocked()
  |> list.contains(module)
  |> should.be_true()

  f(module)

  unload_all()
}

fn module_atoms_to_strings(module_atoms: List(Atom)) -> List(String) {
  module_atoms
  |> list.map(atom.to_string)
}

fn is_ok_atom(a: Atom) -> Result(Bool, MockError) {
  let ok = atom.from_string("ok")
  case ok {
    Ok(ok) ->
      case ok == a {
        True -> Ok(True)
        False -> Error(NoExpectError)
      }
    Error(_) -> Error(NoExpectError)
  }
}

fn load_expect_atoms(
  module: String,
  function: String,
) -> Result(#(Atom, Atom), MockError) {
  use module <- result.then(to_module_atom(module))
  use function <- result.map(to_function_atom(function))

  #(module, function)
}

fn to_function_atom(function: String) -> Result(Atom, MockError) {
  atom.from_string(function)
  |> result.map_error(fn(_) { NoFunctionError(function) })
}

fn to_module_atom(module: String) -> Result(Atom, MockError) {
  atom.from_string(module)
  |> result.map_error(fn(_) { NoModuleError(module) })
}
