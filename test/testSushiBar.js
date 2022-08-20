const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SushiBar", function () {
  it("Should not let staker leave with sushi token if time of staking is less then 2 days", async function () {
    const Sushi = await ethers.getContractFactory("sushi");
    const sushi = await Sushi.deploy(10000000);               // deploying SushiBar contract  

    await sushi.deployed();


    console.log(
      `deployed to ${sushi.address}`
    );

    const SushiBar = await ethers.getContractFactory("SushiBar");
    const sushiBar = await SushiBar.deploy(sushi.address);         // deploying SushiBar contract


    await sushiBar.deployed();

    console.log(
      `deployed to ${sushiBar.address}`
    );

    await sushi.approve(sushiBar.address, 1000);     //giving permission to sushibar contract to use 1000 token of the user

    await sushiBar.enter(100);  // staking 100 sushi token of user in sushibar contract

    await sushiBar.leave(100);   // unstaking 100 sushi token of user 

    expect(await sushi.balanceOf(sushiBar.address)).to.equal(100);  // checking if sushiBar contract have all the sushi tokens staked by the user


    expect(await sushiBar.totalSupply()).to.equal(100);   // checking if total supply of xsushi token is equal to total staked token in starting

  });
});










