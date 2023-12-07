// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import { Donation } from "../src/Donation.sol";
import { MockUSDT } from "./mocks/MockUSDT.sol";

import "forge-std/console.sol";

contract DonationTest is Test {

    event NextOwnerUpdated(address nextOwner);
    event OwnerChanged(address newOwner);

    Donation public donationContract;
    MockUSDT public usdt;

    address owner = mkaddr("owner");
    address nextOwner = mkaddr("nextOwner");

    // address owner = address(0x123);

    function setUp() public {
        vm.startPrank(owner);
            donationContract = new Donation();
            usdt = new MockUSDT();
        vm.stopPrank();
    }

    function test_donation() public {
        vm.startPrank(owner);
            uint256 amount = 10e18;
            uint256 userInitialUsdtBalance = usdt.balanceOf(owner);

            usdt.approve(address(donationContract), amount);

            donationContract.donate(address(usdt), amount);

            assertEq(usdt.balanceOf(address(donationContract)), amount);
            assertEq(usdt.balanceOf(owner), userInitialUsdtBalance - amount);
        vm.stopPrank();
    }

    function test_withdrawal() public {
        vm.startPrank(owner);
            uint256 amount = 10e18;
            uint256 userInitialUsdtBalance = usdt.balanceOf(owner);

            usdt.approve(address(donationContract), amount);

            donationContract.donate(address(usdt), amount);

            assertEq(usdt.balanceOf(address(donationContract)), amount);
            assertEq(usdt.balanceOf(owner), userInitialUsdtBalance - amount);

            uint256 userBalanceAfterDonation = usdt.balanceOf(owner);

            // Start withdrawal
            donationContract.withdraw(address(usdt));

            assertEq(usdt.balanceOf(owner), userBalanceAfterDonation + amount);
        vm.stopPrank();
    }

    function test_onlyOwner_revert() public {
        vm.startPrank(owner);
            uint256 amount = 10e18;
            uint256 userInitialUsdtBalance = usdt.balanceOf(owner);

            usdt.approve(address(donationContract), amount);

            donationContract.donate(address(usdt), amount);

            assertEq(usdt.balanceOf(address(donationContract)), amount);
            assertEq(usdt.balanceOf(owner), userInitialUsdtBalance - amount);
        vm.stopPrank();

        vm.startPrank(nextOwner);
            vm.expectRevert(bytes("not owner"));
            // Start withdrawal
            donationContract.withdraw(address(usdt));
        vm.stopPrank();
        
    }

    function test_setNextOwner() public {
        vm.startPrank(owner);
            vm.expectEmit(true, false, false, true);
            emit NextOwnerUpdated(nextOwner);
            donationContract.setNextOwner(nextOwner);
        vm.stopPrank();
    }

    function test_acceptOwnership() public {
        vm.startPrank(owner);
            vm.expectEmit(true, false, false, true);
            emit NextOwnerUpdated(nextOwner);
            donationContract.setNextOwner(nextOwner);
        vm.stopPrank();

        vm.startPrank(nextOwner);
            vm.expectEmit(true, false, false, true);
            emit OwnerChanged(nextOwner);
            donationContract.acceptOwnership();

            address newOwner = donationContract.owner();
            assertEq(newOwner, nextOwner);
        vm.stopPrank();
    }

    function test_showContractBalance() public {
        vm.startPrank(owner);
            uint256 amount = 10e18;

            usdt.approve(address(donationContract), amount);

            donationContract.donate(address(usdt), amount);

            uint256 contractBalance = donationContract.showContractBalance(address(usdt));

            assertEq(contractBalance, amount);
        vm.startPrank(owner);
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        vm.label(addr, name);
        return addr;
    }

    // Fuzz Testing
    // function test_donation_fuzz(uint16 amount) public {
    //     usdt.approve(address(donationContract), amount);

    //     donationContract.donate(address(usdt), amount);

    //     assertEq(usdt.balanceOf(address(donationContract)), amount);
    // }
}
