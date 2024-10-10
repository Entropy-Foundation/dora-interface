module supra_oracle::supra_oracle_indices {

    use supra_framework::object::Object;

    struct Index has key, copy, drop {
        // unique identifier for the index
        id: u64,
        pair_ids: vector<u32>,
        init_value: u256,
        init_index_time: u64,
        last_update_time: u64,
        scaling_factor: u256,
        scaled_weights: vector<u256>,
        index_decimal: u16,
        index_value: u256
    }

    /// Public entry function to create a new index without an initial value (default init_value = INIT_VALUE).
    /// This function can be accessed by anyone
    native public entry fun create_index(
        owner_signer: &signer,
        pair_ids: vector<u32>,
        weights: vector<u32>,
    );

    /// Public entry function to create a new index with an initial value.
    /// This function can be accessed by anyone
    native public entry fun create_index_with_init_value(
        owner_signer: &signer,
        pair_ids: vector<u32>,
        weights: vector<u32>,
        init_value: u32,
    );

    /// Public entry function to update an existing index
    /// This function can be accessed those who owns index_id ownership
    native public fun update_index(
        owner_signer: &signer,
        index_object: Object<Index>,
        pair_ids: vector<u32>,
        weights: vector<u32>,
    );

    /// Public entry function to delete an existing index
    /// This function can be accessed by those who owns index_id ownership
    native public fun delete_index(
        owner_signer: &signer,
        index_object: Object<Index>,
    );

    /// Public function to calculate the value of an index.
    /// This function can be accessed by anyone.
    native public fun calculate_index_value(
        index_objects: vector<Object<Index>>,
    );

    /// Public function that retrieves the index values considering staleness tolerance.
    /// If an index is stale, it recalculates and updates the value.
    /// - Returns `(vector<u256>, vector<bool>)`: A tuple containing two vectors:
    ///   - The first vector contains the index values (u256).
    ///   - The second vector contains boolean values indicating whether the index value is within the staleness tolerance (true).
    ///     If an index is stale, it recalculates, and still not within the tolerance, it returns (false).
    native public fun get_indices_with_staleness_tolerance(
        index_objects: vector<Object<Index>>,
        staleness_tolerances: vector<u64>
    ): (vector<u256>, vector<bool>);

    #[view]
    /// Public view function to get the details of index by there index_id
    native public fun get_index_by_id(index_id: u64): Object<Index>;

    #[view]
    /// Public view function to get `Index` object address from index_id
    native public fun get_index_address(index_id: u64): address;

    #[view]
    /// Get index object with details
    native public fun get_index_details(index_object: Object<Index>): Index;

    #[view]
    /// Get Weight of Index with `MAX_INDEX_DECIMAL` decimal
    native public fun get_index_weight(index_id: u64): (vector<u256>, u16);
}
