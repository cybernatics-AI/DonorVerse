import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../hooks/useWeb3';
import { getBeneficiaries, registerBeneficiary, approveUtilization } from '../utils/contractHelpers';

const AdminPanel = () => {
  const [beneficiaries, setBeneficiaries] = useState([]);
  const [newBeneficiary, setNewBeneficiary] = useState({ name: '', description: '', targetAmount: '' });
  const [utilizationRequests, setUtilizationRequests] = useState([]);
  const { contract, address } = useWeb3();

  useEffect(() => {
    fetchBeneficiaries();
    fetchUtilizationRequests();
  }, [contract]);

  const fetchBeneficiaries = async () => {
    if (contract) {
      const beneficiaryList = await getBeneficiaries(contract);
      setBeneficiaries(beneficiaryList);
    }
  };

  const fetchUtilizationRequests = async () => {
    // TODO: Implement fetching utilization requests from the contract
  };

  const handleRegisterBeneficiary = async (e) => {
    e.preventDefault();
    try {
      await registerBeneficiary(contract, address, newBeneficiary.name, newBeneficiary.description, newBeneficiary.targetAmount);
      setNewBeneficiary({ name: '', description: '', targetAmount: '' });
      fetchBeneficiaries();
    } catch (error) {
      console.error('Error registering beneficiary:', error);
    }
  };

  const handleApproveUtilization = async (beneficiaryId, milestoneId) => {
    try {
      await approveUtilization(contract, address, beneficiaryId, milestoneId);
      fetchUtilizationRequests();
    } catch (error) {
      console.error('Error approving utilization:', error);
    }
  };

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold text-blue-800">Admin Panel</h1>
      
      <div className="bg-white shadow-md rounded-lg p-6">
        <h2 className="text-2xl font-semibold mb-4 text-blue-700">Register New Beneficiary</h2>
        <form onSubmit={handleRegisterBeneficiary} className="space-y-4">
          <input
            type="text"
            placeholder="Beneficiary Name"
            value={newBeneficiary.name}
            onChange={(e) => setNewBeneficiary({...newBeneficiary, name: e.target.value})}
            className="w-full p-2 border border-gray-300 rounded"
            required
          />
          <textarea
            placeholder="Description"
            value={newBeneficiary.description}
            onChange={(e) => setNewBeneficiary({...newBeneficiary, description: e.target.value})}
            className="w-full p-2 border border-gray-300 rounded"
            required
          ></textarea>
          <input
            type="number"
            placeholder="Target Amount"
            value={newBeneficiary.targetAmount}
            onChange={(e) => setNewBeneficiary({...newBeneficiary, targetAmount: e.target.value})}
            className="w-full p-2 border border-gray-300 rounded"
            required
          />
          <button type="submit" className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors">
            Register Beneficiary
          </button>
        </form>
      </div>

      <div className="bg-white shadow-md rounded-lg p-6">
        <h2 className="text-2xl font-semibold mb-4 text-blue-700">Utilization Requests</h2>
        {utilizationRequests.length === 0 ? (
          <p>No pending utilization requests.</p>
        ) : (
          <ul className="space-y-4">
            {utilizationRequests.map((request) => (
              <li key={request.id} className="flex justify-between items-center">
                <span>{request.description} - {request.amount} STX</span>
                <button
                  onClick={() => handleApproveUtilization(request.beneficiaryId, request.milestoneId)}
                  className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 transition-colors"
                >
                  Approve
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};

export default AdminPanel;