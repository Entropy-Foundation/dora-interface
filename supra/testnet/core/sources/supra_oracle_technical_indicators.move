module supra_oracle::supra_oracle_technical_indicators {

    use std::option::{Option};


    /// Basic data structure combining a value with its timestamp
    struct TimestampedValue has copy, drop, store {
        value: u128,
        // Price or other numerical value
        timestamp: u64
        // Unix timestamp in ms
    }

    /// OHLC candlestick data structure
    struct OHLC has copy, drop, store {
        low: TimestampedValue,
        // Lowest price in the time period
        high: TimestampedValue,
        // Highest price in the time period
        open: TimestampedValue,
        // Opening price of the time period
        close: TimestampedValue,
        // Closing price of the time period
    }

    /// CandleInfo represents a single OHLC candle returned by the indicator queries.
    /// All timestamps are in milliseconds.
    /// - `startTime`: Timestamp marking the beginning of the candle.
    /// - `endTime`: Timestamp marking the end of the candle.
    /// - `candle`: The aggregated candle data (open, high, low, close, volume, etc.).
    /// CandleInfo structure to return data
    struct CandleInfo has copy, drop {
        start_time: u64,
        // start time of the candle
        end_time: u64,
        // endtime of the candle
        candle: OHLC
        // candle open, high, low, close
    }

    #[view]
    // ============================================================================
    // SIMPLE MOVING AVERAGE (SMA)
    // ============================================================================

    /// Computes the Simple Moving Average (SMA) for a given trading pair, period, and candle duration.
    ///
    /// The SMA is calculated by taking the arithmetic mean of closing prices across `period` candles.
    /// It is a fundamental trend indicator used to smooth short-term fluctuations.
    ///
    /// **Formula:**
    /// ```
    /// SMA = (Sum of closing prices over period) / period
    /// ```
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair (e.g., 1 for BTC/USD).
    /// - `period`: Number of candles to average. Must be one of **[9, 20, 50, 200]**.
    /// - `candle_duration`: Duration of each candle **in milliseconds**, must be one of:
    ///   - `300000` (5 min)
    ///   - `900000` (15 min)
    ///   - `3600000` (1 hour)
    ///   - `14400000` (4 hours)
    ///   - `86400000` (1 day)
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage,
    ///   expressed using **two-decimal fixed-point** (e.g., `5000 = 50.00%`, `1000 = 10.00%`).
    ///
    /// # Returns
    /// - `Option<u128>`:
    ///     - `some(sma)` if the indicator can be computed, **scaled by DECIMAL_BUFFER (10000)**.
    ///     - `none` if:
    ///         - insufficient candle history exists (< period candles available),
    ///         - period is invalid (not in [9, 20, 50, 200]),
    ///         - missing-candle tolerance is exceeded.
    ///
    /// # Decimal Precision
    /// **CRITICAL:** The returned SMA is scaled by `DECIMAL_BUFFER = 10000`.
    ///
    /// **To get the actual SMA value:**
    /// ```
    /// let sma_option = compute_sma(pair_id, 20, 300000, 1000);
    /// ```
    ///
    /// # Example Usage
    /// ```move
    /// // Calculate 20-period SMA for BTC/USD using 5-minute candles
    /// // Allow up to 10% missing candles
    /// let pair_id = 1; // BTC/USD
    /// let period = 20;
    /// let candle_duration = 300000; // 5 minutes in milliseconds
    /// let tolerance = 1000; // 10.00%
    ///
    /// let sma_result = compute_sma(pair_id, period, candle_duration, tolerance);
    ///
    /// **CRITICAL:** The returned EMA is scaled by `DECIMAL_BUFFER = 10000`.
    /// for eg. sma of pair will be in decimals of the pair scaled by 10000.
    /// SMA (BTC) - 1_000_000_000_000_000_000 * DECIMAL_BUFFER
    /// ```
    ///
    /// # Notes
    /// - If `(latest_index - first_index) < period`, computation is not possible.
    /// - If missing-candle percentage exceeds tolerance, `none` is returned.
    /// - SMA is less responsive to recent price changes compared to EMA.
    native public fun compute_sma(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): Option<u128>;


    #[view]
    // ============================================================================
    // EXPONENTIAL MOVING AVERAGE (EMA)
    // ============================================================================

    /// Computes the Exponential Moving Average (EMA) for the given pair and candle duration.
    ///
    /// EMA applies greater weight to recent price data, making it more responsive than SMA.
    /// It's widely used for identifying trend direction and generating trading signals.
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair (e.g., 2 for ETH/USD).
    /// - `period`: EMA period. Must be one of **[9, 20, 50, 200]**.
    /// - `candle_duration`: Candle duration in **milliseconds**, must match one of the
    ///   supported canonical durations (300000, 900000, 3600000, 14400000, 86400000).
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage,
    ///   expressed using **two-decimal precision** (e.g., `2000 = 20.00%`).
    ///
    /// # Returns
    /// A tuple containing:
    /// - `Option<u128>`: Latest EMA value **scaled by DECIMAL_BUFFER (10000)**, or `none` if unavailable.
    ///
    /// # Decimal Precision
    /// **CRITICAL:** The returned EMA is scaled by `DECIMAL_BUFFER = 10000`.
    /// **To get the actual EMA value:**
    /// ```move
    /// let (ema_option, num_missing_candles_till_this_ema_calculation, num_total_candles) = compute_ema(pair_id, 50, 3600000, 1500);
    /// ```
    ///
    /// # Example Usage
    /// ```move
    /// // Calculate 50-period EMA for ETH/USD using 1-hour candles
    /// // Allow up to 15% missing candles
    /// let pair_id = 2; // ETH/USD
    /// let period = 50;
    /// let candle_duration = 3600000; // 1 hour in milliseconds
    /// let tolerance = 1500; // 15.00%
    ///
    /// **CRITICAL:** The returned EMA is scaled by `DECIMAL_BUFFER = 10000`.
    /// for eg. ema of pair will be in decimals of the pair scaled by 10000.
    /// EMA (BTC) = 1_000_000_000_000_000_000 * DECIMAL_BUFFER
    ///
    /// let (ema_opt) = compute_ema(pair_id, period, candle_duration, tolerance);
    /// ```
    ///
    /// # Notes
    /// - If no EMA history exists for this `(pair_id, period)`, all fields return `none`.
    /// - If missing-candle percentage exceeds tolerance, the entire tuple returns `none`.
    /// - EMA uses the most recent candle close price for calculations.
    /// - EMA is initialized using SMA when sufficient data becomes available.
    /// - More responsive to recent price changes than SMA due to exponential weighting.
    native public fun compute_ema(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): (Option<u128>);


    #[view]
    // ============================================================================
    // RELATIVE STRENGTH INDEX (RSI)
    // ============================================================================

    /// Computes the Relative Strength Index (RSI) for a given pair, candle duration, and period.
    ///
    /// RSI measures the magnitude of recent gains vs. losses to identify momentum strength.
    /// It's a bounded oscillator that ranges from 0 to 100.
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair (e.g., 3 for BNB/USD).
    /// - `period`: RSI lookback period. Must be one of **[7, 14, 21]**.
    ///   - **7:** More sensitive, generates frequent signals
    ///   - **14:** Standard period, balanced sensitivity
    ///   - **21:** Less sensitive, fewer but stronger signals
    /// - `candle_duration`: Candle duration in **milliseconds**, must be valid (300000, 900000, etc.).
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage
    ///   (two-decimal fixed-point, e.g., `3000 = 30.00%`).
    ///
    /// # Returns
    /// A tuple containing:
    /// - `Option<u128>`: The RSI value **scaled by DECIMAL_BUFFER (10000)** if computable.
    ///
    /// # Decimal Precision
    /// **CRITICAL:** The returned RSI is scaled by `DECIMAL_BUFFER = 10000`.
    ///
    /// **RSI value range:** 0 to 1,000,000 (representing 0.00 to 100.00)
    ///
    /// let (rsi_option, missing_option) = compute_rsi(pair_id, 14, 900000, 2000);
    ///
    /// ```
    /// # Example Usage
    /// ```
    /// // Calculate 14-period RSI for BNB/USD using 15-minute candles
    /// // Allow up to 20% missing candles
    /// let pair_id = 3; // BNB/USD
    /// let period = 14; // Standard RSI period
    /// let candle_duration = 900000; // 15 minutes in milliseconds
    /// let tolerance = 2000; // 20.00%
    ///
    /// let (rsi_opt) = compute_rsi(pair_id, period, candle_duration, tolerance);
    ///
    /// ```
    /// # Decimal Precision
    /// **CRITICAL:** The returned RSI is scaled by `DECIMAL_BUFFER = 10000`.
    /// if returned RSI is 20 , RSI = 20 * DECIMAL_BUFFER
    /// # RSI Special Cases
    /// - **RSI = 0 (scaled: 0)**: Only losses occurred, no gains (extremely oversold)
    /// - **RSI = 100 (scaled: 1000000)**: Only gains occurred, no losses (extremely overbought)
    /// - **No price movement**: Returns the previous RSI value
    ///
    /// # Returns `none` if:
    /// - Period is not supported (not in [7, 14, 21])
    /// - Insufficient candle history (< period + 1 candles available)
    /// - Missing-candle percentage exceeds tolerance
    /// - No historical RSI state exists for continuity
    ///
    /// # Notes
    /// - Requires at least `period + 1` candles to compute initial RSI.
    /// - Falls back to previous RSI if no recent price movement occurred.
    /// - RSI is most reliable in ranging markets, less reliable in strong trends.
    native public fun compute_rsi(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): (Option<u128>);


    #[view]
    // ============================================================================
    // CANDLE DATA RETRIEVAL FUNCTIONS
    // ============================================================================

    /// Retrieves the latest `n` candles for the specified trading pair and candle duration.
    ///
    /// **Use cases:**
    /// - Displaying recent price action on charts
    /// - Analyzing recent price patterns
    /// - Building custom technical indicators
    /// - Backtesting trading strategies
    ///
    /// # Parameters
    /// - `num_of_candles`: Number of recent candles to return (must be > 0).
    /// - `pair_id`: Unique identifier for the trading pair (e.g., 1 for BTC/USD).
    /// - `candle_duration`: Candle duration in **milliseconds** (e.g., 300000 for 5 min).
    ///
    /// # Returns
    /// - `vector<CandleInfo>` containing candles ordered from **newest to oldest**:
    ///     - `startTime`: Candle open timestamp (milliseconds)
    ///     - `endTime`: Candle close timestamp (milliseconds)
    ///     - `candle`: Complete OHLC data structure
    ///
    /// # Example Usage
    /// ```move
    /// // Get the last 50 candles for BTC/USD using 5-minute intervals
    /// let pair_id = 1; // BTC/USD
    /// let candle_duration = 300000; // 5 minutes
    /// let candles = get_latest_candles(50, pair_id, candle_duration);
    ///
    /// ```
    ///
    /// # Notes
    /// - Candles are returned in **reverse chronological order** (newest first).
    /// - If `num_of_candles` exceeds available history, returns all available candles.
    /// - All price values in candles are **scaled by DECIMAL_BUFFER (10000)**.
    /// - Timestamps are in **milliseconds** since Unix epoch.
    native public fun get_latest_candles(
        num_of_candles: u64,
        pair_id: u32,
        candle_duration: u64
    ): vector<CandleInfo>;


    #[view]
    /// Retrieves the latest `n` candles generated after a given `start_timestamp`.
    ///
    /// This is a convenience wrapper that calls `get_latest_candles_between_specific_time`
    /// using the current timestamp as the ending boundary.
    ///
    /// **Use cases:**
    /// - Fetching candles since a specific event (e.g., "show all candles after market open")
    /// - Time-filtered chart data
    /// - Incremental data updates
    ///
    /// # Parameters
    /// - `num_of_candles`: Maximum number of candles to scan.
    /// - `pair_id`: Unique trading pair identifier (e.g., 2 for ETH/USD).
    /// - `candle_duration`: Candle duration in **milliseconds**.
    /// - `start_timestamp`: Lower bound (inclusive), in **milliseconds** since Unix epoch.
    ///
    /// # Returns
    /// - `vector<CandleInfo>` representing candles whose close times are >= `start_timestamp`.
    ///
    /// # Example Usage
    /// ```move
    /// // Get all 5-minute candles for ETH/USD since 10:30 AM today
    /// let pair_id = 2; // ETH/USD
    /// let candle_duration = 300000; // 5 minutes
    /// let start_time = 1704448200000; // 10:30 AM in milliseconds
    ///
    /// let candles = get_latest_candles_from_specific_time(100, pair_id, candle_duration, start_time);
    ///
    /// // candles contains all 5-min candles from 10:30 AM to now
    /// // (up to 100 candles maximum)
    /// ```
    ///
    /// # Notes
    /// - Scans the most recent `num_of_candles` and filters by timestamp.
    /// - If no candles match the time criteria, returns an empty vector.
    /// - All timestamps are in **milliseconds**.
    native public fun get_latest_candles_from_specific_time(
        pair_id: u32,
        candle_duration: u64,
        start_timestamp: u64
    ): vector<CandleInfo>;


    #[view]
    /// Retrieves candles whose close timestamps fall within a specific time window.
    ///
    /// This provides precise time-range filtering for historical analysis.
    ///
    /// **Use cases:**
    /// - Analyzing price action during specific market events
    /// - Backtesting strategies over defined periods
    /// - Comparing price behavior across different time windows
    /// - Generating reports for specific trading sessions
    ///
    /// # Parameters
    /// - `num_of_candles`: Maximum number of recent candles to scan.
    /// - `pair_id`: Unique trading pair identifier (e.g., 3 for BNB/USD).
    /// - `candle_duration`: Candle duration in **milliseconds**.
    /// - `start_timestamp`: Lower bound (inclusive), in **milliseconds** since Unix epoch.
    /// - `end_timestamp`: Upper bound (inclusive), in **milliseconds** since Unix epoch.
    ///
    /// # Returns
    /// - `vector<CandleInfo>` containing all candles matching the time window.
    ///
    /// # Example Usage
    /// ```move
    /// // Get all 1-hour candles for BNB/USD between 9 AM and 5 PM on Jan 5, 2025
    /// let pair_id = 3; // BNB/USD
    /// let candle_duration = 3600000; // 1 hour
    /// let start_time = 1736064000000; // Jan 5, 2025 9:00 AM (ms)
    /// let end_time = 1736092800000;   // Jan 5, 2025 5:00 PM (ms)
    ///
    /// let candles = get_latest_candles_between_specific_time(
    ///     200,              // Scan up to 200 candles
    ///     pair_id,
    ///     candle_duration,
    ///     start_time,
    ///     end_time
    /// );
    ///
    /// // candles contains all 1-hour candles from 9 AM to 5 PM
    /// // Example: 8 candles (9 AM, 10 AM, 11 AM, 12 PM, 1 PM, 2 PM, 3 PM, 4 PM)
    /// ```
    ///
    /// # Notes
    /// - Only the most recent `num_of_candles` are inspected for efficiency.
    /// - If `start_timestamp > end_timestamp`, behavior is undefined (may return empty vector).
    /// - Candles are filtered by their **close timestamp**, not open timestamp.
    /// - All timestamps must be in **milliseconds** since Unix epoch.
    /// - Returns empty vector if no candles fall within the specified range.
    native public fun get_latest_candles_between_specific_time(
        pair_id: u32,
        candle_duration: u64,
        start_timestamp: u64,
        end_timestamp: u64
    ): vector<CandleInfo>;

    /// @dev Deserialises a `Candle` into its four core timestamped components.
    ///
    /// @params candle - The `Candle` struct containing open, high, low, and close values.
    ///
    /// @returns (TimestampedValue, TimestampedValue, TimestampedValue, TimestampedValue)
    ///          Returns the low, high, open, and close values in tuple form for easy comparison
    ///          or external verification.
    ///         (low, high, open, close)
    native public fun deserialise_ohlc(
        candle: OHLC
    ): (TimestampedValue, TimestampedValue, TimestampedValue, TimestampedValue);

    /// @dev Extracts the core components of a `CandleInfo` object for verification or debugging.
    ///
    /// @params candle_info - The `CandleInfo` struct containing timestamps and the underlying candle.
    ///
    /// @returns (u64, u64, Candle)
    ///          Returns the start timestamp, end timestamp, and the associated `OHLC` object.
    native public fun deserialise_candle_info(
        candle_info: CandleInfo
    ): (u64, u64, OHLC);

    /// @dev Breaks down a `TimestampedValue` into its timestamp and numeric value.
    ///
    /// @params timestamp_value - The `TimestampedValue` struct to deserialise.
    ///
    /// @returns (value, timestamp)
    native public fun deserialise_timestamped_value(timestamp_value: TimestampedValue): (u128, u64);
}