// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "@balancer-labs/v2-interfaces/contracts/standalone-utils/IRegistry.sol";

/**
 * @author Balancer Labs
 * @title Registry
 * @notice Balancer address registry.
 */

contract Registry is IRegistry {
    //Only admin is authenticated
    address private immutable _admin;
    uint256 public numEntries;

    struct RegistryEntry {
        uint256 entryType;
        address addr;
        string name;
    }

    mapping(uint256 => RegistryEntry) private registryEntries;
    mapping(bytes32 => uint256) private _hashNameRegistry;
    mapping(address => uint256) private _addressRegistry;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not Admin");
        _;
    }

    constructor(address _adminAddress) {
        _admin = _adminAddress;
    }

    function createEntry(string memory name, address addr, uint256 entryType) public override {
        require(addr != address(0), "Invalid Address");
        bytes32 hashName = keccak256(abi.encode(name));
        require(hashName != bytes32(0), "Invalid Name");
        require(_addressRegistry[addr] == 0, "Address already registered");
        require(_hashNameRegistry[hashName] == 0, "Name already registered");

        numEntries += 1;
        RegistryEntry memory entry = RegistryEntry({name: name, addr: addr, entryType: entryType});
        _hashNameRegistry[hashName] = numEntries;
        _addressRegistry[addr] = numEntries;
        registryEntries[numEntries] = entry;
    }

    function updateName(string memory name, address addr) public override {
        uint256 id = _addressRegistry[addr];
        require(id != 0, "Address not registered");
        bytes32 priorHashName = keccak256(abi.encode(registryEntries[id].name));
        bytes32 hashName = keccak256(abi.encode(name));
        require(_hashNameRegistry[hashName] == 0, "Name already registered");

        registryEntries[id].name = name;
        _hashNameRegistry[priorHashName] = 0;
        _hashNameRegistry[hashName] = id;
    }

    function getEntry(string memory name) public view override returns (address) {
        uint256 id = _hashNameRegistry[keccak256(abi.encode(name))];
        return registryEntries[id].addr;
    }

    function isEntry(string memory name, address addr) public view override returns (bool){
        return _hashNameRegistry[keccak256(abi.encode(name))] == _addressRegistry[addr];
    }

    function isInRegistry(address addr) public view override returns (bool) {
        return _addressRegistry[addr] != 0;
    }

    function getName(address addr) public view override returns (string memory) {
        return registryEntries[_addressRegistry[addr]].name;
    }

}
