# mockth

[![Package Version](https://img.shields.io/hexpm/v/mockth)](https://hex.pm/packages/mockth)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/mockth/)

Gleam modules mocking library. This is a simple wrapper around Erlang [Meck](https://github.com/eproxus/meck) library.

```sh
gleam add mockth
```

## Usage

It provides a simple API to mock Gleam modules and functions. All you need to use `mockth.expect` function to mock any external function with your own implementation.

```gleam
import gleeunit
import gleeunit/should
import gleam/function
import mockth

pub fn main() {
  gleeunit.main()
}

pub fn expect_test() {
  let assert Ok(_) =
    mockth.expect("gleam@function", "identity", fn(_) { "hello" })

  mockth.validate("gleam@function")
  |> should.equal(True)

  mockth.mocked()
  |> should.equal(["gleam@function"])

  function.identity("world")
  |> should.equal("hello")

  mockth.unload_all()
}
```

Don't forget to unload all mocks after each test case.

Further documentation can be found at <https://hexdocs.pm/mockth>.

### With `use` sugar
The `with_mock` function is available to use mockth in your tests with the `use` sugar. It performs all steps from the example above (mock, validate, assert module is mocked), and even unloads all mocks after the test function finishes.

```gleam
 pub fn with_mock_test() {
  use mock <- mockth.with_mock(
    module: "gleam@function",
    function: "identity",
    replacement: fn(_) { "hello" },
  )

  function.identity("world")
  |> should.equal("hello")

  // the mocked module is available here as `mocks`
  // for example to be able to call `mockth.history` with it.
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
