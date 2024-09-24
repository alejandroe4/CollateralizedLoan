// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Collateralized Loan Contract
contract CollateralizedLoan {
    // Define the structure of a loan
    struct Loan {
        uint id;
        address borrower;   //el que recibe. who must repay the amount borrowed, plus the interest agreed upon in the contract
        // Hint: Add a field for the lender's address
        address payable lender;      //el que presta
        uint collateralAmount;  //Monto de garantia
        // Hint: Add fields for loan amount, interest rate, due date, isFunded, isRepaid
        uint loanAmout;
        uint returnAmount;
        uint interestRate;
        uint dueDate;
        bool isFunded;
        bool isRepaid;        
    }

    // Create a mapping to manage the loans
    mapping(uint => Loan) public loans;
    uint public nextLoanId;

    // Hint: Define events for loan requested, funded, repaid, and collateral claimed
    //Allow users to deposit ETH as collateral and request a loan.
    //emit loanRequested(nextLoanId, myLoanAmount, _interestRate, _duration, msg.sender, address(0));
    event loanRequested(uint indexed itemId, uint loanAmount, uint interestRate, uint duration, address borrower, address lender );
    //Enable other users to fund those loans and earn interest
    event funded(uint indexed itemId, address indexed lender, uint fundAmount );
    //Provide functionality for borrowers to repay loans with interest
    event repaid(uint indexed itemId, address indexed borrower);
    //Permit lenders to claim collateral if the borrower defaults
    event collateralClaimed(uint itemId);

    // Custom Modifiers
    // Hint: Write a modifier to check if a loan exists
    modifier loanExist(uint loanId) {        
        require(loans[loanId].loanAmout > 0 , "The loan doesnt exist.");
        _;
    }
    // Hint: Write a modifier to ensure a loan is not already funded
    modifier loanFunded(uint loanId) {        
        Loan storage loan = loans[loanId];
        require(!loan.isFunded, "The loan is already funded");
        _;
    }

    // Function to deposit collateral and request a loan
    //Borrowers deposit ETH as collateral. The contract records the loan request and gives the collateral as the loan amount.
    //duration:   2629743 sec is 1 month, 604800 sec is 1 week, 86400 sec is 1 day, 3600 sec is 1 hour
    function depositCollateralAndRequestLoan(uint _interestRate, uint _duration) external payable {
        // Hint: Check if the collateral is more than 0
        require(msg.value > 0, "collateral must be greater than 0");
        
        //if a bank provides an $800,000 loan in order to purchase a house with a collateral value of $1 million, then its LTV ratio would be 80%.
        // Hint: Calculate the loan amount based on the collateralized amount
        uint myLoanAmount = msg.value * 80/100;
        uint myReturnAmount = myLoanAmount + (myLoanAmount * _interestRate/100);
        
        // Hint: Increment nextLoanId and create a new loan in the loans mapping
        nextLoanId++;
        loans[nextLoanId] = Loan({
            id : nextLoanId,
            lender: payable(address(0)),
            borrower: msg.sender,
            collateralAmount: msg.value,    //How much 
            loanAmout: myLoanAmount,        //amount to lend
            returnAmount: myReturnAmount,   //amount to return
            interestRate: _interestRate, 
            dueDate:  block.timestamp + _duration,
            isFunded: false,
            isRepaid: false
        });
        // Hint: Emit an event for loan request
        emit loanRequested(nextLoanId, myLoanAmount, _interestRate, _duration, msg.sender, address(0));
    }

    // Function to fund a loan
    // Hint: Write the fundLoan function with necessary checks and logic
    //Lenders fund the loan by sending the loan amount in ETH to the contract.
    //The contract records the lender's address and marks the loan as funded.
    function fundLoan(uint loanId) external payable loanExist(loanId) loanFunded(loanId){
        Loan storage loan = loans[loanId];
        //require(!loan.isFunded,"Loan is already funded");
        require(msg.sender != loan.borrower, "borrower cant be the same as lender");
        require(msg.value == loan.loanAmout, "not enough amount");
        
        
        address payable _to = payable(this);
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        
        loan.lender = payable(msg.sender);
        loan.isFunded = true;

        //address(msg.sender).transfer(msg.value);           
        //payable(address(this)).transfer(msg.value);
        emit funded(loanId,msg.sender, msg.value);
    }


    // Function to repay a loan
    //Borrowers repay the loan with interest before the due date.
    //Upon successful repayment, the contract returns the collateral to the borrower.
    // Hint: Write the repayLoan function with necessary checks and logic
    function repayLoan(uint loanId) external payable loanExist(loanId) {
        Loan storage loan = loans[loanId];
        require(msg.value == loan.returnAmount, "The amount is not the correct" );
        require(block.timestamp <= loan.dueDate, "The dueDate expire");
                
        //Pay to the lender
        address payable _to = payable(loans[loanId].lender);
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether to lender");

        loan.isRepaid = true;

        //send back the collateral to the borrower
        _to = payable(loans[loanId].borrower);
        (sent, data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether to borrower");

        emit repaid(loanId,msg.sender);
    }

    // Function to claim collateral on default
    //If the borrower fails to repay the loan on time, the lender can claim the deposited collateral.
    //The contract transfers the collateral to the lender after the due date passes without repayment.
    // Hint: Write the claimCollateral function with necessary checks and logic
    function fnClaimCollateral(uint loanId) external payable{
        Loan storage loan = loans[loanId];
        require(block.timestamp > loan.dueDate, "The dueDate doesnt expire yet");
        require(!loan.isRepaid, "The loan was paid");
        //Pay to the lender
        address payable _to = payable(loan.lender);
        (bool sent, bytes memory data) = _to.call{value: loan.collateralAmount}("");
        require(sent, "Failed to send Ether to lender");

        loan.collateralAmount = 0;
        loan.lender = payable(address(0));
        emit collateralClaimed(loanId);
    }

    // Getter smart contract Balance
    function getSmartContractBalance() external view returns(uint) {
        return address(this).balance;
    }


    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function withdrawLoan(uint loanId) payable public loanFunded(loanId)  {
        Loan storage loan = loans[loanId];
	    require(msg.sender == loan.borrower);
	    //payable(msg.sender).transfer(address(this).balance);
        payable(msg.sender).transfer(loan.loanAmout);
    }
    
}