---
title: Create a monitor
type: apicontent
order: 15.1
external_redirect: /api/#create-a-monitor
---

## Create a monitor

##### ARGUMENTS
*   `type` [*required*]:  
    The type of the monitor, chosen from:  
    *   `metric alert`
    *   `service check`
    *   `event alert`
    *   `composite`

*   `query` [*required*]:  
    The query defines when the monitor triggers. Query syntax depends on what type of monitor you are creating:  
    ##### Metric Alert Query
    `time_aggr(time_window):space_aggr:metric{tags} [by {key}] operator #`

    -   `time_aggr` avg, sum, max, min, change, or pct_change
    -   `time_window` last_#m (5, 10, 15, or 30), last_#h (1, 2, or 4), or last_1d
    -   `space_aggr` avg, sum, min, or max
    -   `tags` one or more tags (comma-separated), or *
    -   `key` a 'key' in key:value tag syntax; defines a separate alert for each tag in the group (multi-alert)
    -   `operator` <, <=, >, >=, ==, or !=
    -   `#` an integer or decimal number used to set the threshold

    If you are using the `_change_` or `_pct_change_` time aggregator, instead use `change_aggr(time_aggr(time_window), timeshift):space_aggr:metric{tags} [by {key}] operator #` with:

    *   `change_aggr` change, pct_change
    *   `time_aggr` avg, sum, max, min [Learn more](/monitors/monitor_types/#define-the-conditions)
    *   `time_window` last_#m (1, 5, 10, 15, or 30), last_#h (1, 2, or 4), or last_#d (1 or 2)
    *   `timeshift` #m_ago (5, 10, 15, or 30), #h_ago (1, 2, or 4), or 1d_ago

    Use this to create an outlier monitor using the following query: `avg(last_30m):outliers(avg:system.cpu.user{role:es-events-data} by {host}, 'dbscan', 7) > 0`

    ##### Service Check Query
    `"check".over(tags).last(count).count_by_status()`

    *   `check` name of the check, e.g. datadog.agent.up
    *   `tags` one or more quoted tags (comma-separated), or "*". e.g.: `.over("env:prod", "role:db")`
    *   `count` must be at >= your max threshold (defined in the `options`). e.g. if you want to notify on 1 critical, 3 ok and 2 warn statuses count should be 3.

    ##### Event Alert Query

    `events('sources:nagios status:error,warning priority:normal tags: "string query"').rollup("count").last("1h")"`

    *   `event`, the event query string:
    *   `string_query` free text query to match against event title and text.
    *   `sources` event sources (comma-separated). [Complete list of source attribute values](/integrations/faq/list-of-api-source-attribute-value)
    *   `status` event statuses (comma-separated). Valid options: error, warn, and info.
    *   `priority` event priorities (comma-separated). Valid options: low, normal, all.
    *   `host` event reporting host (comma-separated).
    *   `tags` event tags (comma-separated).
    *   `excluded_tags` exluded event tags (comma-separated).
    *   `rollup` the stats rollup method. `count` is the only supported method now.
    *   `last` the timeframe to roll up the counts. Examples: 60s, 4h. Supported timeframes: s, m, h and d.

    ##### Composite Query

    `12345 && 67890`, where `12345` and `67890` are the IDs of non-composite monitors

* `name` [*required*, *default* = **dynamic, based on query**]: 
    The name of the alert.
* `message` [*required*, *default* = **dynamic, based on query**]:  
    A message to include with notifications for this monitor. Email notifications can be sent to specific users by using the same '@username' notation as events.
* `tags` [*optional*, *default* = **empty list**]: 
    A list of tags to associate with your monitor. When getting all monitor details via the API, use the `monitor_tags` argument to filter results by these tags. It is only available via the API and isn't visible or editable in the Datadog UI.

* `options` [*optional*, *default*=**None**]:  
    A dictionary of options for the monitor. There are options that are common to all types as well as options that are specific to certain monitor types.  
    ##### Common Options

    *   `silenced` dictionary of scopes to timestamps or `None`. Each scope is muted until the given POSIX timestamp or forever if the value is `None`. Default: **None**  
        Examples:
        *   To mute the alert completely: `{'*': None}`
        *   To mute `role:db` for a short time: `{'role:db': 1412798116}`

    *   `notify_no_data` a boolean indicating whether this monitor notifies when data stops reporting. Default: **false**

    *   `new_host_delay` Time (in seconds) to allow a host to boot and applications to fully start before starting the evaluation of monitor results. Should be a non negative integer. Default: **300**

    *   `no_data_timeframe` the number of minutes before a monitor notifies when data stops reporting. Must be at least 2x the monitor timeframe for metric alerts or 2 minutes for service checks. Default: **2x timeframe for metric alerts, 2 minutes for service checks**

    *   `timeout_h` the number of hours of the monitor not reporting data before it automatically resolves from a triggered state. Default: **None**.

    *   `require_full_window` a boolean indicating whether this monitor needs a full window of data before it's evaluated. We highly recommend you set this to `False` for sparse metrics, otherwise some evaluations are skipped. Default: **True** for "on average", "at all times" and "in total" aggregation. **False** otherwise.

    *   `renotify_interval` the number of minutes after the last notification before a monitor re-notifies on the current status. It only re-notifies if it's not resolved. Default: **None**.

    *   `escalation_message` a message to include with a re-notification. Supports the '@username' notification we allow elsewhere. Not applicable if `renotify_interval` is `None`. Default: **None**.

    *   `notify_audit` a boolean indicating whether tagged users is notified on changes to this monitor. Default: **False**

    *   `locked` a boolean indicating whether changes to to this monitor should be restricted to the creator or admins. Default: **False**

    *   `include_tags` a boolean indicating whether notifications from this monitor automatically inserts its triggering tags into the title. Default: **True** Examples:  
        *   True: `[Triggered on {host:h1}] Monitor Title`
        *   False: `[Triggered] Monitor Title`

    ##### Metric Alert Options
    _These options only apply to metric alerts._

    -   `thresholds` a dictionary of thresholds by threshold type. Currently we have two threshold types for metric alerts: critical and warning. Critical is defined in the query, but can also be specified in this option. Warning threshold can only be specified using the thresholds option.
    If you want to use recovery thresholds for your monitor, use the attributes critical_recovery and warning_recovery.

            Example: `{'critical': 90, 'warning': 80,  'critical_recovery': 70, 'warning_recovery': 50}`

    -   `evaluation_delay` Time (in seconds) to delay evaluation, as a non-negative integer. For example, if the value is set to 300 (5min), the timeframe is set to last_5m and the time is 7:00, the monitor evaluates data from 6:50 to 6:55. This is useful for AWS CloudWatch and other backfilled metrics to ensure the monitor always has data during evaluation.

    ##### Service Check Options
    _These options only apply to service checks and are ignored for other monitor types._

    -   `thresholds` a dictionary of thresholds by status. Because service checks can have multiple thresholds, we don't define them directly in the query.

            Example: `{'ok': 1, 'critical': 1, 'warning': 1}`