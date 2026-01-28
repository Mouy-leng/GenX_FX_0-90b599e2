import numpy as np
import pandas as pd


class RSI:
    """
    Calculates the RSI (Relative Strength Index) indicator.

    Attributes:
        period (int): The time period for RSI calculation.
    """

    def __init__(self, period: int = 14):
        """
        Initializes the RSI calculator with a specified period.

        Args:
            period (int): The look-back period for the RSI calculation.
        """
        self.period = period

    def calculate(self, prices: pd.Series) -> np.ndarray:
        """
        Calculates the Relative Strength Index (RSI) for a given price series.

        Args:
            prices (pd.Series): A pandas Series of closing prices.

        Returns:
            np.ndarray: An array containing the RSI values.
        """
        if isinstance(prices, pd.Series):
            prices = prices.values

        deltas = np.diff(prices)
        seed = deltas[: self.period + 1]
        up = seed[seed >= 0].sum() / self.period
        down = -seed[seed < 0].sum() / self.period
        rs = up / down if down != 0 else 0
        rsi = np.zeros_like(prices)
        rsi[: self.period] = 100.0 - 100.0 / (1.0 + rs)

        for i in range(self.period, len(prices)):
            delta = deltas[i - 1]  # The diff is 1 shorter

            if delta > 0:
                upval = delta
                downval = 0.0
            else:
                upval = 0.0
                downval = -delta

            up = (up * (self.period - 1) + upval) / self.period
            down = (down * (self.period - 1) + downval) / self.period

            rs = up / down if down != 0 else 0
            rsi[i] = 100.0 - 100.0 / (1.0 + rs)

        return rsi


def calculate_rsi(prices: pd.Series, period: int = 14) -> np.ndarray:
    """
    A convenience function to calculate the Relative Strength Index (RSI).

    Args:
        prices (pd.Series): A pandas Series of closing prices.
        period (int): The look-back period for the RSI calculation.

    Returns:
        np.ndarray: An array containing the RSI values.
    """
    rsi_indicator = RSI(period)
    return rsi_indicator.calculate(prices)
