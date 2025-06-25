// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SolarPanelRegistry {
    
    struct SolarPanel {
        uint256 panelId;
        address owner;
        string location;
        uint256 capacity; // in watts
        uint256 installationDate;
        uint256 totalEnergyGenerated; // in kWh
        bool isActive;
        string manufacturer;
    }

    mapping(uint256 => SolarPanel) public solarPanels;
    mapping(address => uint256[]) public ownerPanels;

    uint256 public nextPanelId = 1;
    uint256 public totalRegisteredPanels;
    uint256 public totalEnergyGenerated;

    event PanelRegistered(
        uint256 indexed panelId,
        address indexed owner,
        string location,
        uint256 capacity
    );

    event EnergyUpdated(
        uint256 indexed panelId,
        uint256 newEnergyGenerated,
        uint256 totalEnergy
    );

    event PanelStatusChanged(
        uint256 indexed panelId,
        bool isActive
    );

    modifier onlyPanelOwner(uint256 _panelId) {
        require(solarPanels[_panelId].owner == msg.sender, "Not the panel owner");
        _;
    }

    modifier panelExists(uint256 _panelId) {
        require(_panelId < nextPanelId && _panelId != 0, "Panel does not exist");
        _;
    }

    function registerPanel(
        string memory _location,
        uint256 _capacity,
        string memory _manufacturer
    ) external {
        require(bytes(_location).length > 0, "Location required");
        require(_capacity > 0, "Capacity must be greater than 0");
        require(bytes(_manufacturer).length > 0, "Manufacturer required");

        uint256 panelId = nextPanelId;

        solarPanels[panelId] = SolarPanel({
            panelId: panelId,
            owner: msg.sender,
            location: _location,
            capacity: _capacity,
            installationDate: block.timestamp,
            totalEnergyGenerated: 0,
            isActive: true,
            manufacturer: _manufacturer
        });

        ownerPanels[msg.sender].push(panelId);
        totalRegisteredPanels++;
        nextPanelId++;

        emit PanelRegistered(panelId, msg.sender, _location, _capacity);
    }

    function updateEnergyGeneration(
        uint256 _panelId,
        uint256 _energyGenerated
    ) external onlyPanelOwner(_panelId) panelExists(_panelId) {
        require(_energyGenerated > 0, "Energy must be > 0");
        require(solarPanels[_panelId].isActive, "Panel inactive");

        // Optional overflow safety check (uint256 generally safe, but good habit)
        require(
            solarPanels[_panelId].totalEnergyGenerated + _energyGenerated >= solarPanels[_panelId].totalEnergyGenerated,
            "Overflow detected"
        );

        solarPanels[_panelId].totalEnergyGenerated += _energyGenerated;
        totalEnergyGenerated += _energyGenerated;

        emit EnergyUpdated(_panelId, _energyGenerated, solarPanels[_panelId].totalEnergyGenerated);
    }

    function togglePanelStatus(uint256 _panelId)
        external
        onlyPanelOwner(_panelId)
        panelExists(_panelId)
    {
        solarPanels[_panelId].isActive = !solarPanels[_panelId].isActive;

        emit PanelStatusChanged(_panelId, solarPanels[_panelId].isActive);
    }

    function getPanelDetails(uint256 _panelId)
        external
        view
        panelExists(_panelId)
        returns (
            uint256,
            address,
            string memory,
            uint256,
            uint256,
            uint256,
            bool,
            string memory
        )
    {
        SolarPanel memory panel = solarPanels[_panelId];
        return (
            panel.panelId,
            panel.owner,
            panel.location,
            panel.capacity,
            panel.installationDate,
            panel.totalEnergyGenerated,
            panel.isActive,
            panel.manufacturer
        );
    }

    function getOwnerPanels(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return ownerPanels[_owner];
    }

    function getRegistryStats()
        external
        view
        returns (uint256 totalPanels, uint256 totalEnergy)
    {
        return (totalRegisteredPanels, totalEnergyGenerated);
    }
}
