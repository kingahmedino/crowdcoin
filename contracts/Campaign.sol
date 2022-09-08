// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract CampaignFactory  is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    address[] public deplopedCampaigns;

    mapping(address => address[]) public creatorCampaigns;
    mapping(address => address[]) public contributedCampaigns;
    mapping(address => mapping(address => bool)) public contributed;


    function initialize() public initializer {
        __Ownable_init();
    }

    function createCampaign (string memory campaignName, string memory creatorName, uint minimum, string memory campaignDescription) public {
        address newCampaign = address(new Campaign(campaignName, creatorName, minimum, campaignDescription, msg.sender));

        creatorCampaigns[_msgSender()].push(newCampaign);
        deplopedCampaigns.push(newCampaign);
    }

    function contribute(address _campaign) public payable {
        Campaign(_campaign).contribute{value: msg.value}(_msgSender());

        if(!contributed[_msgSender()][_campaign]){
            contributedCampaigns[_msgSender()].push(_campaign);
            contributed[_msgSender()][_campaign] = true;
        }
    }

    function getCreatorCampaigns(address creatorAddress) public view returns (address[] memory) {
        return creatorCampaigns[creatorAddress];
    }

    function getContributedCampaigns(address contributorAddress) public view returns (address[] memory) {
        return contributedCampaigns[contributorAddress];
    }


    function getDeployedCampaigns() public view returns (address[] memory) {
        return deplopedCampaigns;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

}


contract Campaign {

    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }  

    string public campaignName;
    string public creatorName;
    string public campaignDescription;

    uint public minimumContribution;
    uint public contributorsCount;
    uint public totalContributed;
    uint public numRequests;
    uint public createdAt;

    address public creator;

    mapping(address => bool) public contributors;

    Request[] public requests;

    constructor(string memory _campaignName, string memory _creatorName, uint minimum, string memory _campaignDescription, address _creator) {
        creator = _creator;
        minimumContribution = minimum;
        creatorName = _creatorName;
        campaignName = _campaignName;
        campaignDescription = _campaignDescription;
        createdAt = block.timestamp;
    }


    function contribute(address _contributorAddress) public payable {
        require(msg.value >= minimumContribution, "AMOUNT NOT GREATER THAN MINIMUM");
  
        if(!contributors[_contributorAddress]){
            contributors[_contributorAddress] = true;
            contributorsCount++;
        }
        totalContributed += msg.value;
    }

    function createRequest(string memory description, uint value, address recipient) public restricted {
        requests.push();
        Request storage newRequest = requests[numRequests++];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;

    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];

        require(contributors[msg.sender], "NOT A CONTRIBUTOR!!!");
        require(!request.approvals[msg.sender], "CANNOT APPROVE A REQUEST TWICE!!!");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (contributorsCount/2), "NOT ENOUGH APPROVAL!!!");
        require(!request.complete, "THIS REQUEST HAS BEEN FINALIZED!!!");

        request.complete = true;

        payable(request.recipient).transfer(request.value);
    }

    function getSummary() public view returns (uint, uint, uint, uint, uint, uint, string memory, string memory, string memory, address) {
        return(
            minimumContribution,
            address(this).balance,
            totalContributed,
            requests.length,
            contributorsCount,
            createdAt,
            campaignName,
            creatorName,
            campaignDescription,
            creator
        );
    }
    
    modifier restricted() {
        require(msg.sender == creator);
        _;
    }
}