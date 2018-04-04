pragma solidity ^0.4.18;
import "https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol";

contract ballerBlok is Ownable {
	struct Baller {
		address who;
		bool exists;
		bool ncaaVote;
		bool nbaVote;
		bytes32[] userName;
		uint8 ncaaChoice;
		uint8 nbaChoice;
	}

	address private owner;
	uint16 private minPay;
	uint private ballerCount;
	Event newBaller(uint8 indexed baller, bytes32[] userName);
	Event voteCast(address indexed baller, uint8 choice);
	mapping(address => Baller) public ballerRecs;
	mapping(bytes32 => Baller) public ballerNames;

	modifier paidMin{
		require(msg.value >= minPay);
		_;
	}

	modifier onlyOwner{
		require(msg.sender == owner);
		_;
	}

	modifier hasntVotedNCAA(address baller) {
		require(ballerRecs[baller].ncaaVote == false);
		_;
	}

	modifier hasntVotedNBA(address baller) {
		require(ballerRecs[baller].nbaVote == false);
		_;
	}

	function ballerBlok(uint16 amtwei) public {
		minPay = amtwei;
		ballerCount = 0;
		owner = msg.sender;
	}

	function setMinPay(uint16 amtwei) onlyOwner internal {
		minPay = amtwei;
	}

	function nameTaken(bytes32[] _userName) public view returns (bool) {
		return (ballerNames[_userName].exists);
	}

	function getBallerByAddress(address baller) public view returns (bytes32[], uint8, uint8) {
		require(ballerRecs[baller].exists == true);
		return (ballerRecs[baller].userName, ballerRecs[baller].ncaaChoice, ballerRecs[baller].nbaChoice);
	}

	function getBallerByUserName(bytes32[] _userName) public view returns (address, uint8, uint8) {
		require(nameTaken(_userName) == true);
		return(ballerNames[_userName]);
	}

	function getTotalBallers() public view returns (uint) {
		return ballerCount;
	}

	function ncaaVote(address baller, uint8 choice) payable paidMin hasntVotedNCAA public {
		ballerRecs[baller].ncaaChoice = choice;
		ballerRecs[baller].ncaaVote = true;
		voteCast(msg.sender, choice);
		owner.transfer(msg.value);
	}

	function nbaVote(address baller, uint8 choice) payable paidMin hasntVotedNBA public {
		ballerRecs[baller].nbaChoice = choice;
		ballerRecs[baller].nbaVote = true;
		voteCast(msg.sender, choice);
		owner.transfer(msg.value);
	}

	function createBaller(bytes32[] userName) public {
		require(nameTaken(userName) == false);
		Baller baller = Baller(msg.sender, true, false, false, userName, 0, 0);
		ballerRecs[msg.sender] = baller;
		ballerNames[userName] = baller;
		ballerCount += 1;
		newBaller(ID, userName);
	}
}
