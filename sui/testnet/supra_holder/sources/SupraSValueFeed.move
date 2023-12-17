module SupraOracle::SupraSValueFeed {

    use sui::object::UID;

    struct OracleHolder has key, store { id: UID }

    struct Price has drop {
        pair: u32,
        value: u128,
        decimal: u16,
        timestamp: u128,
        round: u64
    }

    /// It will return the priceFeedData value for that particular tradingPair
    native public fun get_price(oracle_holder: &OracleHolder, pair: u32): (u128, u16, u128, u64);

    /// It will return the priceFeedData value for that multiple tradingPair
    native public fun get_prices(oracle_holder: &OracleHolder, pairs: vector<u32>): vector<Price>;

    /// It will return the extracted price value for the Price struct
    native public fun extract_price(price: &Price): (u32, u128, u16, u128, u64);

    /// Derived pairs are the one whose price info is calculated using two compatible pairs using either multiplication or division.
    /// Return values in tuple
    ///     1. derived_price : u128
    ///     2. decimal : u16
    ///     3. round-difference : u64
    ///     4. `"base" as compared to "quote"` : u8 (Where 0=>LESS, 1=>GREATER, 2=>EQUAL)
    native public fun get_derived_price(oracle_holder: &OracleHolder, pair_id1: u32, pair_id2: u32, operation: u8): (u128, u16, u64, u8);
}
