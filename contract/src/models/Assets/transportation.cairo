use dojo::model::ModelStorage;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum TransportType {
    Ground,
    Air,
    Water,
    Air,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum TransportStatus {
    Active,
    Damaged,
    Maintenance,
    Decomissioned,
}

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
struct Tranportation {
    #[key]
    game_id: u32,
    #[key]
    player_id: u32,
    transport_id: u32, 
    transport_name: felt252,
    transport_type: TransportType,
    capacity: u32,
    speed: u32,
    durability: u32,
    status: TransportStatus,
}