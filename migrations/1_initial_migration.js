var Migrations = artifacts.require("./Migrations.sol");
var cdpcds = artifacts.require("./cdpcds.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(cdpcds);
};
