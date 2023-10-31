const { network, ethers } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(chainId)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  log("----------------------------------------------------");
  log("Deploying FundMe and waiting for confirmations...");
  const fundMeDeployment = await deploy("FundMe", {
    contract: "FundMe",
    from: deployer,
    args: [ethUsdPriceFeedAddress],
    log: true,
    // we need to wait if on a live network so we can verify properly
    // waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`FundMe deployed at ${fundMeDeployment.address}`);
  log("----------------------------------------------------");

  // When you use await deploy("FundMe", ...);,
  // it deploys the contract and then logs information about the deployment,
  // but the return value of deploy is not the deployed contract instance.
  // Instead, it's an object containing information about the deployment.

  // To get the deployed contract instance, you can do the following:

  // const fundMeInstance = await ethers.getContractAt(
  //   "FundMe",
  //   fundMeDeployment.address
  // );
  // console.log(`FundMe deployed at ${fundMeInstance.address}`);
  // let usd = await fundMeInstance.MINIMUM_USD();
  // console.log(usd.toString());
  // await fundMeInstance.fund({ value: ethers.utils.parseEther("0.1") });

  if (!developmentChains.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    await verify(fundMeDeployment.address, [ethUsdPriceFeedAddress]);
  }
};

module.exports.tags = ["all", "fundme"];

// 0x81959Db160DA6466e041404A0DC253f2b648885b => here it is a address where last time deployed on sepolia test net gas=852229
// if it fail sometime then run deployment with --gasprice 1300000000000 flag
// 0x4C6c436F2e3BA1a2b9cA24273aC1d9bf80e3C42E => verify not submitting need to see on that => Done => Working fine now
