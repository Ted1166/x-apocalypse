#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
struct Material {
    #[Key]
    game_id: u32,
    #[key]
    Material_id: u32,
    name: felt252,
    quantity: u32,
    durability: u32,
    is_renewable: bool,
}

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
enum MaterialType {
    Wood,
    Steel,
    Plastic,
    Composite,
    RareMetal,
}