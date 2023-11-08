// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract chatApp{
    struct user{
        string name;
        friend[] friendsList;

    }
    struct friend{
        address pubkey;
        string name;
    }
    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    
    }
    struct AllUserStruct{
        string name;
        address accountAddress;
    }

    AllUserStruct[] getAllUsers;
    mapping (address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    function checkUserExists(address pubkey) public view returns (bool){
        return bytes(userList[pubkey].name).length > 0;
    }
    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User Already Exists");
        require(bytes(name).length>0, "UserName cannot be empty");
        userList[msg.sender].name = name;
        getAllUsers.push(AllUserStruct(name, msg.sender));
    }
    function getUserName(address pubkey) external view returns(string memory){
        require(checkUserExists(pubkey), "User is not registered");
        return userList[pubkey].name;
    }
    function addFriend(address friend_Key, string calldata name) external {
        require(checkUserExists(msg.sender), "Create an account first");
        require(checkUserExists(friend_Key), "User is not registered");
        require(msg.sender != friend_Key, "User cannot add themselves as friends");
        require(checkAlreadyFriends(msg.sender, friend_Key)== false, "These users are already friends");

_addfriend(msg.sender, friend_Key, name);
_addfriend(friend_Key, msg.sender, userList[msg.sender].name);
    }
    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns (bool){
        if (userList[pubkey1].friendsList.length > userList[pubkey2].friendsList.length){
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }
        for(uint256 i =0; i <userList[pubkey1].friendsList.length; i++){
            if (userList[pubkey1].friendsList[i].pubkey == pubkey2) return true;
        }
       return false;
    }
    function _addfriend(address me, address friend_key, string memory name) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendsList.push(newFriend);
    }
    function getMyFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendsList;
    }
    function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if (pubkey1 <pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        }
        else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }
    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExists(msg.sender), "Create an account first");
        require(checkUserExists(friend_key), "User is not registered");
        require(checkAlreadyFriends(msg.sender, friend_key), "You are not friend with the given user");
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);  
    }
    function readMessage(address friend_key) external view returns(message[] memory){
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }
function    getAllAppUser() public view returns(AllUserStruct[] memory){
        return getAllUsers;
    }
}