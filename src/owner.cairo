use starknet::ContractAddress;
#[starknet::interface]
trait IOwnable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::component]
mod OwnableComponent {
    use core::num::traits::zero::Zero;
    use starknet::{ContractAddress, get_caller_address};
    use core::zeroable::Zeroable;

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
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    // #[constructor]
    // fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
    //     self._transfer_ownership(initial_owner)
    // }

    #[embeddable_as(OwnableImpl)]
    impl Ownable<
        TContractState, +HasComponent<TContractState>
    > of super::IOwnable<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            assert(!new_owner.is_zero(), 'Invalid Address');

            self.assert_only_owner();
        }
    }

    #[generate_trait]
    impl Internal of InternalTrait {
        fn initializer(ref self: ContractState, owner: ContractAddress) {
            self._transfer_ownership(owner);
        }

        fn _transfer_ownership(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self._transfer_ownership(owner);
        }

        fn assert_only_owner(self: @ComponentState<TContractState>, new_owner: ContractAddress) {
            let owner: ContractAddress = self.owner.read();
            let caller: ContractAddress = get_caller_address();
            assert(caller == owner, 'Invalid Caller');
        }

        fn _transfer_ownership(
            ref self: ComponentState<TContractState>, new_owner: ContractAddress
        ) {
            let previous_owner = self.owner.read();

            self.owner.write(new_owner)

            self.emit(OwnershipTranfer { previous_owner: previous_owner, new_owner: new_owner, })
        }
    }
}
