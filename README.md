<a name="readme-top"></a>

<div align="center">
  <h3 align="center">Crowdoin</h3>

  <p align="center">
    Crowdcoin are a set of contracts that facilitate decentralized crowdfunding.
    <br />
    <br />
    <a href="https://github.com/kingahmedino/crowdcoin">View Demo</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]]()

Crowdcoin is a crowdfunding platform that allows you to get funding easily using crypto. Crowdcoin is different from other crowdfunding sites because it's decentralized, meaning that there's no central authority or bank account keeping track of funds. This means that you don't have to pay fees or wait for your money to be transferred across the world. Crowdcoin is also more secure than other platforms because it uses smart contracts and blockchain technology.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

#### Back
* Solidity
* Ethereum
* Hardhat
* Openzeppelin Contracts
* Ethers.js
#### Front
* NextJS
* ReactJS
#### Testing
* Chai
* Mocha

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/kingahmedino/crowdcoin.git && cd crowdcoin
   ```
2. Install dependencies
   ```sh
   yarn install
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

Try running some hardhat tests:

```sh
npx hardhat test
```

Try to deploy contract to testnet, Gõerli is the default:

```sh
npx hardhat run scripts/deploy.js
```
or

Edit `hardhat.config.js` to add more networks to deploy to:

```javascript
networks: {
    goerli: {
      url: process.env.NETWORK,
      accounts: [process.env.PRIVATE_KEY],
    },
  }
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[product-screenshot]: images/screenshot.png
