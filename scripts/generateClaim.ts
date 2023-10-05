import MerkleTree from "merkletreejs";
import {keccak256} from "ethers/lib/utils";
import csv from "csv-parser";
import * as fs from "fs";
import {utils} from "ethers";
import path from "path";
import {Data} from "./hashData";
import {generateAirdropCSV, getPath} from "./addUserId";
import {AddressProof} from "./generateProof";

interface AirdropData {
	address: string;
	amount: number;
	airdropId: number;
}

const csvfile = path.join(__dirname, "Addresses/address.csv");

//generate an election tree given the election name and id
//will store the necessary files in a folder acccording to its name
async function generateAirdropTree(
	airdropId: number,
	airdropName: string
): Promise<void> {
	const data: Data[] = [];
	//first generate the election csv data
	const csvFile = await generateAirdropCSV(csvfile, airdropName, airdropId);

	// Read the CSV file and store the data in an array
	await new Promise((resolve, reject) => {
		fs.createReadStream(csvFile)
			.pipe(csv())
			.on("data", (row: Data) => {
				data.push(row);
			})
			.on("end", resolve)
			.on("error", reject);
	});
	let leaf: string;
	let leaves: string[] = [];
	// Hash the data using the Solidity keccak256 function
	for (const row of data) {
		leaf = utils.solidityKeccak256(
			["user_address", "uint256", "uint256"],
			[row.user_address, row.itemID, row.airdropId]
		);
		leaves.push(leaf);
	}

	// Create the Merkle tree
	const tree = new MerkleTree(leaves, keccak256, {sortPairs: true});
	const addressProofs: {[address: string]: AddressProof} = {};
	data.forEach((row, index) => {
		const proof = tree.getProof(leaves[index]);
		addressProofs[row.user_address] = {
			leaf: "0x" + leaves[index].toString(),
			proof: proof.map((p) => "0x" + p.data.toString("hex")),
		};
	});

	// Write the Merkle tree and root to a file
	await new Promise<void>((resolve, reject) => {
		fs.writeFile(
			`${getPath(csvFile)}/tree.json`,
			JSON.stringify(addressProofs),
			(err) => {
				if (err) {
					reject(err);
				} else {
					resolve();
				}
			}
		);
	});

	// Write a JSON object mapping addresses to data to a file
	const addressData: {[address: string]: Data} = {};
	data.forEach((row) => {
		addressData[row.user_address] = row;
	});

	await new Promise<void>((resolve, reject) => {
		fs.writeFile(
			`${getPath(csvFile)}/data.json`,
			JSON.stringify(addressData),
			(err) => {
				if (err) {
					reject(err);
				} else {
					resolve();
				}
			}
		);
	});
	console.log("0x" + tree.getRoot().toString("hex"));
}

generateAirdropTree(0, "Airdrop Participants").catch((error) => {
	console.error(error);
	process.exitCode = 1;
});