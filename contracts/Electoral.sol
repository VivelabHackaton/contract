pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract Electoral is Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    mapping (bytes32 => Process) private ElectoralProcess;

    struct Process {
        uint start;
        uint end;
        bytes32 name;
        bytes32[] candidateKeys;
        mapping(bytes32 => Candidate) candidates;
        mapping(bytes32 => Voter) voters;
    }

    struct Candidate {
        bool isCandidate;
        uint votesCounter;
    }

    struct Voter {
        bool hasVoted;
    }

    function addProcess(bytes32 _code, uint _start, uint _end, bytes32 _name, bytes32[] _candidates) public onlyOwner {
        ElectoralProcess[_code] = Process({ start: _start, end: _end, name: _name, candidateKeys: _candidates });
        for(uint i=0; i<_candidates.length; i++) {
            ElectoralProcess[_code].candidates[_candidates[i]] = Candidate({isCandidate: true, votesCounter: 0});
        }
    }

    function getProcess(bytes32 _code) public view returns (uint, uint) {
        Process memory process = ElectoralProcess[_code];
        return (process.start, process.end);
    }

    function removeCandidate(bytes32 _code, bytes32 _candidateId) public onlyOwner {
        delete ElectoralProcess[_code].candidates[_candidateId];
        for (uint i=0; i<ElectoralProcess[_code].candidateKeys.length; i++) {
            if(ElectoralProcess[_code].candidateKeys[i] == _candidateId) {
                delete ElectoralProcess[_code].candidateKeys[i];
            }
        }
    }

    function isInCandidates(bytes32 _code, bytes32 _candidateId) public view returns(bool) {
        return  ElectoralProcess[_code].candidates[_candidateId].isCandidate;
    }

    function vote(bytes32 _code, bytes32 voter, bytes32 _candidateId) public {
        require(ElectoralProcess[_code].voters[voter].hasVoted != true);
        ElectoralProcess[_code].voters[voter] = Voter({hasVoted: true});
        ElectoralProcess[_code].candidates[_candidateId].votesCounter++;
    }

    function getCandidateVotes(bytes32 _code, bytes32 _candidateId) public onlyOwner view returns (uint) {
        return ElectoralProcess[_code].candidates[_candidateId].votesCounter;
    }

}