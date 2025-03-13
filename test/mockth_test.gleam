import gleam/function
import gleeunit
import gleeunit/should
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

pub fn with_mock_test() {
  use _mock <- mockth.with_mock(
    module: "gleam@function",
    function: "identity",
    replacement: fn(_) { "hello" },
  )

  function.identity("world")
  |> should.equal("hello")
}

pub fn with_mock_assert_unload_test() {
  mockth.with_mock("gleam@function", "identity", fn(_) { "hello" }, fn(_) {
    Nil
  })

  mockth.mocked()
  |> should.equal([])
}
