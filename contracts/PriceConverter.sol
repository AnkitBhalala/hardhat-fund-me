// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
  function getPrice(
    AggregatorV3Interface priceFeed
  ) internal view returns (uint256) {
    // ABI
    // Addres 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // AggregatorV3Interface priceFeed = AggregatorV3Interface(
    //   0x694AA1769357215DE4FAC081bf1f309aDC325306
    // );
    (, int256 price, , , ) = priceFeed.latestRoundData();
    // to match with ETH some math need to do, function retutn 8 decimal value and we ned 18 decimal
    return uint256(price * 1e10);
  }

  function getConversionRate(
    uint ethAmount,
    AggregatorV3Interface priceFeed
  ) internal view returns (uint256) {
    uint ethPrice = getPrice(priceFeed);
    return (ethPrice * ethAmount) / 1e18; // ethereum amount in USD
  }
}
