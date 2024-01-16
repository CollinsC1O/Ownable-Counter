#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: TContractState) -> u32;
    fn increase_counter(ref self: TContractState, initial_counter: u32);
}

#[starknet::contract]
mod CounterContract {
    #[storage]
    struct Storage {
        counter: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_counter: u32) {
        self.counter.write(initial_counter)
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<TContractState> {
        fn get_counter(self: TContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: TContractState, initial_counter: u32) {
            let current_counter: u32 = self.counter.read();
            self.counter.write(current_counter + 1)
        }
    }
}
