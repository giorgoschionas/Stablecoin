//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        dsc = new DecentralizedStableCoin();
        (, , weth, wbtc, ) = config.activeNetworkConfig();
        targetContract(address(engine));
    }

    //In the DSC, we should always have more collateral than the amount of DSC tokens minted (overcollateralization)

    function invariant_proper_collateralization() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalBtcDeposited = IERC20(wbtc).balanceOf(address(engine));
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 btcValue = engine.getUsdValue(wbtc, totalBtcDeposited);

        uint256 totalCollateralValue = wethValue + btcValue;
        assert(totalCollateralValue >= totalSupply);
    }
    

}