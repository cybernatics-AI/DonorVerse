import React, { useState, useEffect } from 'react';
import BeneficiaryList from './BeneficiaryList';
import DonationForm from './DonationForm';
import UtilizationList from './UtilizationList';
import AdminPanel from './AdminPanel';
import { useWeb3 } from '../hooks/useWeb3';
// import { getContractInstance } from '../utils/contractHelpers';

const App = () => {
  const [userRole, setUserRole] = useState(null);
  const [beneficiaries, setBeneficiaries] = useState([]);
  const [donations, setDonations] = useState([]);
  const [utilizations, setUtilizations] = useState([]);
  const { account, web3 } = useWeb3();

  useEffect(() => {
    // TODO: Fetch user role, beneficiaries, donations, and utilizations from the smart contract
  }, []);

  return (
    <div className="app">
      <h1>Charity Smart Contract UI</h1>
      <BeneficiaryList beneficiaries={beneficiaries} />
      <DonationForm beneficiaries={beneficiaries} />
      <UtilizationList utilizations={utilizations} />
      {userRole === 'ROLE_ADMIN' && <AdminPanel />}
    </div>
  );
};

export default App;
