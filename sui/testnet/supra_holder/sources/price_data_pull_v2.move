module SupraOracle::price_data_pull_v2 {

    use sui::clock::Clock;
    use sui::tx_context::TxContext;
    use SupraOracle::SupraSValueFeed::OracleHolder;
    use supra_validator::validator_v2::DkgState;

    /// Represents price data with information about the pair, price, decimal, timestamp, and stale value status
    struct PriceData has copy, drop { }

    struct MerkleRootHash has key, store { }

    /// Extracts relevant information from a PriceData struct
    native public fun price_data_split(price_data: &PriceData): (u32, u128, u64, u16, u64);

    /// Verifies the oracle proof and retrieves price data
    native public fun verify_oracle_proof(
        dkg_state: &DkgState,
        oracle_holder_addr: &mut OracleHolder,
        merkle_root_hash: &mut MerkleRootHash,
        clock: &Clock,
        bytes: vector<u8>,
        _ctx: &mut TxContext,
    ): vector<PriceData>;
}
