// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./CampaignInterface.sol";

/** @title CampaignFactory
 * @author @tanim0la, @kingahmedino
 * @notice This contract manages all campaigns created on the Crowdcoin dApp
 * @dev All function calls are currently implemented without side effects
 */
contract CampaignFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public deployedCampaigns;

    mapping(address => address[]) public creatorCampaigns;
    mapping(address => address[]) public contributedCampaigns;
    mapping(address => mapping(address => bool)) public contributed;

    event CampaignCreated(
        string campaignName,
        string creatorName,
        string campaignDescription,
        uint256 indexed minimumContribution,
        address indexed escrowAddress
    );

    event Contributed(
        address indexed campaign,
        address indexed contributor,
        uint256 value
    );

    function initialize() public initializer {
        __Ownable_init();
    }

    /**
     * @notice Allows anyone to create a new campaign
     * @param campaignName The name of the campaign
     * @param creatorName The name of the creator
     * @param minimum The minimum contribution accepted into the campaign
     * @param campaignDescription The description of the campaign
     */
    function createCampaign(
        string memory campaignName,
        string memory creatorName,
        uint256 minimum,
        string memory campaignDescription
    ) public {
        address newCampaign = address(
            new Campaign(
                campaignName,
                creatorName,
                minimum,
                campaignDescription,
                msg.sender
            )
        );

        creatorCampaigns[_msgSender()].push(newCampaign);
        deployedCampaigns.push(newCampaign);

        emit CampaignCreated(
            campaignName,
            creatorName,
            campaignDescription,
            minimum,
            newCampaign
        );
    }

    /**
     * @notice Allows anyone to contribute ether to a campaign
     * @param _campaign The address of the campaign to contribute
     */
    function contribute(address _campaign) public payable {
        CampaignInterface _campaignInterface = CampaignInterface(_campaign);
        _campaignInterface.contribute{value: msg.value}(_msgSender());

        if (!contributed[_msgSender()][_campaign]) {
            contributedCampaigns[_msgSender()].push(_campaign);
            contributed[_msgSender()][_campaign] = true;
        }

        emit Contributed(_campaign, _msgSender(), msg.value);
    }

    /**
     * @notice Get campaigns created by an address
     * @param creatorAddress The address of the creator
     * @return The campaigns created by the creator address
     */
    function getCreatorCampaigns(address creatorAddress)
        public
        view
        returns (address[] memory)
    {
        return creatorCampaigns[creatorAddress];
    }

    /**
     * @notice Get campaigns an address contributed in
     * @param contributorAddress The address of the contributor
     * @return The campaigns contributed in by the contributor address
     */
    function getContributedCampaigns(address contributorAddress)
        public
        view
        returns (address[] memory)
    {
        return contributedCampaigns[contributorAddress];
    }

    /**
     * @notice Get all campaigns that have been created
     * @return All campaigns created
     */
    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}

/** @title Campaign
 * @author @tanim0la, @kingahmedino
 * @notice This contract manages all details of a single campaign created on the Crowdcoin dApp
 * @dev All function calls are currently implemented without side effects
 */
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

    mapping(address => uint256) public contributorBalance;

    Request[] public requests;

    event RequestCreated(
        address indexed campaign,
        address indexed recipient,
        uint256 indexed value,
        string description
    );

    event ApprovedRequest(
        address indexed campaign,
        string campaignName,
        address indexed approver,
        uint40 approvalsCount,
        string description
    );

    event RequestFinalized(
        address indexed campaign,
        string campaignName,
        address indexed recipient,
        uint40 approvalsCount,
        string description
    );

    constructor(
        string memory _campaignName,
        string memory _creatorName,
        uint256 minimum,
        string memory _campaignDescription,
        address _creator
    ) {
        creator = _creator;
        minimumContribution = minimum;
        creatorName = _creatorName;
        campaignName = _campaignName;
        campaignDescription = _campaignDescription;
        createdAt = uint40(block.timestamp);
    }

    /**
     * @notice Allows anyone to contribute ether to a campaign
     * @param _contributorAddress The address of the contributor
     */
    function contribute(address _contributorAddress) public payable {
        require(
            msg.value >= minimumContribution,
            "amount not greater than minimum"
        );

        if (contributorBalance[_contributorAddress] == 0) {
            contributorsCount++;
        }

        contributorBalance[_contributorAddress] += msg.value;
        totalContributed += msg.value;
    }

    /**
     * @notice Allows the campaign creator to create a new request for withdrawal
     * @param description The campaign description
     * @param value The amount to withdraw
     * @param recipient The address to be credited when request is granted
     */
    function createRequest(
        string memory description,
        uint256 value,
        address recipient
    ) public restricted {
        requests.push();
        Request storage newRequest = requests[numRequests++];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;

        emit RequestCreated(address(this), recipient, value, description);
    }

    /**
     * @notice Allows any contributor of a campaign to approve a request for withdrawal
     * @param index The index of the campaign request
     */
    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(contributorBalance[msg.sender] > 0, "not a contributor");
        require(!request.approvals[msg.sender], "cannot multi-approve");

        request.approvals[msg.sender] = true;
        request.approvalCount++;

        emit ApprovedRequest(
            address(this),
            campaignName,
            msg.sender,
            request.approvalCount,
            request.description
        );
    }

    /**
     * @notice Allows the campaign creator to finalize a request after it has been approved by enough contributors
     * @param index The index of the campaign request
     */
    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(
            request.approvalCount > (contributorsCount / 2),
            "not enough approvals"
        );
        require(!request.complete, "request already finalized");

        request.complete = true;

        payable(request.recipient).transfer(request.value);

        emit RequestFinalized(
            address(this),
            campaignName,
            request.recipient,
            request.approvalCount,
            request.description
        );
    }

    /**
     * @notice Allows anyone to get the summary of a campaign
     * @return minimum contribution
     * @return campaign address
     * @return totalContributed
     * @return number of requests
     * @return contributor count
     * @return time created
     * @return campaign name
     * @return creator name
     * @return campaign description
     * @return creator address
     */
    function getSummary()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            string memory,
            string memory,
            string memory,
            address
        )
    {
        return (
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
