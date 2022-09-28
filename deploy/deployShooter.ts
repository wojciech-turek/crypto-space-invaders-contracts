// deploy with hardhat-deply

import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;

  const deployer = (await getUnnamedAccounts())[0];

  const shooter = await deploy("CryptoSpaceInvaders", {
    from: deployer,
    args: [],
    log: true,
  });

  if (shooter.newlyDeployed) {
    console.log("Contract deployed at: ", shooter.address);
  }
};

export default func;
func.tags = ["CryptoSpaceInvaders"];
func.dependencies = ["PolygonToken"];
