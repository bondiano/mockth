import gleeunit
import gleeunit/should
import gleam/function
import mockth

pub fn main() {
  gleeunit.main()
}

pub fn expect1_test() {
  let assert Ok(_) =
    mockth.expect1("gleam/function", "identity", fn(_args) { "hello" })

  mockth.validate("gleam/function")
  |> should.equal(True)

  mockth.mocked()
  |> should.equal(["gleam/function"])

  function.identity("world")
  |> should.equal("hello")

  mockth.unload_all()
}
