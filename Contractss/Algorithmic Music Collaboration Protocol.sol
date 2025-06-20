// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AlgorithmicMusicCollab {
    struct Track {
        string title;
        string ipfsHash;
        address creator;
    }

    Track[] public tracks;
    mapping(address => uint256[]) public userTracks;

    event TrackUploaded(string title, address indexed creator, string ipfsHash);
    event CollaborationInvited(address indexed from, address indexed to, uint256 trackId);
    event FeedbackProvided(uint256 trackId, string feedback);

    function uploadTrack(string calldata title, string calldata ipfsHash) external {
        tracks.push(Track(title, ipfsHash, msg.sender));
        userTracks[msg.sender].push(tracks.length - 1);
        emit TrackUploaded(title, msg.sender, ipfsHash);
    }

    function getTrack(uint256 index) public view returns (string memory, string memory, address) {
        Track memory track = tracks[index];
        return (track.title, track.ipfsHash, track.creator);
    }

    function inviteToCollaborate(address collaborator, uint256 trackId) public {
        require(trackId < tracks.length, "Invalid track ID");
        require(tracks[trackId].creator == msg.sender, "Only creator can invite");
        emit CollaborationInvited(msg.sender, collaborator, trackId);
    }

    function provideFeedback(uint256 trackId, string calldata feedback) external {
        require(trackId < tracks.length, "Invalid track ID");
        emit FeedbackProvided(trackId, feedback);
    }
}
