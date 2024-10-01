// src/components/RecentActivityPopup.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import configureStore from 'redux-mock-store';
import RecentActivityPopup from './RecentActivityPopup';
import { fetchRecentActivityRequest } from '../redux/actions/recentActivityActions';

const mockStore = configureStore([]);

describe('RecentActivityPopup Component', () => {
    let store: any;

    beforeEach(() => {
        store = mockStore({
            recentActivity: {
                loading: false,
                data: [
                    { transactionDescription: 'Test Transaction 1', transactionAmount: '10.00', transactionDate: '08/02/24' },
                    { transactionDescription: 'Test Transaction 2', transactionAmount: '20.00', transactionDate: '08/03/24' }
                ],
                error: null,
            },
        });
        store.dispatch = jest.fn();
    });

    it('should dispatch fetchRecentActivityRequest on render', () => {
        render(
            <Provider store={store}>
                <RecentActivityPopup />
            </Provider>
        );
        expect(store.dispatch).toHaveBeenCalledWith(fetchRecentActivityRequest());
    });

    it('should display loading message when loading is true', () => {
        store = mockStore({
            recentActivity: {
                loading: true,
                data: [],
                error: null,
            },
        });

        render(
            <Provider store={store}>
                <RecentActivityPopup />
            </Provider>
        );

        expect(screen.getByText(/Loading.../i)).toBeInTheDocument();
    });

    it('should display error message when error is present', () => {
        store = mockStore({
            recentActivity: {
                loading: false,
                data: [],
                error: 'Failed to fetch data',
            },
        });

        render(
            <Provider store={store}>
                <RecentActivityPopup />
            </Provider>
        );

        expect(screen.getByText(/Failed to fetch data/i)).toBeInTheDocument();
    });

    it('should display list of transactions', () => {
        render(
            <Provider store={store}>
                <RecentActivityPopup />
            </Provider>
        );

        expect(screen.getByText(/Test Transaction 1/i)).toBeInTheDocument();
        expect(screen.getByText(/Amount: 10.00/i)).toBeInTheDocument();
        expect(screen.getByText(/Test Transaction 2/i)).toBeInTheDocument();
    });
});
