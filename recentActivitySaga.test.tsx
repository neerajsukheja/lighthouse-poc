// src/redux/sagas/recentActivitySaga.test.tsx
import { runSaga } from 'redux-saga';
import { fetchRecentActivitySaga } from './recentActivitySaga';
import * as api from '../api'; // Assuming you move the mock fetch to an API file
import {
    fetchRecentActivitySuccess,
    fetchRecentActivityFailure,
} from '../actions/recentActivityActions';

describe('Recent Activity Saga', () => {
    it('should call API and dispatch success action', async () => {
        const dispatchedActions: any[] = [];
        const mockData = [{ id: 1, transactionDescription: 'Test transaction' }];

        // Mocking API call
        jest.spyOn(api, 'fetchRecentActivityApi').mockImplementation(() => Promise.resolve(mockData));

        // Running the saga
        await runSaga(
            {
                dispatch: (action) => dispatchedActions.push(action),
            },
            fetchRecentActivitySaga
        ).toPromise();

        expect(dispatchedActions).toContainEqual(fetchRecentActivitySuccess(mockData));
    });

    it('should call API and dispatch failure action on error', async () => {
        const dispatchedActions: any[] = [];
        const mockError = 'API fetch failed';

        // Mocking API failure
        jest.spyOn(api, 'fetchRecentActivityApi').mockImplementation(() => Promise.reject(mockError));

        // Running the saga
        await runSaga(
            {
                dispatch: (action) => dispatchedActions.push(action),
            },
            fetchRecentActivitySaga
        ).toPromise();

        expect(dispatchedActions).toContainEqual(fetchRecentActivityFailure(mockError));
    });
});
