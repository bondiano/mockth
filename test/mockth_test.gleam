import gleeunit
import gleeunit/should
import gleam/function
import mockth

pub fn main() {
  gleeunit.main()
}

pub fn expect1_test() {
  let assert Ok(_) =
    mockth.expect1("gleam/function", "identity", fn(_) { "hello" })

  mockth.validate("gleam/function")
  |> should.equal(True)

  mockth.mocked()
  |> should.equal(["gleam/function"])

  function.identity("world")
  |> should.equal("hello")

  mockth.unload_all()
}

pub fn stub0() {
  "hello"
}

pub fn expect0_test() {
  let assert Ok(_) = mockth.expect0("mockth_test", "stub0", fn() { "hello" })

  stub0()
  |> should.equal("hello")

  mockth.unload_all()
}

pub fn stub2(_a, _b) {
  "hello"
}

pub fn expect2_test() {
  let assert Ok(_) =
    mockth.expect2("mockth_test", "stub2", fn(_, _) { "hello" })

  stub2(1, 2)
  |> should.equal("hello")

  mockth.unload_all()
}

pub fn stub3(_a, _b, _c) {
  "hello"
}

pub fn expect3_test() {
  let assert Ok(_) =
    mockth.expect3("mockth_test", "stub3", fn(_, _, _) { "hello" })

  stub3(1, 2, 3)
  |> should.equal("hello")

  mockth.unload_all()
}

pub fn stub4(_a, _b, _c, _d) {
  "hello"
}

pub fn expect4_test() {
  let assert Ok(_) =
    mockth.expect4("mockth_test", "stub4", fn(_, _, _, _) { "hello" })

  stub4(1, 2, 3, 4)
  |> should.equal("hello")

  mockth.unload_all()
}

pub fn stub5(_a, _b, _c, _d, _e) {
  "hello"
}

pub fn expect5_test() {
  let assert Ok(_) =
    mockth.expect5("mockth_test", "stub5", fn(_, _, _, _, _) { "hello" })

  stub5(1, 2, 3, 4, 5)
  |> should.equal("hello")

  mockth.unload_all()
}
