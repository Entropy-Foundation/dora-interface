module supra_oracle::supra_oracle_pull {

    /// Represents price data with information about the pair, price, decimal, timestamp
    struct PriceData has copy, drop {
        pair_index: u32,
        value: u128,
        timestamp: u64,
        decimal: u16,
        round: u64
    }

    /// Extracts relevant information from a PriceData struct
    native public fun price_data_split(price_data: &PriceData): (u32, u128, u64, u16, u64);

    /// Verifies the oracle proof and retrieves price data
    native public fun verify_oracle_proof(
        _account: &signer,
        oracle_proof_bytes: vector<u8>
    ): vector<PriceData> ;

    #[view]
    /// Length of the MerkleRootHashes
    native public fun merkle_root_hashes_length(): u64 ;

    #[view]
    /// to get object address of MerkleRootHash and MerkleRootObjectController easily
    native  public fun get_merkle_root_addr(): address;
    
}
