module supra_holder::price_data_pull_v2 {

    struct PriceData has copy, drop { }

    native public fun verify_oracle_proof(
        _account: &signer,
        oracle_holder_addr: address,
        bytes: vector<u8>,
    ): vector<PriceData>;

    /// Extract price data in tuple
    native public fun price_data_split(price_data: &PriceData) : (u32, u128, u16, u64);
}
