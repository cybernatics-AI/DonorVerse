import React from 'react';

const UtilizationList = ({ utilizations }) => {
  return (
    <div className="utilization-list">
      <h2>Utilizations</h2>
      <ul>
        {utilizations.map((utilization) => (
          <li key={utilization.id}>
            <h3>Milestone: {utilization.milestone}</h3>
            <p>Beneficiary ID: {utilization.beneficiaryId}</p>
            <p>Description: {utilization.description}</p>
            <p>Amount: {utilization.amount}</p>
            <p>Status: {utilization.status}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default UtilizationList;
