module supra_utils::utils {

    /// unstable append of second vector into first vector
    native public fun destructive_reverse_append<Element: drop>(first: &mut vector<Element>, second: vector<Element>);

    /// Flatten and concatenate the vectors
    native public fun vector_flatten_concat<Element: copy + drop>(lhs: &mut vector<Element>, other: vector<vector<Element>>);

}
