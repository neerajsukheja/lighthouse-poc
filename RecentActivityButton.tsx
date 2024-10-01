// src/components/RecentActivityButton.tsx
import React, { useState } from 'react';
import RecentActivityPopup from './RecentActivityPopup';

const RecentActivityButton: React.FC = () => {
    const [showPopup, setShowPopup] = useState(false);

    const handleButtonClick = () => {
        setShowPopup(true);
    };

    return (
        <div>
            <button onClick={handleButtonClick}>View Recent Activity</button>
            {showPopup && <RecentActivityPopup />}
        </div>
    );
};

export default RecentActivityButton;
