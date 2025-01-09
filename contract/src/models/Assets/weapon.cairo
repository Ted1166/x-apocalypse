#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
struct Weapon {
    #[key]
    game_id: u32,
    #[key]
    id: ContractAddress,
    type_: felt252,
    damge: u32,
    durability: u32,
    range: u32,
    owner: ContractAddress
}

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
enum WeaponType {
    Melee,
    Ranged,
    Explosive,
}

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
enum WeaponStatus {
    Functional,
    Damaged,
    Broken,
}