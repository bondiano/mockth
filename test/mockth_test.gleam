import gleeunit
import gleeunit/should
import gleam/function
import mockth

pub fn main() {
  gleeunit.main()
}

pub fn expect_test() {
  let assert Ok(_) =
    mockth.expect("gleam/function", "identity", fn(_) { "hello" })

  mockth.validate("gleam/function")
  |> should.equal(True)

  mockth.mocked()
  |> should.equal(["gleam/function"])

  function.identity("world")
  |> should.equal("hello")

  mockth.unload_all()
}
