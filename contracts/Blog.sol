//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    string public name;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    struct Post {
        uint256 id;
        string title;
        string content;
        bool published;
    }

    mapping(uint256 => Post) private idToPost;
    mapping(string => Post) private hashToPost;

    event PostCreated(uint256 id, string title, string hash);
    event PostUpdated(uint256 id, string title, string hash, bool published);

    constructor(string memory _name) {
        console.log("Deploying blog with name: ", _name);
        name = _name;
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function updateName(string memory _name) public onlyOwner {
        name = _name;
    }

    function createPost(string memory _title, string memory _hash)
        public
        onlyOwner
    {
        _postIds.increment();
        uint256 _id = _postIds.current();
        Post storage post = idToPost[_id];
        post.id = _id;
        post.title = _title;
        post.content = _hash;
        post.published = true;
        hashToPost[_hash] = post;
        emit PostCreated(_id, _title, _hash);
    }

    function updatePost(
        uint256 _id,
        string memory _title,
        string memory _hash,
        bool _published
    ) public onlyOwner {
        Post storage post = idToPost[_id];
        post.title = _title;
        post.content = _hash;
        post.published = _published;
        idToPost[_id] = post;
        hashToPost[_hash] = post;
        emit PostUpdated(_id, _title, _hash, _published);
    }

    function fetchPost(string memory _hash) public view returns (Post memory) {
        return hashToPost[_hash];
    }

    function fetchPosts() public view returns (Post[] memory) {
        uint256 itemCount = _postIds.current();
        Post[] memory posts = new Post[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Post storage currentItem = idToPost[currentId];
            posts[i] = currentItem;
        }
        return posts;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
}
