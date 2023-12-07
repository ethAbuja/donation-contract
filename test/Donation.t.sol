// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { Donation } from "../src/Donation.sol";
import { MockUSDT } from "./mocks/MockUSDT.sol";

contract DonationTest is Test {
    Donation public donationContract;
    MockUSDT public usdt;

    function setUp() public {
        donationContract = new Donation();
        usdt = new MockUSDT();
    }

    function test_donation() public {
        uint256 amount = 10e18;

        usdt.approve(address(donationContract), amount);

        donation.donate(address(usdt), amount);

        assertEq(usdt.balanceOf(address(donationContract)), amount);
    }

    // function test_donation_fuzz(uint256 amount) public {
    //     usdt.approve(address(donationContract), amount);

    //     donation.donate(address(usdt), amount);

    //     assertEq(usdt.balanceOf(address(donationContract)), amount);
    // }
}
