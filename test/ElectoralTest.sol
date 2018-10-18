pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Electoral.sol";

contract ElectoralTest {

    Electoral electoral;
    Electoral deployedElectoral;
    Process process;

    function beforeEach() public {
        electoral = new Electoral();
        mockProcessForm();
    }

    function testThatContractHasAnOwner() public {
        Assert.equal(electoral.owner(), this, "El dueño es diferente al que despliega");
    }

    function testThatAnElectoralProcessWasAddedToTheState() public {
        uint storedStart;
        uint storedEnd;
        electoral.addProcess(process.code, process.start, process.end, process.name, process.candidates);
        (storedStart, storedEnd) = electoral.getProcess(process.code);
        Assert.equal(process.start, storedStart, "El proceso electoral no existe");
        Assert.equal(process.end, storedEnd, "El proceso electoral no existe");
    }

    function testThatOwnerCanDeleteACandidate() public {
        bool isCandidate;
        electoral.addProcess(process.code, process.start, process.end, process.name, process.candidates);
        electoral.removeCandidate(process.code, process.candidates[0]);
        isCandidate = electoral.isInCandidates(process.code, process.candidates[0]);
        Assert.equal(isCandidate, false, "El candidato no fue eliminado");
    }

    function testThatAVoterCanVoteOnAnActiveProcessOnce() public {
        electoral.addProcess(process.code, process.start, process.end, process.name, process.candidates);
        uint initialVotes = electoral.getCandidateVotes(process.code, process.candidates[0]);
        electoral.vote(process.code, process.voter, process.candidates[0]);
        uint finalVotes = electoral.getCandidateVotes(process.code, process.candidates[0]);
        Assert.notEqual(initialVotes, finalVotes, "El voto no fue registrado");
    }

    function testThatOwnerCanRetrieveProcessResults() public {
        electoral.addProcess(process.code, process.start, process.end, process.name, process.candidates);
        bytes32[] memory identifications;
        uint[] memory votes;
        electoral.vote(process.code, process.voter, process.candidates[0]);
        electoral.vote(process.code, process.second_voter, process.candidates[1]);
        (identifications, votes) = electoral.getResults(process.code);
        Assert.notEqual(identifications.length, 0, "No hay votos");
        Assert.notEqual(votes.length, 0, "No hay votos");
        Assert.equal(votes[0], 1, "Hay una diferencia en los votos");
    }

    struct Process {
        bytes32 code;
        uint start;
        uint end;
        bytes32 name;
        bytes32[] candidates;
        bytes32 voter;
        bytes32 second_voter;
    }

    function mockProcessForm() private {
        process.code = "f8d8e50dfa5241a244a6aafbb79ac7dd";
        process.start = 1537382220;
        process.end = 1537900620;
        process.name = "presidenciales2019";
        process.candidates.push("123");
        process.candidates.push("321");
        process.candidates.push("345");
        process.voter = "654";
    }

}