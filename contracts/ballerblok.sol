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
	Baller[] public ballers;
	uint16 private minPay;
	Event newBaller(uint8 indexed baller, bytes32[] userName);
	Event voteCast(address indexed baller, uint8 choice);
	mapping(address => Baller) public ballerRecs;

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
		owner = msg.sender;
	}

	function setMinPay(uint16 amtwei) onlyOwner internal {
		minPay = amtwei;
	}

	function nameTaken(bytes32[] _userName) public view returns (bool) {
		for(uint8 i = 0; i < ballers.length; i++) {
			if(ballers[i].userName == _userName) {
				return true;
			}
		}
		return false;
	}

	function getBallerByAddress(address baller) public view returns (bytes32[], uint8, uint8) {
		require(ballerRecs[baller].exists == true);
		return (ballerRecs[baller].userName, ballerRecs[baller].ncaaChoice, ballerRecs[baller].nbaChoice);
	}

	function getBallerByUserName(bytes32[] _userName) public view returns (address, uint8, uint8) {
		require(nameTaken(_userName) == true);
		for(uint i = 0; i < ballers.length; i++) {
			if(baller[i].userName == _userName) {
				return (baller[i].who, baller[i].ncaachoice, baller[i].nbachoice);
			}
		}
	}

	function getTotalBallers() public view returns (uint8) {
		return ballers.length;
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
		uint8 ID = ballers.push(Baller(msg.sender, true, false, false, userName, 0, 0));
		ballerRecs[msg.sender] = ballers[ballers.length - 1];
		newBaller(ID, userName);
	}
}
