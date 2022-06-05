// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;
/**+-ReentrancyGuard:_ This is a Security Mechanism that gives us an Utility Helper callled "non-re-entrant" that will help us to protect certain transactions
that are Talking to a Separate Smart Contract to prevent someone to hit this with multiple malicious transactions.*/
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

//import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";

/**
 * Request testnet LINK and MATIC here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract Database is ReentrancyGuard, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address payable owner;
    //+-Message Price:_ The Fee that the user Pays for Listing a N.F.T.
    uint256 msgPrice = 0.01 ether; //+-0.01 MATIC per Message.

    //+-This is ChainLink Node Operator Oracle Address, it will change depending on the E.V.M. Chain Used (ETH, Polygon, etc):_
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId, string volume);

    //+-Stores the Default Name of an User and its Friends Information:_
    struct user {
        string name;
        friend[] friendList;
    }

    //+-Each Friend is identified by its Wallet Address and Name assigned by the Second party:_
    struct friend {
        address pubkey;
        string name;
    }

    //+-The Message Struct Stores the single Chat Message and its MetaData:_
    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    //+-Collection of users Registered on the Application:_
    mapping(address => user) userList;
    //+-Collection of Messages communicated in a Channel between 2 Users:_
    mapping(bytes32 => message[]) allMessages; // key : Hash(user1,user2)

    //+-It checks whether an User(identified by its Wallet Address/Public Key) has created an Account on this Application or Not:_
    function checkUserExists(address pubkey) public view returns (bool) {
        return bytes(userList[pubkey].name).length > 0;
    }

    constructor() {
        owner = payable(msg.sender);
        setPublicChainlinkToken();
        oracle = 0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656;
        //+-Kovan Ethereum TestNet LINK Token Contract Address. https://docs.chain.link/docs/decentralized-oracles-ethereum-mainnet/
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        /**+-HTTP GET to any public API, parse the response and return a sequence of characters string:_
        https://docs.chain.link/docs/direct-request-get-string/.*/
        fee = 0.1 * 10**18; // (Varies by network and job)
        //+-NOTE:_ I could write Get and Set Functions for these Parameters, but I find it unnecessary and excessive for the scope of this Test.
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function getOwner() public view virtual returns (address) {
        return owner;
    }

    //+-Returns the Message Price of the Smart Contract:_
    function getMsgPrice() public view returns (uint256) {
        return msgPrice;
    }

    //+-Sets the Listing Price of the Smart Contract:_
    function setMsgPrice(uint256 newPrice) public onlyOwner {
        msgPrice = newPrice;
    }

    //+-Registers the caller(msg.sender) to our App with a non-empty UserName:_
    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User already exists!");
        require(bytes(name).length > 0, "Username cannot be empty!");
        userList[msg.sender].name = name;
    }

    //+-Returns the default name provided by an user:_
    function getUsername(address pubkey) external view returns (string memory) {
        require(checkUserExists(pubkey), "User is not registered!");
        return userList[pubkey].name;
    }

    //+-A helper function to update the friendList:_
    function _addFriend(
        address me,
        address friend_key,
        string memory name
    ) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //+-Adds new user as your friend with an associated nickname:_
    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExists(msg.sender), "Create an account first!");
        require(checkUserExists(friend_key), "User is not registered!");
        require(
            msg.sender != friend_key,
            "Users cannot add themselves as friends!"
        );
        require(
            checkAlreadyFriends(msg.sender, friend_key) == false,
            "These users are already friends!"
        );

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    //+-Checks if two users are already friends or not:_
    function checkAlreadyFriends(address pubkey1, address pubkey2)
        internal
        view
        returns (bool)
    {
        if (
            userList[pubkey1].friendList.length >
            userList[pubkey2].friendList.length
        ) {
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }

        for (uint256 i = 0; i < userList[pubkey1].friendList.length; ++i) {
            if (userList[pubkey1].friendList[i].pubkey == pubkey2) return true;
        }
        return false;
    }

    //+-Returns list of friends of the sender:_
    function getMyFriendList() external view returns (friend[] memory) {
        return userList[msg.sender].friendList;
    }

    //+-Returns a unique code for the channel created between the two users:_
    // Hash(key1,key2) where key1 is lexicographically smaller than key2
    function _getChatCode(address pubkey1, address pubkey2)
        internal
        pure
        returns (bytes32)
    {
        if (pubkey1 < pubkey2)
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    //+-Sends a new message to a given friend:_
    function sendMessage(address friend_key, string calldata _msg)
        public
        payable
        nonReentrant
    {
        require(checkUserExists(msg.sender), "Create an account first!");
        require(checkUserExists(friend_key), "User is not registered!");
        require(
            checkAlreadyFriends(msg.sender, friend_key),
            "You are not friends with the given user"
        );
        require(
            msg.value == msgPrice,
            "msg.value(Fee to pay) must be equal to message price"
        );

        payable(owner).transfer(msgPrice);

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    //+-Returns all the chat messages communicated in a channel:_
    function readMessage(address friend_key)
        external
        view
        returns (message[] memory)
    {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestCatFact() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.sendCatFactMessage.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", "https://catfact.ninja/fact");

        // Set the path to find the desired data in the API response, where the response format is:
        // {
        //      "fact": "A cat’s brain is biologically more similar to a human brain than it is to a dog’s. Both humans and cats have identical regions in their brains that are responsible for emotions.",
        //      "length": 177
        //  }

        req.add("path", "fact"); // Chainlink nodes 1.0.0 and later support this format.

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    //+-Receives the Random Cat Fact and Sends it as a Message to a Friend:_
    function sendCatFactMessage(
        bytes32 _requestId,
        address friend_key,
        string calldata _msg
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestVolume(_requestId, _msg);
        sendMessage(friend_key, _msg);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
