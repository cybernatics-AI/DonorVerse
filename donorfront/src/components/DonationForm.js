import React, { useState } from 'react';

const DonationForm = ({ beneficiaries }) => {
  const [selectedBeneficiary, setSelectedBeneficiary] = useState('');
  const [amount, setAmount] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: Call the donate function from the smart contract
    console.log('Donation submitted:', { beneficiaryId: selectedBeneficiary, amount });
  };

  return (
    <div className="donation-form">
      <h2>Make a Donation</h2>
      <form onSubmit={handleSubmit}>
        <select
          value={selectedBeneficiary}
          onChange={(e) => setSelectedBeneficiary(e.target.value)}
          required
        >
          <option value="">Select a beneficiary</option>
          {beneficiaries.map((beneficiary) => (
            <option key={beneficiary.id} value={beneficiary.id}>
              {beneficiary.name}
            </option>
          ))}
        </select>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Amount"
          required
        />
        <button type="submit">Donate</button>
      </form>
    </div>
  );
};

export default DonationForm;
