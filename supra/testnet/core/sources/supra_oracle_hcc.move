module supra_oracle::supra_oracle_hcc {

    /// HCC return value for a pair
    struct HccValue has store,drop,copy {
        pair_id: u32,
        hcc_value: u8,
    }


    #[view]
    /// To get object address of HccPairs,HccPairClusters and HccObjectController
    native public fun get_hcc_pair_object_address(): address;

    #[view]
    /// Returns the list of pairs under HCC
    native public fun hcc_pair_list(): vector<u32>;

    #[view]
    /// External view function
    /// It will return the Pair Value List for that particular tradingPair if its under HCC
    native public fun get_price_list(pair: u32): vector<u128>;

    #[view]
    /// It will return if the pair is under History Consistency Check or not
    native public fun under_hcc(pair_id: u32): bool;

    #[view]
    /// It will return the current HCC value of list of pairs
    native public fun get_hcc_value(pair_ids: vector<u32>): vector<HccValue>;


    }
