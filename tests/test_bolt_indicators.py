import pandas as pd
import numpy as np
import pytest
from utils.technical_indicators import TechnicalIndicators

def test_add_all_indicators_correctness():
    ti = TechnicalIndicators()
    n = 100
    df = pd.DataFrame({
        "high": np.linspace(102, 110, n),
        "low": np.linspace(98, 106, n),
        "close": np.linspace(100, 108, n),
        "volume": np.ones(n) * 1000,
    })

    result = ti.add_all_indicators(df)

    # Check if typical_price is present and correct
    assert "typical_price" in result.columns
    expected_tp = (df["high"] + df["low"] + df["close"]) / 3
    pd.testing.assert_series_equal(result["typical_price"], expected_tp, check_names=False)

    # Check if Pivot Points are present and correct
    assert "pivot" in result.columns
    pd.testing.assert_series_equal(result["pivot"], expected_tp, check_names=False)

    # Check if CCI is present
    assert "cci" in result.columns

    # Check if WMA is present and reasonably valued
    assert "wma_20" in result.columns
    # The last WMA_20 should be greater than the first one if prices are increasing
    assert result["wma_20"].iloc[-1] > result["wma_20"].iloc[20]

def test_wma_logic():
    ti = TechnicalIndicators()
    # Simple case: 3 periods
    df = pd.DataFrame({
        "close": [10.0, 20.0, 30.0, 40.0, 50.0]
    })
    # We need to mock add_moving_averages periods to include 3, or just test the logic
    # Since add_moving_averages uses fixed periods [5, 10, 20, 50, 100, 200]
    # let's use 5
    df = pd.DataFrame({
        "close": [10.0, 20.0, 30.0, 40.0, 50.0, 60.0]
    })
    result = ti.add_moving_averages(df)

    # WMA 5 for [10, 20, 30, 40, 50]
    # Weights: [1, 2, 3, 4, 5], Sum: 15
    # Expected: (10*1 + 20*2 + 30*3 + 40*4 + 50*5) / 15 = (10+40+90+160+250)/15 = 550/15 = 36.666...
    assert pytest.approx(result["wma_5"].iloc[4]) == 550/15

    # WMA 5 for [20, 30, 40, 50, 60]
    # Expected: (20*1 + 30*2 + 40*3 + 50*4 + 60*5) / 15 = (20+60+120+200+300)/15 = 700/15 = 46.666...
    assert pytest.approx(result["wma_5"].iloc[5]) == 700/15

def test_ad_line_logic():
    ti = TechnicalIndicators()
    df = pd.DataFrame({
        "high": [110, 120],
        "low": [100, 100],
        "close": [105, 115],
        "volume": [1000, 1000]
    })
    result = ti.add_volume_indicators(df)

    # Row 0: H=110, L=100, C=105, V=1000
    # Range = 10
    # MFM = (2*105 - 100 - 110) / 10 = (210 - 210) / 10 = 0
    # AD = 0
    assert result["ad_line"].iloc[0] == 0

    # Row 1: H=120, L=100, C=115, V=1000
    # Range = 20
    # MFM = (2*115 - 100 - 120) / 20 = (230 - 220) / 20 = 10 / 20 = 0.5
    # MFV = 0.5 * 1000 = 500
    # AD = 0 + 500 = 500
    assert result["ad_line"].iloc[1] == 500

if __name__ == "__main__":
    pytest.main([__file__])
