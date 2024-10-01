// src/components/RecentActivityButton.test.tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import RecentActivityButton from './RecentActivityButton';

describe('RecentActivityButton Component', () => {
    it('should render the button and show popup on click', () => {
        render(<RecentActivityButton />);

        // Ensure button is rendered
        const button = screen.getByText(/View Recent Activity/i);
        expect(button).toBeInTheDocument();

        // Click the button
        fireEvent.click(button);

        // Ensure popup appears
        expect(screen.getByText(/Recent Activity/i)).toBeInTheDocument();
    });
});
