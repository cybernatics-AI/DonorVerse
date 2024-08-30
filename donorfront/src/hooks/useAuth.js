import { useState, useEffect, useContext } from 'react';
import { Web3Context } from '../contexts/Web3Context';
import { UserContext } from '../contexts/UserContext';
import { getContractInstance } from '../utils/contractHelpers';

export const useAuth = () => {
  const { web3, account } = useContext(Web3Context);
  const { user, setUser } = useContext(UserContext);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      if (web3 && account) {
        const contract = getContractInstance(web3);
        const roleData = await contract.methods.roles(account).call();
        
        setIsAuthenticated(true);
        setIsAdmin(roleData.role === '1'); // Assuming ROLE_ADMIN is represented by '1'
        setUser({ address: account, role: roleData.role });
      } else {
        setIsAuthenticated(false);
        setIsAdmin(false);
        setUser(null);
      }
    };

    checkAuth();
  }, [web3, account, setUser]);

  const logout = () => {
    // Implement logout logic here
    setIsAuthenticated(false);
    setIsAdmin(false);
    setUser(null);
  };

  return { user, isAuthenticated, isAdmin, logout };
};

export default useAuth;