//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract DSCEngineTest is Test {
    DecentralizedStableCoin dsc;
    DeployDSC deployer;
    DSCEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        // dsc = new DecentralizedStableCoin();
        (ethUsdPriceFeed, , weth, ,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_USER_BALANCE);


    }


    /////////////////////////////// 
    /////// Price Tests ///////////
    //////////////////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);
        assertEq(actualUsd, expectedUsd);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 amountWeth = engine.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(amountWeth, expectedWeth);
    }


    /////////////////////////////// 
    /////// depositCollateral Tests ///////////
    //////////////////////////////


    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertIfTokenIsNotAllowed() public {
        ERC20Mock newToken = new ERC20Mock("New", "New", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__TokenNotAllowed.selector, address(newToken)));
        engine.depositCollateral(address(newToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

        modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositedCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 expectedDepositedAmount = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted,0);
        assertEq(AMOUNT_COLLATERAL, expectedDepositedAmount);
    }
}