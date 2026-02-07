## 2024-07-22 - Non-blocking CPU-Bound Tasks in Asyncio

**Learning:** I discovered a performance bottleneck in `core/trading_engine.py` where a CPU-bound operation, `technical_indicators.add_all_indicators`, was blocking the `asyncio` event loop. Even though the I/O operations were concurrent, this synchronous calculation serialized the execution, negating the benefits of `asyncio.gather`.

**Action:** In the future, I will use `asyncio.to_thread` to run any CPU-bound function in a separate thread. This will keep the event loop free and ensure that both I/O and CPU-bound tasks can run in parallel, maximizing throughput.

## 2025-01-30 - Vectorizing Rolling Linear Regression Slope

**Learning:** I identified a major performance bottleneck in `utils/technical_indicators.py` where `rolling().apply(np.polyfit)` was used to calculate trend strength. This iterative approach is extremely slow because it invokes the SVD-based `polyfit` solver and Python-level overhead for every window.

**Action:** I replaced the iterative approach with a vectorized mathematical formula using `np.convolve` and `rolling().sum()`. This optimization provided a ~3x speedup for the `add_trend_indicators` method, significantly reducing the CPU load during market data processing and signal generation.

## 2025-02-14 - Redundant Mean in Mean Absolute Deviation (MAD)

**Learning:** While optimizing CCI in `utils/technical_indicators.py`, I realized that the rolling Mean Absolute Deviation (MAD) step was re-calculating the rolling mean for every window, even though the Simple Moving Average (SMA) of the Typical Price (`sma_tp`) had already been computed. Reusing these pre-calculated mean values in the vectorized MAD calculation avoids redundant arithmetic.

**Action:** I refactored the CCI calculation to reuse `sma_tp.values` during the vectorized MAD step. I also switched from `as_strided` to `np.lib.stride_tricks.sliding_window_view` for safer and more modern vectorized window generation. This improved the CCI calculation speed by ~17%.

## 2025-02-14 - Weight Ordering in Vectorized WMA

**Learning:** I discovered that the previous `np.convolve` implementation of the Weighted Moving Average (WMA) was logically incorrect because it didn't account for the fact that convolution flips the kernel. This resulted in older prices receiving higher weights than recent ones.

**Action:** I corrected the WMA implementation by reversing the weights (`weights[::-1]`) before passing them to `np.convolve`. I also optimized the denominator calculation using the constant-time arithmetic series formula `n*(n+1)/2`, ensuring the indicator is both fast and mathematically sound.

## 2025-01-30 - Row-wise Maximum and Arithmetic Overhead

**Learning:** I identified a significant performance bottleneck in the ADX calculation within `utils/technical_indicators.py`. Specifically, using `pd.concat([...], axis=1).max(axis=1)` to calculate the True Range (TR) is extremely inefficient compared to nested `np.maximum` calls. Additionally, performing row-wise arithmetic on Pandas Series carries substantial overhead for index alignment and validation.

**Action:** I replaced `pd.concat().max()` with nested `np.maximum` and moved arithmetic operations to raw NumPy arrays by using `.values`. This combination reduced the ADX calculation time by ~43%, demonstrating that bypassing the Pandas Series abstraction for simple row-wise math is a powerful optimization in hot code paths.

## 2025-02-12 - Reusing Intermediate Indicator Results

**Learning:** I identified a common performance anti-pattern where multiple technical indicators (e.g., Stochastic Oscillator, Williams %R, Bollinger Bands, and Support/Resistance) re-calculate the same rolling windows (min, max, mean, std) independently. This redundancy wastes CPU cycles, especially as the number of indicators grows.

**Action:** I refactored `utils/technical_indicators.py` to calculate shared rolling windows once and reuse them. For example, rolling min/max for window 14 is now shared between Stochastic and Williams %R, and `sma_20`/`std_20` are shared between Bollinger Bands and Volatility Indicators. This optimization provides a ~10-15% speedup across the affected methods without changing the output logic.

## 2025-05-15 - Vectorized Sliding Windows in Feature Engineering

**Learning:** I identified a massive performance bottleneck in `ai_models/feature_engineer.py` where Python loops were used to generate sliding windows for LSTMs and CNNs. Generating chart images was particularly slow (~1.7s for 2000 rows) due to repeated `.iloc` slicing and redundant normalization in every window. Additionally, the inference path redundantly calculated the entire history even though only the last window was needed.

**Action:** I replaced the Python loops with `numpy.lib.stride_tricks.sliding_window_view` for fully vectorized window generation, yielding a ~270x speedup for chart images. I also introduced an `only_last` flag to optimize the inference path, providing a ~60x speedup for real-time predictions. Using `np.stack` and `np.column_stack` on the vectorized windows ensures the multi-channel structure is maintained without explicit iteration.

## 2025-05-20 - Index Alignment Overhead in Row-wise Arithmetic

**Learning:** I identified a performance bottleneck in `utils/technical_indicators.py` where multiple technical indicators (RSI, Bollinger Bands, Pivot Points) were performing row-wise arithmetic directly on Pandas Series. Each Series-to-Series operation triggers index validation and alignment, which is costly when done repeatedly for many columns.

**Action:** I replaced Series arithmetic with raw NumPy array operations by extracting `.values`. This optimization provided a ~20% speedup for Support/Resistance levels and a ~5% boost for Bollinger Bands. Moving to NumPy for final arithmetic steps after windowed operations (like rolling mean) is a consistent win in this codebase.

## 2025-05-25 - Bypassing Series Index Alignment in Bulk Indicator Arithmetic

**Learning:** I identified a consistent performance overhead in `utils/technical_indicators.py` where row-wise arithmetic operations (addition, subtraction, division) were performed directly on Pandas Series. Even when indexes are aligned, Pandas performs validation that becomes significant when called repeatedly across dozens of indicators.

**Action:** I replaced Series-to-Series arithmetic with raw NumPy array operations by extracting `.values`. For OBV and VPT, I fully vectorized the logic using `np.diff` and `np.where`. This provided a ~14% overall speedup for the `add_all_indicators` method (~100ms per 100k rows), demonstrating that "dropping down" to NumPy for final arithmetic steps after windowed operations is a high-value performance pattern in data-intensive paths.

## 2026-02-14 - Vectorizing SMA, ROC, and ADX Shifting

**Learning:** I identified a performance bottleneck in the technical indicator utility where SMA, ROC, and ADX were using Pandas-level operations (`rolling().mean()`, `pct_change()`, and `shift()`). While these are optimized in Pandas, they still carry significant overhead for index alignment and validation when called repeatedly for multiple periods and columns.

**Action:** I replaced Pandas `rolling().mean()` with `np.convolve` for SMAs, and replaced `pct_change()` and `shift()` with vectorized NumPy arithmetic. These optimizations provided a ~32% overall speedup for the `add_all_indicators` method (~91ms vs ~135ms for 10k rows), confirming that "dropping down" to raw NumPy arrays for even basic arithmetic and windowing is a consistent performance win in data-intensive paths.
