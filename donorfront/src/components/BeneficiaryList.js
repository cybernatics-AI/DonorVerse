import React from 'react';

const BeneficiaryList = ({ beneficiaries }) => {
  return (
    <div className="beneficiary-list">
      <h2>Beneficiaries</h2>
      <ul>
        {beneficiaries.map((beneficiary) => (
          <li key={beneficiary.id}>
            <h3>{beneficiary.name}</h3>
            <p>{beneficiary.description}</p>
            <p>Target Amount: {beneficiary.targetAmount}</p>
            <p>Received Amount: {beneficiary.receivedAmount}</p>
            <p>Status: {beneficiary.status}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default BeneficiaryList;
  