import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { Dummy, Relayer } from "../typechain-types";

describe("Relayer", () => {
  let relayer: Relayer;
  let dummy: Dummy;
  let txSigner: Signer;

  beforeEach(async () => {
    // Get signers and set up initial contracts
    const signers = await ethers.getSigners();
    txSigner = signers[1];

    // Deploy contracts
    const Relayer = await ethers.getContractFactory("Relayer");
    const Dummy = await ethers.getContractFactory("Dummy");

    relayer = await Relayer.deploy();
    dummy = await Dummy.deploy();
  });

  it("should relay a signed message to update and emit the number", async () => {
    const number = 100;

    // Get nonce for the transaction signer
    const nonce = await ethers.provider.getTransactionCount(await txSigner.getAddress()) + 1;

    console.log("Nonce ", nonce)
    // Prepare function data to be called on the Dummy contract
    const functionData = dummy.interface.encodeFunctionData("updateAndEmitNumber", [number]);
    console.log("Encoded function data:", functionData);

    // Compute the message hash
    const message = await relayer.getMessageHash(
      dummy ,
      await txSigner.getAddress(),
      functionData,
      nonce
    );
    console.log("Message hash:", message);

    // Sign the message
    const signature = await txSigner.signMessage(ethers.toBeArray(message));
    console.log("Signed message:", signature);

    await relayer.giveTargetPermission(dummy);
    // Relay the message through the Relayer contract
    const tx = await relayer.send({
        from: txSigner,
        to: dummy,
        data: functionData,
        nonce: nonce,
        deadline: (await ethers.provider.getBlock('latest'))!.timestamp + 100
      }, signature);

    await tx.wait();

    // Assertions to validate the result
    const storedNumber = await dummy.lastNumber();
    expect(storedNumber).to.equal(number);
    console.log("stored: ", storedNumber)
    const emittedEvent = await dummy.queryFilter(dummy.filters.NumberReceived());
    expect(emittedEvent.length).to.be.greaterThan(0);
    expect(emittedEvent[0].args?.[0]).to.equal(number);
  });
});
