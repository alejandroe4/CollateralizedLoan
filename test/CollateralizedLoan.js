// Importing necessary modules and functions from Hardhat and Chai for testing
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

// Describing a test suite for the CollateralizedLoan contract
describe("CollateralizedLoan", function () {
  // A fixture to deploy the contract before each test. This helps in reducing code repetition.
  async function deployCollateralizedLoanFixture() {
    // Deploying the CollateralizedLoan contract and returning necessary variables
    // TODO: Complete the deployment setup
    const[publisher, lender, borrower] = await ethers.getSigners();
    const CLoan = await ethers.getContractFactory("CollateralizedLoan");
    const myCLoan = await CLoan.deploy();
    return {myCLoan, publisher, lender, borrower};
  }

  // Test suite for the loan request functionality
  describe("Loan Request", function () {
    it("Should let a borrower deposit collateral and request a loan", async function () {
      // Loading the fixture
      // TODO: Set up test for depositing collateral and requesting a loan
      // HINT: Use .connect() to simulate actions from different accounts
      const {myCLoan,publisher, lender, borrower} = await loadFixture(deployCollateralizedLoanFixture);
      await myCLoan.connect(borrower).depositCollateralAndRequestLoan( 10,10, {value:ethers.parseEther("10")});
      
    });
  });

  // Test suite for funding a loan
  describe("Funding a Loan", function () {
    it("Allows a lender to fund a requested loan", async function () {
      // Loading the fixture
      // TODO: Set up test for a lender funding a loan
      // HINT: You'll need to check for an event emission to verify the action
      const {myCLoan,publisher, lender, borrower} = await loadFixture(deployCollateralizedLoanFixture);
      
      await myCLoan.connect(borrower).depositCollateralAndRequestLoan(5,15, {value:ethers.parseEther("1")});
      
      await myCLoan.connect(lender).fundLoan(1,{value:ethers.parseEther("0.8")});
          
      

    });
  });

  // Test suite for repaying a loan
  describe("Repaying a Loan", function () {
    it("Enables the borrower to repay the loan fully", async function () {
      // Loading the fixture
      // TODO: Set up test for a borrower repaying the loan
      // HINT: Consider including the calculation of the repayment amount
      const {myCLoan,publisher, lender, borrower} = await loadFixture(deployCollateralizedLoanFixture);
      await myCLoan.connect(borrower).depositCollateralAndRequestLoan(5,15, {value:ethers.parseEther("1")});
      await myCLoan.connect(lender).fundLoan(1,{value:ethers.parseEther("0.8")});
      await myCLoan.connect(borrower).repayLoan(1, {value:ethers.parseEther("0.84")});
      
    });
  });

  // Test suite for claiming collateral
  describe("Claiming Collateral", function () {
    it("Permits the lender to claim collateral if the loan isn't repaid on time", async function () {
      // Loading the fixture
      // TODO: Set up test for claiming collateral
      // HINT: Simulate the passage of time if necessary
      const {myCLoan,publisher, lender, borrower} = await loadFixture(deployCollateralizedLoanFixture);
      await myCLoan.connect(borrower).depositCollateralAndRequestLoan(5,0, {value:ethers.parseEther("1")});
      await myCLoan.connect(lender).fundLoan(1,{value:ethers.parseEther("0.8")});
      await myCLoan.connect(lender).fnClaimCollateral(1);
    });
  });
});
