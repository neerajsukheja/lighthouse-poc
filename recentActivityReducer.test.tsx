// src/redux/reducers/recentActivityReducer.test.tsx
import recentActivityReducer from './recentActivityReducer';
import {
    FETCH_RECENT_ACTIVITY_REQUEST,
    FETCH_RECENT_ACTIVITY_SUCCESS,
    FETCH_RECENT_ACTIVITY_FAILURE,
} from '../actions/recentActivityActions';

describe('Recent Activity Reducer', () => {
    const initialState = {
        loading: false,
        data: [],
        error: null,
    };

    it('should return the initial state', () => {
        expect(recentActivityReducer(undefined, {})).toEqual(initialState);
    });

    it('should handle FETCH_RECENT_ACTIVITY_REQUEST', () => {
        const expectedState = { ...initialState, loading: true };
        expect(recentActivityReducer(initialState, { type: FETCH_RECENT_ACTIVITY_REQUEST })).toEqual(expectedState);
    });

    it('should handle FETCH_RECENT_ACTIVITY_SUCCESS', () => {
        const mockData = [{ id: 1, transactionDescription: 'Test transaction' }];
        const expectedState = { ...initialState, loading: false, data: mockData };
        expect(recentActivityReducer(initialState, { type: FETCH_RECENT_ACTIVITY_SUCCESS, payload: mockData })).toEqual(expectedState);
    });

    it('should handle FETCH_RECENT_ACTIVITY_FAILURE', () => {
        const mockError = 'Failed to fetch data';
        const expectedState = { ...initialState, loading: false, error: mockError };
        expect(recentActivityReducer(initialState, { type: FETCH_RECENT_ACTIVITY_FAILURE, payload: mockError })).toEqual(expectedState);
    });
});
