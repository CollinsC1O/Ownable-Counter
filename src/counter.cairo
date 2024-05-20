#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;

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
    impl CounterImpl of super::ICounter<ContractState> {
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: ContractState, initial_counter: u32) {
            let current_counter: u32 = self.counter.read();
            self.counter.write(current_counter + 1)
        }
    }
}


#[cfg(test)]
mod test_counter {
    use core::result::ResultTrait;
    use core::array::ArrayTrait;
    use starknet::{ContractAddress, TryInto};
    use core::option::OptionTrait;
    use starknet::syscalls::deploy_syscall;
    use super::{CounterContract, ICounterDispatcher, ICounterDispatcherTrait};

    #[test]
    #[available_gas(100000000)]
    fn test_counter() {
        let initial_counter: u32 = 10;
        let admin_acct: ContractAddress = 'admin'.try_into().unwrap();

        let calldata = array![initial_counter.into(), admin_acct.into()];

        let (address0, _) = deploy_syscall(
            CounterContract::TEST_CLASS_HASH.try_into(), 0, calldata.span(), false
        )
            .unwrap();

        let contract0 = ICounterDispatcher { contract_address: address0 };

        assert(initial_counter == contract0.get_counter(), 'invalid counter');
    }
}
