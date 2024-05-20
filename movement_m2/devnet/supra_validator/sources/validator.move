module supra_validator::validator {
    use sui::object::UID;

    struct DkgState has key, store { id: UID }
}
