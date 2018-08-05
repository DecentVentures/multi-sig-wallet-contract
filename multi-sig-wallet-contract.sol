pragma solidity ^0.4.21;


contract MultiSigWallet {

  struct Proposal {
    address to;
    uint amount;
    mapping(address => bool) signed;
    bool finalized;
  }

  uint signersRequired;
  address[] public signers;
  Proposal[] public proposals;
  mapping(address => bool) public canSign;

  constructor(address[] initSigners, uint m) public {
    if(m == 0) {
      signersRequired = initSigners.length;
    } else {
      signersRequired = m;
    }
    signers = initSigners;
    for(uint i = 0; i < initSigners.length; i++) {
      canSign[initSigners[i]] = true;
    }
  }

  function () public payable {

  }

  function balance() public view returns(uint) {
    return address(this).balance;
  }


  modifier isSigner(address user) {
    require(canSign[user] == true);
    _;
  }
  function submitProposal(uint amount, address to)  isSigner(msg.sender) public {
    proposals.push(Proposal({
      to: to,
      amount: amount,
      finalized: false
    }));
  }

  modifier proposalExists(uint index) {
    require(index >= 0);
    require(index < proposals.length);
    _;
  }
  function sign(uint proposalIndex)  isSigner(msg.sender) proposalExists(proposalIndex) public {
    proposals[proposalIndex].signed[msg.sender] = true;
  }

  function signerRequirementsMet(uint index) proposalExists(index) public view returns(bool) {
    uint signedCount = 0;
    for(uint i = 0; i < signers.length; i++) {
      if(proposals[index].signed[signers[i]]){
        signedCount++;
      }
    }
    return signedCount >= signersRequired;
  }

  modifier isFullySigned(uint index) {
    require(signerRequirementsMet(index));
    _;
  }

  function finalizeProposal(uint index) isFullySigned(index) isSigner(msg.sender) public  {
    require(address(this).balance >= proposals[index].amount);
    require(proposals[index].finalized == false);
    proposals[index].finalized = true;
    proposals[index].to.transfer(proposals[index].amount);
  }


}
