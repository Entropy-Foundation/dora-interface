module supra_validator::validator_v2 {
    use sui::object::UID;

    struct DkgState has key, store { id: UID }
}
