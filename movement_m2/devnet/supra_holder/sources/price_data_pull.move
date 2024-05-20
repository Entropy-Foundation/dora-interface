module SupraOracle::price_data_pull {

    use sui::tx_context::TxContext;
    use SupraOracle::SupraSValueFeed::OracleHolder;
    use supra_validator::validator::DkgState;

    struct PriceData has copy, drop { }

    /// Returns price data while verifying the oracle proof
    native public fun verify_oracle_proof (
        dkg_state: &DkgState,
        oracle_holder: &mut OracleHolder,

        vote_smr_block_round: vector<vector<u8>>,
        vote_smr_block_timestamp: vector<vector<u8>>,
        vote_smr_block_author: vector<vector<u8>>,
        vote_smr_block_qc_hash: vector<vector<u8>>,
        vote_smr_block_batch_hashes: vector<vector<vector<u8>>>,
        vote_round: vector<u64>,

        min_batch_protocol: vector<vector<u8>>,
        min_batch_txn_hashes: vector<vector<vector<u8>>>,

        min_txn_cluster_hashes: vector<vector<vector<u8>>>,
        min_txn_sender: vector<vector<u8>>,
        min_txn_protocol: vector<vector<u8>>,
        min_txn_tx_sub_type: vector<u8>,

        scc_data_hash: vector<vector<u8>>,
        scc_pair: vector<vector<u32>>,
        scc_prices: vector<vector<u128>>,
        scc_timestamp: vector<vector<u128>>,
        scc_decimals: vector<vector<u16>>,
        scc_qc: vector<vector<u8>>,
        scc_round: vector<u64>,
        scc_id: vector<vector<u8>>,
        scc_member_index: vector<u64>,
        scc_committee_index: vector<u64>,

        batch_idx: vector<u64>,
        txn_idx: vector<u64>,
        cluster_idx: vector<u64>,
        sig: vector<vector<u8>>,
        pair_mask: vector<vector<bool>>,

        ctx: &mut TxContext,
    ): vector<PriceData>;

    /// Extract price data in tuple
    native public fun price_data_split(price_data: &PriceData): (u32, u128, u16, u64);
}
