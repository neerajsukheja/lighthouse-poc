// src/redux/actions/recentActivityActions.test.tsx
import {
    FETCH_RECENT_ACTIVITY_REQUEST,
    FETCH_RECENT_ACTIVITY_SUCCESS,
    FETCH_RECENT_ACTIVITY_FAILURE,
    fetchRecentActivityRequest,
    fetchRecentActivitySuccess,
    fetchRecentActivityFailure,
} from './recentActivityActions';

describe('Recent Activity Actions', () => {
    it('should create an action to fetch recent activity', () => {
        const expectedAction = { type: FETCH_RECENT_ACTIVITY_REQUEST };
        expect(fetchRecentActivityRequest()).toEqual(expectedAction);
    });

    it('should create an action for successful recent activity fetch', () => {
        const mockData = [{ id: 1, transactionDescription: 'Test transaction' }];
        const expectedAction = {
            type: FETCH_RECENT_ACTIVITY_SUCCESS,
            payload: mockData,
        };
        expect(fetchRecentActivitySuccess(mockData)).toEqual(expectedAction);
    });

    it('should create an action for failed recent activity fetch', () => {
        const mockError = 'Failed to fetch data';
        const expectedAction = {
            type: FETCH_RECENT_ACTIVITY_FAILURE,
            payload: mockError,
        };
        expect(fetchRecentActivityFailure(mockError)).toEqual(expectedAction);
    });
});
