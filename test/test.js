const { expect } = require("chai");
const { constants } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Campaign", function () {
  let campaignFactoryContract;
  let owner, creator1, contributor1, contributor2, withdrawalRecipient;

  const createACampaign = () => {
    return campaignFactoryContract
      .connect(creator1)
      .createCampaign(
        "Campaign One",
        "king",
        parseEther("0.1"),
        "This is the very first campaign created from this factory"
      );
  };

  beforeEach(async () => {
    [owner, creator1, contributor1, contributor2, withdrawalRecipient] =
      await ethers.getSigners();
    const CampaignFactory = await hre.ethers.getContractFactory(
      "CampaignFactory"
    );
    campaignFactoryContract = await CampaignFactory.deploy();
    await campaignFactoryContract.initialize();
  });

  it("should create the CampaignFactory Contract", async () => {
    expect(await campaignFactoryContract.address).to.contains("0x");
  });

  it("should create a Campaign", async () => {
    await createACampaign();

    //get creator campaigns
    const campaigns = await campaignFactoryContract.getCreatorCampaigns(
      creator1.address
    );
    expect(campaigns.length).to.equal(1);
  });

  it("should create a Campaign and contribute to it", async () => {
    await createACampaign();

    //get deployed campaigns
    const deployedCampaigns =
      await campaignFactoryContract.getDeployedCampaigns();

    //contribute to a campaign
    await campaignFactoryContract
      .connect(contributor1)
      .contribute(deployedCampaigns[0], { value: parseEther("10") });

    //get contributed campaigns for contributor1
    const contributedCampaigns =
      await campaignFactoryContract.getContributedCampaigns(
        contributor1.address
      );

    expect(contributedCampaigns[0]).to.equal(deployedCampaigns[0]);
  });

  //   it("should create a Campaign, contribute to it and make a withdrawal", async () => {
  //     await createACampaign();

  //     //get deployed campaigns
  //     const deployedCampaigns =
  //       await campaignFactoryContract.getDeployedCampaigns();

  //     //contribute to a campaign
  //     await campaignFactoryContract
  //       .connect(contributor1)
  //       .contribute(deployedCampaigns[0], { value: parseEther("10") });

  //     //contribute again
  //     await campaignFactoryContract
  //       .connect(contributor2)
  //       .contribute(deployedCampaigns[0], { value: parseEther("20") });

  //     const abi = [
  //       "function createRequest(string memory description, uint256 value, address recipient) public",
  //       "function approveRequest(uint256 index) public",
  //       "function finalizeRequest(uint256 index) public",
  //       "function getSummary() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, string memory, string memory, string memory, address)",
  //     ];

  //     const campaignContract = new ethers.Contract(
  //       deployedCampaigns[0],
  //       abi,
  //       owner
  //     );

  //     await campaignContract
  //       .connect(creator1)
  //       .createRequest(
  //         "I need to buy cat food",
  //         parseEther("10"),
  //         withdrawalRecipient.address
  //       );
  //     await campaignContract.connect(contributor1).approveRequest(0);
  //     await campaignContract.connect(contributor2).approveRequest(0);
  //     await campaignContract.connect(creator1).finalizeRequest(0);

  //get requests
  // console.log(await campaignContract.requests());

  // expect(contributedCampaigns[0]).to.equal(deployedCampaigns[0]);
  //   });
});
