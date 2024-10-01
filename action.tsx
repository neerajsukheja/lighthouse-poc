// src/redux/actions/recentActivityActions.tsx
export const FETCH_RECENT_ACTIVITY_REQUEST = 'FETCH_RECENT_ACTIVITY_REQUEST';
export const FETCH_RECENT_ACTIVITY_SUCCESS = 'FETCH_RECENT_ACTIVITY_SUCCESS';
export const FETCH_RECENT_ACTIVITY_FAILURE = 'FETCH_RECENT_ACTIVITY_FAILURE';

// Action creator to trigger fetching recent activity
export const fetchRecentActivityRequest = () => ({
    type: FETCH_RECENT_ACTIVITY_REQUEST,
});

// Action creator for successful fetch
export const fetchRecentActivitySuccess = (data: any) => ({
    type: FETCH_RECENT_ACTIVITY_SUCCESS,
    payload: data,
});

// Action creator for failed fetch
export const fetchRecentActivityFailure = (error: string) => ({
    type: FETCH_RECENT_ACTIVITY_FAILURE,
    payload: error,
});
