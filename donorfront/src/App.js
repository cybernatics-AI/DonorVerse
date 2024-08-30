import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Navigation from './Navigation';
import BeneficiaryList from './BeneficiaryList';
import BeneficiaryDetails from './BeneficiaryDetails';
import DonationForm from './DonationForm';
import UtilizationList from './UtilizationList';
import AdminPanel from './AdminPanel';
import UserDashboard from './UserDashboard';
import { Web3Provider } from '../contexts/Web3Context';
import { UserProvider } from '../contexts/UserContext';

const App = () => {
  const [userRole, setUserRole] = useState(null);

  useEffect(() => {
    // TODO: Fetch user role from the smart contract
  }, []);

  return (
    <Web3Provider>
      <UserProvider>
        <Router>
          <div className="min-h-screen bg-gray-50 text-gray-900">
            <Navigation userRole={userRole} />
            <main className="container mx-auto px-4 py-8">
              <Switch>
                <Route exact path="/" component={BeneficiaryList} />
                <Route path="/beneficiary/:id" component={BeneficiaryDetails} />
                <Route path="/donate/:id" component={DonationForm} />
                <Route path="/utilization/:id" component={UtilizationList} />
                {userRole === 'admin' && <Route path="/admin" component={AdminPanel} />}
                <Route path="/dashboard" component={UserDashboard} />
              </Switch>
            </main>
          </div>
        </Router>
      </UserProvider>
    </Web3Provider>
  );
};

export default App;