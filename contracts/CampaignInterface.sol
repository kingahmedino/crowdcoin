// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface CampaignInterface {
    function contribute(address _contributorAddress) external payable;
}