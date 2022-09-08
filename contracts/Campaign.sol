// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./CampaignInterface.sol";

/// @title CampaignFactory
/// @author @tanim0la, @kingahmedino
/// @notice This contract manages all campaigns created on the Crowdcoin dApp
/// @dev All function calls are currently implemented without side effects
contract CampaignFactory  is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    address[] public deployedCampaigns;

    mapping(address => address[]) public creatorCampaigns;
    mapping(address => address[]) public contributedCampaigns;
    mapping(address => mapping(address => bool)) public contributed;


    function initialize() public initializer {
        __Ownable_init();
    }

    function createCampaign (string memory campaignName, string memory creatorName, uint256 minimum, string memory campaignDescription) public {
        address newCampaign = address(new Campaign(campaignName, creatorName, minimum, campaignDescription, msg.sender));

        creatorCampaigns[_msgSender()].push(newCampaign);
        deployedCampaigns.push(newCampaign);
    }

    function contribute(address _campaign) public payable {
        CampaignInterface _campaignInterface = CampaignInterface(_campaign);
        _campaignInterface.contribute{value: msg.value}(_msgSender());

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
        return deployedCampaigns;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

}


contract Campaign {

    struct Request {
        address recipient;
        bool complete;
        uint40 approvalCount;
        string description;
        uint256 value;
        mapping(address => bool) approvals;
    }  

    string public campaignName;
    string public creatorName;
    string public campaignDescription;

    uint256 public minimumContribution;
    uint40 public contributorsCount;
    uint256 public totalContributed;
    uint8 public numRequests;
    uint40 public createdAt;

    address public creator;

    mapping(address => uint) public contributorBalance;

    Request[] public requests;

    constructor(string memory _campaignName, string memory _creatorName, uint256 minimum, string memory _campaignDescription, address _creator) {
        creator = _creator;
        minimumContribution = minimum;
        creatorName = _creatorName;
        campaignName = _campaignName;
        campaignDescription = _campaignDescription;
        createdAt = uint40(block.timestamp);
    }


    function contribute(address _contributorAddress) public payable {
        require(msg.value >= minimumContribution, "amount not greater than minimum");

        if(contributorBalance[_contributorAddress] == 0){
            contributorsCount++;
        }

        contributorBalance[_contributorAddress] += msg.value;
        totalContributed += msg.value;
    }

    function createRequest(string memory description, uint256 value, address recipient) public restricted {
        requests.push();
        Request storage newRequest = requests[numRequests++];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(contributorBalance[msg.sender] > 0, "not a contributor");
        require(!request.approvals[msg.sender], "cannot multi-approve");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (contributorsCount/2), "not enough approvals");
        require(!request.complete, "request already finalized");

        request.complete = true;

        payable(request.recipient).transfer(request.value);
    }

    function getSummary() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, string memory, string memory, string memory, address) {
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