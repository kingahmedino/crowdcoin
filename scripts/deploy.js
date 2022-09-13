// proxy contract: 0x107F67F583580F0B6AD61125CC37901A8B08dA83
// implementation contract: 0x712d482b86e836c9f738d54bf64dd245d2430f47

const { ethers, upgrades } = require('hardhat')

async function main() {
  const CampaignFactory = await ethers.getContractFactory('CampaignFactory')
  const campaignFactory = await upgrades.deployProxy(CampaignFactory, {
    kind: 'uups',
  })

  await campaignFactory.deployed()

  console.log(`Deployed to ${campaignFactory.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
