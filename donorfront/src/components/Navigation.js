import React from 'react';
import { Link } from 'react-router-dom';

const Navigation = ({ userRole }) => {
  return (
    <nav className="bg-blue-600 text-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center py-4">
          <Link to="/" className="text-2xl font-bold text-white hover:text-blue-200 transition-colors">Charity DApp</Link>
          <ul className="flex space-x-6">
            <li><Link to="/" className="hover:text-blue-200 transition-colors">Home</Link></li>
            <li><Link to="/dashboard" className="hover:text-blue-200 transition-colors">Dashboard</Link></li>
            {userRole === 'admin' && (
              <li><Link to="/admin" className="hover:text-blue-200 transition-colors">Admin</Link></li>
            )}
          </ul>
        </div>
      </div>
    </nav>
  );
};

export default Navigation;