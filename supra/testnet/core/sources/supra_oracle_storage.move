module supra_oracle::supra_oracle_storage {

    /// Structure to define the Price Feed Data
    struct Price has store, drop {
        pair: u32,
        value: u128,
        decimal: u16,
        timestamp: u64,
        round: u64
    }

    #[view]
    /// Function which checks that is pair index is exist in OracleHolder
    native public fun does_pair_exist(pair_index: u32): bool;

    #[view]
    /// External view function
    /// It will return OracleHolder resource address
    native public fun get_oracle_holder_address(): address;

    #[view]
    /// External view function
    /// It will return the priceFeedData value for that particular tradingPair
    native public fun get_price(pair: u32): (u128, u16, u64, u64);

    #[view]
    /// External view function
    /// It will return the priceFeedData value for that multiple tradingPair
    /// If any of the pairs do not exist in the OracleHolder, an empty vector will be returned for that pair.
    /// If a client requests 10 pairs but only 8 pairs exist, only the available 8 pairs' price data will be returned.
    native public fun get_prices(pairs: vector<u32>): vector<Price>;


    /// External public function
    /// It will return the extracted price value for the Price struct
    native public fun extract_price(price: &Price): (u32, u128, u16, u64, u64);

    #[view]
    /// External public function.
    /// This function will help to find the prices of the derived pairs
    /// Derived pairs are the one whose price info is calculated using two compatible pairs using either multiplication or division.
    /// Return values in tuple
    ///     1. derived_price : u32
    ///     2. decimal : u16
    ///     3. round-difference : u64
    ///     4. `"pair_id1" as compared to "pair_id2"` : u8 (Where 0=>EQUAL, 1=>LESS, 2=>GREATER)
    native public fun get_derived_price(pair_id1: u32,pair_id2: u32,operation: u8): (u128, u16, u64, u8);

}
