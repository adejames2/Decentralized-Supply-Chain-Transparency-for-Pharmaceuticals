# Decentralized Supply Chain Transparency for Pharmaceuticals

A comprehensive blockchain-based system for tracking pharmaceutical products from origin to patient, ensuring safety, authenticity, and regulatory compliance.

## System Overview

This system consists of five interconnected smart contracts that provide end-to-end transparency in the pharmaceutical supply chain:

### 1. Drug Origin Verification Contract (`drug-origin.clar`)
- Records the source of active pharmaceutical ingredients (APIs) and excipients
- Tracks supplier certifications and quality standards
- Maintains immutable records of ingredient origins

### 2. Manufacturing Process Tracking Contract (`manufacturing-process.clar`)
- Monitors the manufacturing process to ensure quality and prevent contamination
- Records batch information, quality control tests, and manufacturing conditions
- Tracks compliance with Good Manufacturing Practices (GMP)

### 3. Distribution Channel Verification Contract (`distribution-channel.clar`)
- Tracks the movement of drugs from manufacturers to distributors to pharmacies
- Verifies authorized distribution channels
- Prevents counterfeit drugs from entering the supply chain

### 4. Temperature Monitoring Contract (`temperature-monitoring.clar`)
- Ensures that drugs are stored and transported at the correct temperatures
- Records temperature logs throughout the supply chain
- Alerts for temperature excursions that could affect drug efficacy

### 5. Patient Verification Contract (`patient-verification.clar`)
- Verifies that patients have a valid prescription before dispensing medication
- Tracks medication dispensing to prevent abuse and ensure proper usage
- Maintains patient privacy while ensuring prescription validity

## Key Features

- **Immutable Records**: All supply chain data is permanently recorded on the blockchain
- **Real-time Tracking**: Monitor pharmaceutical products at every stage
- **Regulatory Compliance**: Built-in compliance with pharmaceutical regulations
- **Anti-counterfeiting**: Prevents fake drugs from entering the supply chain
- **Temperature Integrity**: Ensures cold chain compliance for temperature-sensitive medications
- **Patient Safety**: Verifies prescriptions and prevents medication errors

## Contract Architecture

Each contract operates independently while maintaining data integrity across the entire supply chain. The system uses:

- **Principal-based Access Control**: Only authorized parties can update records
- **Event Logging**: All significant actions are logged for audit trails
- **Data Validation**: Strict validation ensures data integrity
- **Error Handling**: Comprehensive error codes for troubleshooting

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts: \`clarinet deploy\`

### Usage

Each contract provides specific functions for different stakeholders:

- **Suppliers**: Register ingredient origins and certifications
- **Manufacturers**: Record production processes and quality tests
- **Distributors**: Track product movement and storage conditions
- **Pharmacies**: Verify prescriptions and dispense medications
- **Regulators**: Audit supply chain data and ensure compliance

## Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
npm test
\`\`\`

Tests cover:
- Contract deployment and initialization
- Access control and permissions
- Data validation and error handling
- Integration between contracts
- Edge cases and security scenarios

## Security Considerations

- All sensitive operations require proper authorization
- Data validation prevents malicious inputs
- Access control ensures only authorized parties can modify records
- Audit trails provide complete transparency for regulators

## Compliance

This system is designed to support compliance with:
- FDA regulations for pharmaceutical tracking
- Good Manufacturing Practices (GMP)
- Good Distribution Practices (GDP)
- HIPAA requirements for patient data protection

## Contributing

Please read the PR-DETAILS.md file for information on contributing to this project.

## License

This project is licensed under the MIT License.
