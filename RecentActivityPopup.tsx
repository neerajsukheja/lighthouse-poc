// src/components/RecentActivityPopup.tsx
import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchRecentActivityRequest } from '../redux/actions/recentActivityActions';
import { RootState } from '../redux/reducers/rootReducer'; // Assuming RootState type is defined for state

const RecentActivityPopup: React.FC = () => {
    const dispatch = useDispatch();
    const { loading, data, error } = useSelector((state: RootState) => state.recentActivity);

    useEffect(() => {
        dispatch(fetchRecentActivityRequest());
    }, [dispatch]);

    return (
        <div className="popup">
            <h2>Recent Activity</h2>
            {loading && <p>Loading...</p>}
            {error && <p>Error: {error}</p>}
            <ul>
                {data?.map((transaction, index) => (
                    <li key={index}>
                        <p>{transaction.transactionDescription}</p>
                        <p>Amount: {transaction.transactionAmount}</p>
                        <p>Date: {transaction.transactionDate}</p>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default RecentActivityPopup;
