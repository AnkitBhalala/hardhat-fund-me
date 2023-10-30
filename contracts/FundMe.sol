// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

/**
 * @title A contract for crowd funding
 * @author Ankit Bhalala
 * @notice This contract is to demo of a sample funding contract
 * @dev This implements price feeds as our library
 */

contract FundMe {
  // Type Declaration
  using PriceConverter for uint256;

  // State Variable
  uint public constant MINIMUM_USD = 50 * 1e18;
  address[] private s_funders;
  mapping(address => uint) private s_addressToAmountFunded;
  address private immutable i_owner;
  AggregatorV3Interface private s_priceFeed;

  modifier OnlyOwner() {
    require(msg.sender == i_owner, "sender is not a owner!");
    _;
  }

  // Functions Order:
  //// constructor
  //// receive
  //// fallback
  //// external
  //// public
  //// internal
  //// private
  //// view / pure

  constructor(address s_priceFeedAddress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }

  function fund() public payable {
    require(
      msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
      "Did't send enough"
    );
    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] += msg.value;
  }

  function withdraw() public OnlyOwner {
    for (uint256 index; index < s_funders.length; index++) {
      address funder = s_funders[index];
      s_addressToAmountFunded[funder] = 0;
    }
    // reset the array
    s_funders = new address[](0);

    // actually withdrow the fund

    // transfer
    // payable (msg.sender).transfer(address(this).balance);

    // send
    // bool sendSuccess = payable (msg.sender).send(address(this).balance);
    // require(sendSuccess, "send faild");

    // call
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "call faild");
  }

  function getFunders(uint index) public view returns (address) {
    return s_funders[index];
  }

  function getAddressToAmountFunded(
    address fundingAddress
  ) public view returns (uint) {
    return s_addressToAmountFunded[fundingAddress];
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}
