// src/redux/reducers/rootReducer.tsx
import { combineReducers } from 'redux';
import recentActivityReducer from './recentActivityReducer';

const rootReducer = combineReducers({
    recentActivity: recentActivityReducer,
    // Add other reducers here if needed
});

export default rootReducer;
