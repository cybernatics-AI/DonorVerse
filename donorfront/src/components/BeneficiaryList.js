import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useWeb3 } from '../hooks/useWeb3';
import { getBeneficiaries } from '../utils/contractHelpers';

const BeneficiaryList = () => {
  const [beneficiaries, setBeneficiaries] = useState([]);
  const { contract } = useWeb3();

  useEffect(() => {
    const fetchBeneficiaries = async () => {
      if (contract) {
        const beneficiaryList = await getBeneficiaries(contract);
        setBeneficiaries(beneficiaryList);
      }
    };

    fetchBeneficiaries();
  }, [contract]);

  return (
    <div className="space-y-8">
      <h1 className="text-3xl font-bold text-blue-800">Beneficiaries</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {beneficiaries.map((beneficiary) => (
          <div key={beneficiary.id} className="bg-white shadow-md rounded-lg overflow-hidden transition-shadow hover:shadow-lg">
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-2 text-blue-700">{beneficiary.name}</h2>
              <p className="text-gray-600 mb-4">{beneficiary.description}</p>
              <div className="flex justify-between items-center">
                <span className="text-blue-600 font-semibold">
                  {beneficiary.receivedAmount} / {beneficiary.targetAmount} STX
                </span>
                <Link
                  to={`/beneficiary/${beneficiary.id}`}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors"
                >
                  View Details
                </Link>
              </div>
            </div>
            <div className="bg-blue-100 px-6 py-4">
              <div className="w-full bg-blue-200 rounded-full h-2.5">
                <div 
                  className="bg-blue-600 h-2.5 rounded-full" 
                  style={{ width: `${(beneficiary.receivedAmount / beneficiary.targetAmount) * 100}%` }}
                ></div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default BeneficiaryList;