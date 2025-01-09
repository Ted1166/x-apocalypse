use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::event::EventStorage;

mod errors {
    const SHELTER_NOT_FOUND: felt252 = "Shelter not found";
    const SHELTER_ALREADY_EXISTS: felt252 = "Shelter already exists";
    const INVALID_SHELTER_OPERATION: felt252 = "Shelter: invalid operation";
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct ShelterCapacityModified {
    #[key]
    Shelter: ContractAddress,
    resource_change: u32,
    is_decrease: bool,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct Shelter {
    #[key]
    game_id: u32,
    #[key]
    id: ContractAddress,
    location: felt252,
    capacity: u32,
    occupants: u32,
    resources: u32,
}

#[generate_trait]
impl ShelterImpl of ShelterTrait {

    #[inline(always)]
    fn spawn_shelter(ref self: ContractState, game_id: u32, id: ContractAddress, location: felt252, capacity: u32) {
        let mut world = self.world_default();

        if world.has_model::<Shelter>(id) {
            panic(errors::SHELTER_ALREADY_EXISTS);
        }

        let new_shelter = shelter {
            game_id,
            id,
            location,
            capacity,
            occupants: 0,
            resources: 0,
        };

        world.write_model(@new_shelter);
    }

    #[inline(always)]
    fn modify_resources(ref self: ContractState, id: ContractAddress, amount: u32, is_decrease: bool) {
        let mut world = self.world_default();
        let mut shelter = world.read_model(id);

        if is_decrease {
            if shelter.resources < amount {
                panic(errors::INVALID_SHELTER_OPERATION);
            }
            shelter.resources -= amount;
        } else {
            shelter.resources += amount;
        }

        world.write_model(@shelter);
        world.emit_event(@ShelterResourecesModified {
            shelter: id,
            resource_change: amount,
            is_decrease,
        });
    }

    #[inline(always)]
    fn has_resources(self: Shelter, required: u32) -> bool {
        self.resource >= required
    }
}

#[generate_trait]
impl InternalImpl of InternalTrait {

    #[inline(always)]
    fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
        self.world("xapocalypse")
    }
}