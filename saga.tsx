// src/redux/sagas/recentActivitySaga.tsx
import { call, put, takeLatest } from 'redux-saga/effects';
import {
    FETCH_RECENT_ACTIVITY_REQUEST,
    fetchRecentActivitySuccess,
    fetchRecentActivityFailure,
} from '../actions/recentActivityActions';

// Mock API call function, replace this with actual API call
const fetchRecentActivityApi = async () => {
    const response = await fetch('/api/recent-activity'); // Replace with actual API endpoint
    if (!response.ok) {
        throw new Error('Failed to fetch recent activity data');
    }
    return await response.json();
};

// Worker saga to handle fetching recent activity data
function* fetchRecentActivitySaga() {
    try {
        const data = yield call(fetchRecentActivityApi);
        yield put(fetchRecentActivitySuccess(data));
    } catch (error: any) {
        yield put(fetchRecentActivityFailure(error.message));
    }
}

// Watcher saga
export function* watchFetchRecentActivity() {
    yield takeLatest(FETCH_RECENT_ACTIVITY_REQUEST, fetchRecentActivitySaga);
}
