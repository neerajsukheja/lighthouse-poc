// src/redux/reducers/recentActivityReducer.tsx
import {
    FETCH_RECENT_ACTIVITY_REQUEST,
    FETCH_RECENT_ACTIVITY_SUCCESS,
    FETCH_RECENT_ACTIVITY_FAILURE,
} from '../actions/recentActivityActions';

interface RecentActivityState {
    loading: boolean;
    data: any[];
    error: string | null;
}

const initialState: RecentActivityState = {
    loading: false,
    data: [],
    error: null,
};

const recentActivityReducer = (state = initialState, action: any) => {
    switch (action.type) {
        case FETCH_RECENT_ACTIVITY_REQUEST:
            return {
                ...state,
                loading: true,
                error: null,
            };
        case FETCH_RECENT_ACTIVITY_SUCCESS:
            return {
                ...state,
                loading: false,
                data: action.payload,
            };
        case FETCH_RECENT_ACTIVITY_FAILURE:
            return {
                ...state,
                loading: false,
                error: action.payload,
            };
        default:
            return state;
    }
};

export default recentActivityReducer;
