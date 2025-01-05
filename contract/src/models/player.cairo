use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::event::EventStorage;

const DEFAULT_HEALTH: U32 = 100;
const DEFAULT_STAMINA: u32 = 100;
const DEFAULT_RANK: U8 = 0;

mod errors {
    const PLAYER_NOT_FOUND: felt252 = "Player: not found";
    const PLAYER_ALREADY_EXISTS: felt252 = "Player: already exists";
    const INVALID_PLAYER_ACTION: felt252 = "Player: invalid action";
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct PlayerHealthModified {
    #[key]
    player: ContractAddress,
    health_change: u32,
    is_decrease: bool
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct PlayerStaminaModified {
    #[key]
    player: ContractAddress,
    stamina_change: u32,
    is_decrease: bool
}

#[derive(Copy, Drop, Serde)]
#[dojo: model]
struct Player {
    [key]
    id: ContractAddress,
    health: u32,
    stamina: u32,
    rank: U8
}

#[generate_trait]
impl PlayerImpl of PlayerTrait {

    #[inline(always)]
    fn spawn_player(ref self: ContractState, id: ContractAddress) {
        let mut world = self.world_default();

        if world.has_model::<Player>(id) {
            panic(errors::PLAYER_ALREADY_EXISTS);
        };

        let new_player = Player {
            id,
            health: DEFAULT_HEALTH,
            stamina: DEFAULT_STAMINA,
            rank: DEFAULT_RANK
        };

        world.write_model(@new_player);
    }

    #[inline(always)]
    fn modify_health(ref self: ContractState, id: ContractAddress, amount: u32, is_decrease: bool) {
        let mut world = self.world_default();
        let mut player:Player = world.read_model(id);

        if is_decrease {
            player.health =  player.health.saturating_sub(amount);
        } else {
            player.health = player.health.saturating_add(amount);
        }

        world.write_model(@player);
        world.emit_event(@PlayerHealthModified {player: id, health_change: amount, is_decrease});
    }

    #[inline(always)]
    fn modify_stamina(ref self: ContractState, id: ContractAddress, amount: u32, is_decrease: bool) {
        let mut world = self.world_default();
        let mut player:Player = world.read_model(id);

        if is_decrease {
            player.stamina = player.stamina.saturating_sub(amount);
        } else {
            player.stamina = player.stamina.saturating_add(amount);
        };

        world.write_model(@player);
        world.emit_event(@PlayerStaminaModified { player: id, stamina_change: amount, is_decrease});
    }

    #[inline(always)]
    fn is_alive(self: Player) -> bool {
        self.health > 0
    }

    #[inline(always)]
    fn upgrade_rank(ref self: ContractState, id: ContractAddress) {
        let mut world = self.world_default();
        let mut player: Player = world.read_model(id);

        player.rank += 1;
        world.write_model(@player);
    }
}

#[generate_trait]
impl InternalImpl of InternalTrait {
    
    #[inline(always)]
    fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
        self.world("xapocalypse");
    }
}

