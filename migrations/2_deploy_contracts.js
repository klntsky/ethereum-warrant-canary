var Canary = artifacts.require("./Canary.sol");

module.exports = function(deployer) {
  deployer.deploy(Canary);
};
