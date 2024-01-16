use starknet::ContractAddress;

#[starknet::interface]
trait IOwnable<TContractState> {
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn transfer_owner(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
mod OwnableComponent {
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTranfer: OwnershipTranfer,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTranfer {
        previous_owner: previous_owner,
        new_owner: new_owner,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self._transfer_ownership(initial_owner)
    }


    #[embeddable_as(OwnableImpl)]
    impl Ownable<
        TContractState, +HasComponent<TContractState>
    > of super::IOwnable<ComponentState<TContractState>> {
        fn get_owner(self: @TContractState) -> ContractAddress {
            self.owner.read()
        }
        fn transfer_owner(ref self: TContractState, new_owner: ContractAddress) {
            assert(!new_owner.is_zero, 'Invalid Address');
        }

        #[generate_trait]
        impl Internal of InternalTrait {
            fn _transfer_ownership(ref self: ContractState, owner: ContractAddress) {
                self._transfer_ownership(owner)
            }

            fn assert_only_owner(self: @ContractState, new_owner: ContractAddress) {
                let owner: ContractAddress = self.owner.read();
                let caller: ContractAddress = get_caller_address();
                assert(caller == owner, 'Invalid Caller');
            }

            fn _transfer_ownership(ref self: ComponentState, new_owner: ContractAddress) {
                let previous_owner = self.owner.read();

                self.owner.write(new_owner)

                self
                    .emit(
                        OwnershipTranfer { previous_owner: previous_owner, new_owner: new_owner, }
                    )
            }
        }
    }
}
