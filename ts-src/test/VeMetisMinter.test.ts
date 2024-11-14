import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";

describe("VeMetisMinter", function () {
  let deployer: any;
  let Metis: any;
  let VeMetis: any;
  let VeMetisMinter: any;

  // Deployed Contract Addresses
  const METIS_ADDRESS = "0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000";
  const VEMETIS_MINTER_ADDRESS = "0x82c6D49F563D87F8D95bDd7350174d0314401B18";
  const VEMETIS_ADDRESS = "0xc467683d79CEa75abF3C9181BbEcaA20B6d5aED1";
  let MetisUser: any;
  let VeMetisMinterUser: any;

  beforeEach(async function () {
    // Get signers
    [deployer] = await ethers.getSigners();
    // deployer = deployer.address;

    // Connect to the already deployed Metis ERC20 contract
    Metis = await ethers.getContractAt("IERC20", METIS_ADDRESS, deployer);

    // Connect to the already deployed VeMetis contract
    VeMetis = await ethers.getContractAt("IVeMetis", VEMETIS_ADDRESS, deployer);

    // Connect to the already deployed VeMetisMinter contract
    VeMetisMinter = await ethers.getContractAt(
      "IVeMetisMinter",
      VEMETIS_MINTER_ADDRESS,
      deployer
    );

    // Connect contracts to user
    MetisUser = Metis.connect(deployer);
    VeMetisMinterUser = VeMetisMinter.connect(deployer);
  });

  /**
   * Utility function to log gas used by a transaction
   * @param tx Promise returned by a contract method
   * @param action Description of the action being performed
   */
  async function logGasUsed(tx: Promise<any>, action: string) {
    const transaction = await tx;
    const receipt = await transaction.wait();
    console.log(`${action} Gas Used:`, receipt.gasUsed.toString());
    return receipt.gasUsed;
  }

  describe("user flow", function () {
    it("should allow a user to approve Metis, mint VeMetis, and bridge to L1", async function () {
      // Set up the amounts
      const mintAmount = ethers.parseEther("0.2");
      const bridgeAmount = ethers.parseEther("0.1");

      const veMetisMinterMetisBalanceBefore = await Metis.balanceOf(
        VEMETIS_MINTER_ADDRESS
      );

      // Step 1: User approves VeMetisMinter to spend Metis
      const approveTx = await MetisUser.approve(
        VEMETIS_MINTER_ADDRESS,
        mintAmount
      );
      await approveTx.wait(1);
      const allowance = await Metis.allowance(deployer, VEMETIS_MINTER_ADDRESS);
      expect(allowance).to.be.at.least(mintAmount);

      // Step 2: User calls mint on VeMetisMinter
      const mintTx = await VeMetisMinterUser.mint(deployer, mintAmount);
      await mintTx.wait(1);

      // Step 3: User calls depositToL1Dealer to bridge Metis
      const bridgeFee = ethers.parseEther("0.000000000001"); 
      const depositTx = await VeMetisMinterUser.depositToL1Dealer(
        bridgeAmount,
        { value: bridgeFee }
      );
      await logGasUsed(depositTx, "Deposit to L1 Dealer");
      await depositTx.wait(1);

      // Verify Metis balance in VeMetisMinter decreased
      const veMetisMinterMetisBalance = await Metis.balanceOf(
        VEMETIS_MINTER_ADDRESS
      );
      expect(veMetisMinterMetisBalance).to.equal(
        veMetisMinterMetisBalanceBefore - bridgeAmount
      );
    });
  });
});
