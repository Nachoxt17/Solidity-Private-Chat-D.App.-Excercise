# Solidity-Private-Chat-D.App.

- Users can Connect their Wallets and Send Private Messages to Each Other, and additionally send Random Cat Facts Messages.
  PLEASE READ "TestAnswers.txt".

## For Testing the Successful S.C. DEMO Deployed in the Kovan Ethereum TestNet:

(In Real Life, this would be Deployed to the Polygon MainNet)
Smart Contract deployed with the account: ------------------
https://kovan.etherscan.io/address/------------------

-NOTE:\_ The Smart Contract of this Test is not Deployed because as TestNets is regarded,
ChainLink(The Service used to GET the Data from the A.P.I. to the Smart Contract) supports only the
Kovan Ethereum TestNet and Alchemy(The Service used to Deploy Smart Contracts) doesn't supports it,
since they deprecated it and only use the Goerli Ethereum TestNet.

-You can get Kovan Test Ether and Test LINK Here:
https://faucets.chain.link/kovan

-You can get Mumbai Test Matic Here:
https://faucet.polygon.technology

## Quick Project start:

:one: The first things you need to do are cloning this repository and installing its
dependencies:

```sh
npm install
```

## Setup

:two: Copy and Paste the File ".env.example" inside the same Root Folder(You will Duplicate It) and then rename it removing the part of ".example" so that it looks like ".env" and then fill all the Data Needed Inside the File. In the part of "ALCHEMY_API_KEY"
just write the KEY, not the whole URL.

```sh
cp .env.example .env && nano .env
```

:three: Open a Terminal and let's Test your Project in a Hardhat Local Node. You can also Clone the Polygon Main Network in your Local Hardhat Node:
https://hardhat.org/guides/mainnet-forking.html

```sh
npx hardhat node
```

:four: Now Open a 2nd Terminal and Deploy your Project in the Hardhat Local Node. You can also Test it in the same Terminal:

```sh
npx hardhat test
```

## Deploying the Project to the Kovan Ethereum TestNet:

:five: Deploy the Smart Contract to the Kovan Ethereum TestNet Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):

```sh
npx hardhat run scripts/deploy.js --network kovan
```

## Deploying the Project to the Polygon MainNet:

:six: Deploy the Smart Contract to the Polygon Main Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):

```sh
npx hardhat run scripts/deploy.js --network polygon
```

:seven: To Interact with the Deployed S.C. you need to run contract-interact.js:

```sh
node scripts/contract-interact.js
```

:eight: Verify your smart contract on PolygonScan:

```sh
npx hardhat verify --network mumbai DEPLOYED_SMART_CONTRACT_ADDRESS_MUMBAI 'Hello World!'
```

## User Guide:

You can find detailed instructions on using this repository and many tips in [its documentation](https://hardhat.org/tutorial).

- [Setting up the environment](https://hardhat.org/tutorial/setting-up-the-environment.html)
- [Testing with Hardhat, Mocha and Waffle](https://hardhat.org/tutorial/testing-contracts.html)
- [Hardhat's full documentation](https://hardhat.org/getting-started/)

For a complete introduction to Hardhat, refer to [this guide](https://hardhat.org/getting-started/#overview).
