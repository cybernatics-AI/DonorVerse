import { openContractCall } from '@stacks/connect';
import { uintCV, stringUtf8CV } from '@stacks/transactions';

export const getBeneficiaries = async (contract) => {
  // This is a placeholder. In a real app, you'd need to implement pagination
  // and fetch beneficiaries from the contract storage
  const beneficiaryCount = await contract.getBeneficiaryCount();
  const beneficiaries = [];
  for (let i = 1; i <= beneficiaryCount; i++) {
    const beneficiary = await contract.getBeneficiary(i);
    beneficiaries.push(beneficiary);
  }
  return beneficiaries;
};

export const registerBeneficiary = async (contract, address, name, description, targetAmount) => {
  const functionArgs = [
    stringUtf8CV(name),
    stringUtf8CV(description),
    uintCV(targetAmount)
  ];

  const options = {
    contractAddress: contract.address,
    contractName: contract.name,
    functionName: 'register-beneficiary',
    functionArgs,
    senderAddress: address,
    network: contract.network,
  };

  return openContractCall(options);
};

export const donate = async (contract, address, beneficiaryId, amount) => {
  const functionArgs = [
    uintCV(beneficiaryId),
    uintCV(amount)
  ];

  const options = {
    contractAddress: contract.address,
    contractName: contract.name,
    functionName: 'donate',
    functionArgs,
    senderAddress: address,
    network: contract.network,
  };

  return openContractCall(options);
};

export const approveUtilization = async (contract, address, beneficiaryId, milestoneId) => {
  const functionArgs = [
    uintCV(beneficiaryId),
    uintCV(milestoneId)
  ];

  const options = {
    contractAddress: contract.address,
    contractName: contract.name,
    functionName: 'approve-utilization',
    functionArgs,
    senderAddress: address,
    network: contract.network,
  };

  return openContractCall(options);
};

export const getUserDonations = async (contract, address) => {
  return [];
};