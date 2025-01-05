use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::event::EventStorage;

mod errors {
    const RESOURCE_NOT_FOUND: felt252 = "Resource; not found";
    const RESOURCE_ALREADY_EXISTS: felt252 = "Resource: already exists";
    const INSUFFICIENT_AMOUNT: felt252 = "Resource: insufficient amount";
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct ResourceModified {
    #[key]
    game_id: u32,
    #[key]
    resource: ContractAddress,
    amount_change: u32,
    is_decrease:bool
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Resource {
    #[key]
    game_id: u32,
    #[key]
    id: ContractAddress,
    name: felt252,
    amount: u32,
}

#[generate_trait]
impl ResourceImpl of ResourceTrait {

    #[inline(always)]
    fn create_resource(ref self: ContractState, id: ContractAddress, game_id: u32, name; felt252, initial_amount: u32) {
        let mut world = self.world_default();

        if world.has_model::<Resource>((id, game_id)) {
            panic(errors::RESOURCE_ALREADY_EXISTS);
        }

        let new_resource = Resource {
            id,
            game_id,
            name,
            amount: initial_amount,
        };

        world.write_model(@new_resource);
    }

    #[inline(always)]
    fn modify_amount(ref self: ContractState, id: ContractAddress, game_id: u32, amount_change: u32, is_decrease: bool) {
        let mut world = self.world_default();
        let mut resource: Resource = world.read_model((id, game_id));

        if is_decrease {
            resource.amount = resource.amount.saturating_sub(amount_change);
        } else {
            resource.amount = resource.amount.saturating_add(amount_change);
        }

        world.write_model(@resource);
        world.emit_event(@ResourceAmountModified {resource: id, game_id, amount_change, is_decrease});
    }

    #[inline(always)]
    fn get_amount(ref self: ContractState, id: ContractAddress, game_id: u32) -> u32 {
        let world self.world_default();
        let resource: Resource = world.read_model(id, game_id);
        resource.amount;
    }

    #[inline(always)]
    fn delete_resources(ref self: ContractState, id: ContractAddress, game_id: u32) {
        let mut world = self.world_default();

        if !world.has_model::<Resource>(id, game_id) {
            panic(errors::RESOURCE_NOT_FOUND);
        }

        world.delete_model::<Resource>(id, game_id);
    }
}

#[generate_trait]
impl InternalImpl of InternalTrait {

    #[inline(always)]
    fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
        self.world("xapocalypse_resouces");
    }
}