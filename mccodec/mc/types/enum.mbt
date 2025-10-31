///|
pub fn[T] enum_to_int(value : T) -> Int = "%identity"

///|
pub fn[T] int_to_enum(value : Int) -> T = "%identity"

///|
pub fn[T] enum_to_byte(value : T) -> Byte = "%identity"

///|
pub fn[T] byte_to_enum(value : Byte) -> T = "%identity"

///|
priv enum TestEnum {
  A
  B
  C
  D = 254
} derive(Eq, Show)

///|
test {
  // Integer conversions
  assert_eq(enum_to_int(TestEnum::A), 0)
  assert_eq(enum_to_int(TestEnum::B), 1)
  assert_eq(enum_to_int(TestEnum::C), 2)
  assert_eq(enum_to_int(TestEnum::D), 254)
  assert_eq(int_to_enum(0), TestEnum::A)
  assert_eq(int_to_enum(1), TestEnum::B)
  assert_eq(int_to_enum(2), TestEnum::C)
  assert_eq(int_to_enum(254), TestEnum::D)


  // Byte conversions
  assert_eq(enum_to_byte(TestEnum::A), 0)
  assert_eq(enum_to_byte(TestEnum::B), 1)
  assert_eq(enum_to_byte(TestEnum::C), 2)
  assert_eq(enum_to_byte(TestEnum::D), 254)
  assert_eq(byte_to_enum(0), TestEnum::A)
  assert_eq(byte_to_enum(1), TestEnum::B)
  assert_eq(byte_to_enum(2), TestEnum::C)
  assert_eq(byte_to_enum(254), TestEnum::D)
}
