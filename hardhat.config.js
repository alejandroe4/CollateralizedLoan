const { HardhatUserConfig } = require("hardhat/config");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv/config");

const config = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    "sepolia-testnet": {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY].filter(Boolean),
    },
  },
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  //const accounts = await ethers.getSigners()
  const accounts = await hre.ethers.getSigners();
  const provider = hre.ethers.provider;

  //console.log(accounts);
  //await ethers.provider.getBalance
  account_balance = await hre.ethers.provider.getBalance(accounts[0].address);
  console.log(account_balance);
  account_balance = await hre.ethers.provider.getBalance(accounts[1].address);
  console.log(account_balance);
  account_balance = await hre.ethers.provider.getBalance(accounts[2].address);
  console.log(account_balance);
  //ether_balance = hre.ethers.utils.formatEther(account_balance.toString())
  //ether_balance = hre.ethers.utils.formatEther(await hre.ethers.provider.getBalance(accounts[0].address));
  //console.log(ether_balance);
  /*
  for (const account of accounts) {
      console.log(
          "%s (%i ETH)",
          account.address,
          hre.ethers.utils.formatEther(
              // getBalance returns wei amount, format to ETH amount
              await provider.getBalance(account.address)
          )
      );
  }*/
});

module.exports = config;
