// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Quantum Entanglement Simulation Economy
 * @dev A blockchain-based simulation of quantum entanglement mechanics
 */
contract Project {

    address public owner;

    struct QuantumParticle {
        uint256 id;
        address owner;
        uint8 spinState; // 0 = down, 1 = up, 2 = superposition
        uint256 entanglementId;
        bool isEntangled;
        uint256 creationTime;
        uint256 lastMeasurement;
    }

    struct EntanglementPair {
        uint256 id;
        uint256 particle1Id;
        uint256 particle2Id;
        address creator;
        uint256 creationTime;
        uint256 totalMeasurements;
        bool isActive;
    }

    mapping(uint256 => QuantumParticle) public particles;
    mapping(uint256 => EntanglementPair) public entanglementPairs;
    mapping(address => uint256[]) public userParticles;
    mapping(address => uint256) public quantumTokens;

    uint256 public particleCounter;
    uint256 public entanglementCounter;
    uint256 public constant CREATION_COST = 10;
    uint256 public constant ENTANGLEMENT_REWARD = 50;
    uint256 public constant MEASUREMENT_REWARD = 5;

    event ParticleCreated(uint256 indexed particleId, address indexed owner);
    event ParticlesEntangled(uint256 indexed entanglementId, uint256 particle1Id, uint256 particle2Id);
    event ParticleMeasured(uint256 indexed particleId, uint8 newState, uint256 reward);
    event EntanglementBroken(uint256 indexed entanglementId, string reason);

    constructor() {
        owner = msg.sender;
        particleCounter = 0;
        entanglementCounter = 0;
    }

    function createQuantumParticle() external returns (uint256) {
        require(quantumTokens[msg.sender] >= CREATION_COST, "Insufficient quantum tokens");

        particleCounter++;
        uint256 newParticleId = particleCounter;

        particles[newParticleId] = QuantumParticle({
            id: newParticleId,
            owner: msg.sender,
            spinState: 2,
            entanglementId: 0,
            isEntangled: false,
            creationTime: block.timestamp,
            lastMeasurement: 0
        });

        userParticles[msg.sender].push(newParticleId);
        quantumTokens[msg.sender] -= CREATION_COST;

        emit ParticleCreated(newParticleId, msg.sender);
        return newParticleId;
    }

    function entangleParticles(uint256 particle1Id, uint256 particle2Id) external returns (uint256) {
        require(particles[particle1Id].owner == msg.sender || particles[particle2Id].owner == msg.sender,
                "Must own at least one particle");
        require(!particles[particle1Id].isEntangled && !particles[particle2Id].isEntangled,
                "Particles already entangled");
        require(particles[particle1Id].spinState == 2 && particles[particle2Id].spinState == 2,
                "Both particles must be in superposition");
        require(particle1Id != particle2Id, "Cannot entangle particle with itself");

        entanglementCounter++;
        uint256 newEntanglementId = entanglementCounter;

        entanglementPairs[newEntanglementId] = EntanglementPair({
            id: newEntanglementId,
            particle1Id: particle1Id,
            particle2Id: particle2Id,
            creator: msg.sender,
            creationTime: block.timestamp,
            totalMeasurements: 0,
            isActive: true
        });

        particles[particle1Id].isEntangled = true;
        particles[particle1Id].entanglementId = newEntanglementId;
        particles[particle2Id].isEntangled = true;
        particles[particle2Id].entanglementId = newEntanglementId;

        quantumTokens[msg.sender] += ENTANGLEMENT_REWARD;

        emit ParticlesEntangled(newEntanglementId, particle1Id, particle2Id);
        return newEntanglementId;
    }

    function measureParticle(uint256 particleId) external returns (uint8) {
        require(particles[particleId].id != 0, "Particle does not exist");
        QuantumParticle storage particle = particles[particleId];
        require(particle.owner == msg.sender, "Not the owner of the particle");

        uint8 newState = uint8(uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            particleId
        ))) % 2);

        particle.spinState = newState;
        particle.lastMeasurement = block.timestamp;

        if (particle.isEntangled) {
            EntanglementPair storage entanglement = entanglementPairs[particle.entanglementId];
            require(entanglement.isActive, "Entanglement is not active");

            uint256 pairedParticleId = (entanglement.particle1Id == particleId) ?
                                        entanglement.particle2Id : entanglement.particle1Id;

            particles[pairedParticleId].spinState = (newState == 0) ? 1 : 0;
            particles[pairedParticleId].lastMeasurement = block.timestamp;

            entanglement.totalMeasurements++;

            if (entanglement.totalMeasurements >= 3) {
                entanglement.isActive = false;
                particles[particleId].isEntangled = false;
                particles[particleId].entanglementId = 0;
                particles[pairedParticleId].isEntangled = false;
                particles[pairedParticleId].entanglementId = 0;
                emit EntanglementBroken(particle.entanglementId, "Maximum measurements reached");
            }
        }

        quantumTokens[msg.sender] += MEASUREMENT_REWARD;

        emit ParticleMeasured(particleId, newState, MEASUREMENT_REWARD);
        return newState;
    }

    function getParticlesByOwner(address ownerAddr) external view returns (uint256[] memory) {
        return userParticles[ownerAddr];
    }

    function getQuantumTokenBalance(address user) external view returns (uint256) {
        return quantumTokens[user];
    }

    function isParticleEntangled(uint256 particleId) external view returns (bool) {
        return particles[particleId].isEntangled;
    }

    function addQuantumTokens(address user, uint256 amount) external {
        require(msg.sender == owner, "Only owner can add tokens");
        quantumTokens[user] += amount;
    }

    function getEntanglementDetails(uint256 entanglementId) external view returns (
        uint256 particle1Id,
        uint256 particle2Id,
        address creator,
        uint256 totalMeasurements,
        bool isActive
    ) {
        EntanglementPair storage entanglement = entanglementPairs[entanglementId];
        return (
            entanglement.particle1Id,
            entanglement.particle2Id,
            entanglement.creator,
            entanglement.totalMeasurements,
            entanglement.isActive
        );
    }
}
 
