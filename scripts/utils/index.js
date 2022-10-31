const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const { write } = require("./io");
const AddressesJSON = require("../addresses.json");

const hashStringAddress = (address) =>
  keccak256(Buffer.from(address.substring(2), "hex"));

const getProof = (tree, address) =>
  tree.getHexProof(hashStringAddress(address));

const generateMerkleTree = (addresses) => {
  const leaves = addresses.map((v) => hashStringAddress(v));
  return new MerkleTree(leaves, keccak256, { sort: true });
};

const generateTree = () => {
  // const addresses = JSON.parse(AddressesJSON);
  const addresses = AddressesJSON;

  const merkleTree = generateMerkleTree(addresses);
  const merkleRoot = merkleTree.getHexRoot();
  const merkleProof = [];
  for (const address of addresses) {
    merkleProof.push({
      address,
      proofs: getProof(merkleTree, address).join(","),
    });
  }

  write({
    root: merkleRoot,
    proofs: merkleProof,
  });
};

module.exports = {
  hashStringAddress,
  getProof,
  generateMerkleTree,
  generateTree,
};
