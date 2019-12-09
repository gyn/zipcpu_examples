////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	buttonsim.h
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	A BUTTON simulator, capable of bouncing for a specified number
//		of clock ticks.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Written and distributed by Gisselquist Technology, LLC
//
// This program is hereby granted to the public domain.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.
//
////////////////////////////////////////////////////////////////////////////////
//
//
#ifndef	BUTTONSIM_H
#define	BUTTONSIM_H

#define	TIME_PERIOD	50000 // 1/2 ms at 10ns

class	BUTTONSIM	{
	int	m_state, m_timeout;

public:
	BUTTONSIM(void) {
		// Start with the button up
		m_state = 0; // not pressed
		//
		// and begin stable, i.e.
		m_timeout = 0;
	}

	void	press(void) {
		m_state = 1; // i.e. down
		m_timeout = TIME_PERIOD;
	}

	bool	pressed(void) {
		return m_state;
	}

	void	release(void) {
		m_state = 0; // i.e. released
		m_timeout = TIME_PERIOD;
	}

	int	operator()(void) {
		if (m_timeout > 0)
			m_timeout--;
		if (m_timeout == TIME_PERIOD-1) {
			// Return any new button
			// state accurately and
			// immediately
			return	m_state;
		} else if (m_timeout > 0) {
			// Until we become stable
			// Bounce!
			return rand()&1;
		}
		// Else the button has settled
		return m_state;
	}
};

#endif // BUTTONSIM_H
