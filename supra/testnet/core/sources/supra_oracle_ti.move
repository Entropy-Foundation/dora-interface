module supra_oracle::supra_oracle_ti {

    use std::option::{Option};


    /// Basic data structure combining a value with its timestamp
    struct TimestampedValue has copy, drop, store {
        value: u128,
        // Price or other numerical value
        timestamp: u64
        // Unix timestamp in ms
    }

    /// OHLC candlestick data structure
    struct Candle has copy, drop, store {
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
    struct CandleInfo has copy, drop {
        startTime: u64,
        endTime: u64,
        candle: Candle
    }

    /// Computes the Simple Moving Average (SMA) for a given trading pair, period, and candle duration.
    ///
    /// The SMA is calculated by taking the arithmetic mean of closing prices across `period` candles.
    /// It is a fundamental trend indicator used to smooth short-term fluctuations.
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair.
    /// - `period`: Number of candles to average. Must be one of **[9, 20, 50, 200]**.
    /// - `candle_duration`: Duration of each candle **in milliseconds**, must be one of:
    ///   `300_000`, `900_000`, `3_600_000`, `14_400_000`, `86_400_000`.
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage,
    ///   expressed using **two-decimal fixed-point** (e.g., `5000 = 50.00%`, `1000 = 10.00%`).
    ///
    /// # Returns
    /// - `Option<u128>`:
    ///     - `some(sma)` if the indicator can be computed.
    ///     - `none` if:
    ///         - insufficient candle history exists,
    ///         - period is invalid,
    ///         - missing-candle tolerance is exceeded.
    ///
    /// # Notes
    /// - Returned SMA is scaled by `DECIMAL_BUFFER` for precision.
    /// - If `(latest_index - first_index) < period`, computation is not possible.
    /// - If missing-candle percentage exceeds tolerance, `none` is returned.
    #[view]
    native public fun compute_sma(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): Option<u128>;


    /// Computes the Exponential Moving Average (EMA) for the given pair and candle duration.
    ///
    /// EMA applies greater weight to recent price data, making it more responsive than SMA.
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair.
    /// - `period`: EMA period. Must be one of **[9, 20, 50, 200]**.
    /// - `candle_duration`: Candle duration in **milliseconds**, must match one of the
    ///   supported canonical durations.
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage,
    ///   expressed using **two-decimal precision**.
    ///
    /// # Returns
    /// A tuple:
    /// - `Option<u128>`: Latest EMA value (scaled), or `none` if unavailable.
    /// - `Option<u64>`: Number of missing candles since last EMA update.
    /// - `Option<u64>`: Total candles formed from the first candle to the latest update.
    ///
    /// # Notes
    /// - If no EMA history exists for this `(pair_id, period)`, all fields return `none`.
    /// - If missing-candle percentage exceeds tolerance, the entire tuple returns `none`.
    /// - EMA uses the most recent candle close price.

    #[view]
    native public fun compute_ema(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): (Option<u128>, Option<u64>, Option<u64>);


    /// Computes the Relative Strength Index (RSI) for a given pair, candle duration, and period.
    ///
    /// RSI measures the magnitude of recent gains vs. losses to identify momentum strength.
    ///
    /// # Parameters
    /// - `pair_id`: Unique identifier of the trading pair.
    /// - `period`: RSI lookback period. Must be one of **[7, 14, 21]**.
    /// - `candle_duration`: Candle duration in **milliseconds**, must be valid.
    /// - `missing_candles_tolerance_percentage`: Maximum allowed missing-candle percentage
    ///   (two-decimal fixed-point).
    ///
    /// # Returns
    /// - `Option<u128>`: The RSI value (scaled) if computable.
    /// - `Option<u64>`: Number of missing candles inside the RSI window.
    ///
    /// # RSI is returned only if:
    /// - Period is supported.
    /// - At least `period + 1` candles exist.
    /// - Missing-candle percentage is within tolerance.
    /// - Necessary historical RSI state exists.
    ///
    /// Otherwise `(none, none)` is returned.

    #[view]
    native public fun compute_rsi(
        pair_id: u32,
        period: u64,
        candle_duration: u64,
        missing_candles_tolerance_percentage: u64
    ): (Option<u128>, Option<u64>);


    /// Retrieves the latest `n` candles for the specified trading pair and candle duration.
    ///
    /// # Parameters
    /// - `num_of_candles`: Number of recent candles to return.
    /// - `pair_id`: Unique identifier for the trading pair.
    /// - `candle_duration`: Candle duration in **milliseconds**.
    ///
    /// # Returns
    /// - `vector<CandleInfo>` containing:
    ///     - `startTime`: Candle open timestamp,
    ///     - `endTime`: Candle close timestamp,
    ///     - `candle`: Complete candle struct.
    ///
    /// # Notes
    /// - Candles are returned from newest to oldest.

    #[view]
    native public fun get_latest_candles(
        num_of_candles: u64,
        pair_id: u32,
        candle_duration: u64
    ): vector<CandleInfo>;


    /// Retrieves the latest `n` candles generated after a given `start_timestamp`.
    ///
    /// This is a convenience wrapper that calls
    /// `get_latest_candles_between_specific_time` using the current timestamp
    /// as the ending boundary.
    ///
    /// # Parameters
    /// - `num_of_candles`: Number of candles requested.
    /// - `pair_id`: Unique trading pair identifier.
    /// - `candle_duration`: Candle duration in milliseconds.
    /// - `start_timestamp`: Lower bound (inclusive), in milliseconds.
    ///
    /// # Returns
    /// - `vector<CandleInfo>` representing candles whose close times are >= `start_timestamp`.

    #[view]
    native public fun get_latest_candles_from_specific_time(
        num_of_candles: u64,
        pair_id: u32,
        candle_duration: u64,
        start_timestamp: u64
    ): vector<CandleInfo>;


    /// Retrieves candles whose close timestamps fall within a specific time window.
    ///
    /// # Parameters
    /// - `num_of_candles`: Number of recent candles to scan.
    /// - `pair_id`: Unique trading pair identifier.
    /// - `candle_duration`: Candle duration in milliseconds.
    /// - `start_timestamp`: Lower bound (inclusive), in milliseconds.
    /// - `end_timestamp`: Upper bound (inclusive), in milliseconds.
    ///
    /// # Returns
    /// - `vector<CandleInfo>` containing all candles matching the time window.
    ///
    /// # Notes
    /// - Only the most recent `num_of_candles` are inspected.
    /// - If `start_timestamp > end_timestamp`, the call will revert.
    #[view]
    native public fun get_latest_candles_between_specific_time(
        num_of_candles: u64,
        pair_id: u32,
        candle_duration: u64,
        start_timestamp: u64,
        end_timestamp: u64
    ): vector<CandleInfo>;

}