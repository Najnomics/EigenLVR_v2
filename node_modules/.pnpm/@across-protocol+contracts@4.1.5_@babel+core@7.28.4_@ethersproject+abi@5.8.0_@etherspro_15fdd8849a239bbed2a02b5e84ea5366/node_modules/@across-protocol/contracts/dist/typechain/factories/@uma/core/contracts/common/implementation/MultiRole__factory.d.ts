import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { MultiRole, MultiRoleInterface } from "../../../../../../@uma/core/contracts/common/implementation/MultiRole";
export declare class MultiRole__factory {
    static readonly abi: readonly [{
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "newMember";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "manager";
            readonly type: "address";
        }];
        readonly name: "AddedSharedMember";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "oldMember";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "manager";
            readonly type: "address";
        }];
        readonly name: "RemovedSharedMember";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "newMember";
            readonly type: "address";
        }, {
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "manager";
            readonly type: "address";
        }];
        readonly name: "ResetExclusiveMember";
        readonly type: "event";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "newMember";
            readonly type: "address";
        }];
        readonly name: "addMember";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }];
        readonly name: "getMember";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "memberToCheck";
            readonly type: "address";
        }];
        readonly name: "holdsRole";
        readonly outputs: readonly [{
            readonly internalType: "bool";
            readonly name: "";
            readonly type: "bool";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "memberToRemove";
            readonly type: "address";
        }];
        readonly name: "removeMember";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }];
        readonly name: "renounceMembership";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "roleId";
            readonly type: "uint256";
        }, {
            readonly internalType: "address";
            readonly name: "newMember";
            readonly type: "address";
        }];
        readonly name: "resetMember";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): MultiRoleInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): MultiRole;
}
