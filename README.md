# Donor-Beneficiary Connection DApp Smart Contract

This smart contract, written in Clarity, powers a decentralized application (DApp) that connects donors with marginalized individuals or groups seeking funding. It allows for transparent tracking of funds and their utilization.

## Features

1. Beneficiary Registration
2. Donation Management
3. Fund Utilization Tracking
4. Admin Controls

## Main Functions

### `register-beneficiary`
Allows a beneficiary to register with a name, description, and target amount.

### `donate`
Enables donors to contribute STX to a specific beneficiary.

### `add-utilization`
Allows the admin to add fund utilization entries for beneficiaries.

### `approve-utilization`
Enables the admin to approve fund utilization requests.

### Read-Only Functions

- `get-beneficiary`: Retrieves information about a specific beneficiary.
- `get-donations`: Lists all donations for a particular beneficiary.
- `get-utilization`: Shows all utilization entries for a beneficiary.

## Data Structures

1. `beneficiaries`: Stores information about registered beneficiaries.
2. `donations`: Records all donations made through the platform.
3. `utilization`: Tracks how funds are being used by beneficiaries.

## Security Features

- Admin-only functions for critical operations.
- Error handling for various scenarios (e.g., insufficient funds, unauthorized access).

## Getting Started

1. Deploy this contract to a Stacks blockchain.
2. Set the admin address post-deployment.
3. Beneficiaries can register using `register-beneficiary`.
4. Donors can contribute using the `donate` function.
5. The admin can track and approve fund utilization.

Expected code structure for the User Interface (UI)

src/
|-- components/
|   |-- Admin/
|   |   |-- SetRole.js
|   |   |-- RemoveRole.js
|   |   |-- AddUtilization.js
|   |   |-- ApproveUtilization.js
|   |-- Beneficiary/
|   |   |-- RegisterBeneficiary.js
|   |   |-- BeneficiaryDetails.js
|   |   |-- BeneficiaryList.js
|   |-- Donation/
|   |   |-- DonationForm.js
|   |   |-- DonationList.js
|   |-- Utilization/
|   |   |-- UtilizationList.js
|   |-- common/
|   |   |-- Header.js
|   |   |-- Footer.js
|   |   |-- Navbar.js
|-- contexts/
|   |-- WalletContext.js
|-- hooks/
|   |-- useContract.js
|-- pages/
|   |-- Home.js
|   |-- AdminDashboard.js
|   |-- BeneficiaryDashboard.js
|   |-- DonationPage.js
|-- services/
|   |-- contractInteraction.js
|-- App.js
|-- index.js