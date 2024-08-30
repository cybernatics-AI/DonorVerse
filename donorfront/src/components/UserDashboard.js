import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../hooks/useWeb3';
import { getUserDonations } from '../utils/contractHelpers';

const UserDashboard = () => {
  const [donations, setDonations] = useState([]);
  const [totalDonated, setTotalDonated] = useState(0);
  const { contract, address } = useWeb3();

  useEffect(() => {
    fetchUserDonations();
  }, [contract, address]);

  const fetchUserDonations = async () => {
    if (contract && address) {
      const userDonations = await getUserDonations(contract, address);
      setDonations(userDonations);
      setTotalDonated(userDonations.reduce((sum, donation) => sum + donation.amount, 0));
    }
  };

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold text-blue-800">User Dashboard</h1>
      
      <div className="bg-white shadow-md rounded-lg p-6">
        <h2 className="text-2xl font-semibold mb-4 text-blue-700">Your Donations</h2>
        <p className="text-xl mb-4">Total Donated: <span className="font-bold text-blue-600">{totalDonated} STX</span></p>
        
        {donations.length === 0 ? (
          <p>You haven't made any donations yet.</p>
        ) : (
          <ul className="space-y-4">
            {donations.map((donation, index) => (
              <li key={index} className="border-b pb-4">
                <p className="font-semibold">{donation.beneficiaryName}</p>
                <p className="text-gray-600">Amount: {donation.amount} STX</p>
                <p className="text-gray-600">Date: {new Date(donation.timestamp * 1000).toLocaleDateString()}</p>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};

export default UserDashboard;