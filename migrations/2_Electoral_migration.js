var Migrations = artifacts.require("./Electoral.sol");

module.exports = function(deployer) {
    deployer.deploy(Migrations);
};
