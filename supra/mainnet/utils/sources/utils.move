module supra_utils::utils {
    /// unstable append of second vector into first vector
    native public fun destructive_reverse_append<Element: drop>(first: &mut vector<Element>, second: vector<Element>);

    /// Flatten and concatenate the vectors
    native public fun vector_flatten_concat<Element: copy + drop>(
        lhs: &mut vector<Element>,
        other: vector<vector<Element>>
    );

    /// function that calls bls12381 to verify the signature
    native public fun verify_signature(public_key: vector<u8>, msg: vector<u8>, signature: vector<u8>): bool;

    /// Calculates the power of a base raised to an exponent. The result of `base` raised to the power of `exponent`
    native public fun calculate_power(base: u128, exponent: u16): u256;

    /// Ensures that the specified index belongs to the given owner. It will Panics if the index object does not belong to the caller.
    native public fun ensure_object_owner<T: key>(object: supra_framework::object::Object<T>, caller: &signer);

    /// Returns the number of bits required to represent the given u256 number.
    native public fun num_bits(num: u256): u16;

    /// Returns the maximum value that can be represented with `x` bits as a u256.
    native public fun max_x_bits(x: u16): u256;

    /// Returns the absolute difference between two u256 numbers.
    native public fun abs_difference(a: u256, b: u256): u256;
}
