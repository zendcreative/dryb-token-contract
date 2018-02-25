var DrybToken = artifacts.require("./DrybToken.sol");

module.exports = function(deployer) {
  deployer.deploy(DrybToken);
};
