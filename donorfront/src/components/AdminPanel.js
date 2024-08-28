import React, { useState } from 'react';

const AdminPanel = () => {
  const [beneficiaryName, setBeneficiaryName] = useState('');
  const [beneficiaryDescription, setBeneficiaryDescription] = useState('');
  const [beneficiaryTargetAmount, setBeneficiaryTargetAmount] = useState('');
  const [utilizationBeneficiaryId, setUtilizationBeneficiaryId] = useState('');
  const [utilizationDescription, setUtilizationDescription] = useState('');
  const [utilizationAmount, setUtilizationAmount] = useState('');

  const handleRegisterBeneficiary = (e) => {
    e.preventDefault();
    // TODO: Call the register-beneficiary function from the smart contract
    console.log('Register beneficiary:', { beneficiaryName, beneficiaryDescription, beneficiaryTargetAmount });
  };

  const handleAddUtilization = (e) => {
    e.preventDefault();
    // TODO: Call the add-utilization function from the smart contract
    console.log('Add utilization:', { utilizationBeneficiaryId, utilizationDescription, utilizationAmount });
  };

  return (
    <div className="admin-panel">
      <h2>Admin Panel</h2>
      <form onSubmit={handleRegisterBeneficiary}>
        <h3>Register Beneficiary</h3>
        <input
          type="text"
          value={beneficiaryName}
          onChange={(e) => setBeneficiaryName(e.target.value)}
          placeholder="Name"
          required
        />
        <input
          type="text"
          value={beneficiaryDescription}
          onChange={(e) => setBeneficiaryDescription(e.target.value)}
          placeholder="Description"
          required
        />
        <input
          type="number"
          value={beneficiaryTargetAmount}
          onChange={(e) => setBeneficiaryTargetAmount(e.target.value)}
          placeholder="Target Amount"
          required
        />
        <button type="submit">Register Beneficiary</button>
      </form>

      <form onSubmit={handleAddUtilization}>
        <h3>Add Utilization</h3>
        <input
          type="number"
          value={utilizationBeneficiaryId}
          onChange={(e) => setUtilizationBeneficiaryId(e.target.value)}
          placeholder="Beneficiary ID"
          required
        />
        <input
          type="text"
          value={utilizationDescription}
          onChange={(e) => setUtilizationDescription(e.target.value)}
          placeholder="Description"
          required
        />
        <input
          type="number"
          value={utilizationAmount}
          onChange={(e) => setUtilizationAmount(e.target.value)}
          placeholder="Amount"
          required
        />
        <button type="submit">Add Utilization</button>
      </form>
    </div>
  );
};

export default AdminPanel;
