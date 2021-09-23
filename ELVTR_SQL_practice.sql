/* SQL Practice Exercises */

/* Use the mobile notary schema. Calculate the week-over-week cumulative sum of notaries onboarded
 * and revenue. Use the notary onboarding date (not the session date) to aggregate revenue. */
WITH wk_totals AS (
SELECT date_trunc('week', onboarding_date) AS WEEK
, count(DISTINCT n.notary_id) AS n_notaries
, sum((50 + (0.75 * travel_distance) + (0.5 * session_duration) + 6) * pricing_multiplier) AS REVENUE
FROM mobile_notary.notary n 
LEFT JOIN mobile_notary."session" s 
ON n.notary_id = s.notary_id 
LEFT JOIN mobile_notary.session_event se 
ON s.session_id = se.session_id 
WHERE se."event" = 'SessionCompleted'
GROUP BY WEEK
ORDER BY WEEK
)
SELECT wt1.WEEK
, sum(wt2.n_notaries) AS cumulative_notaries
, sum(wt2.REVENUE) AS cumulative_revenue
FROM wk_totals wt1
INNER JOIN wk_totals wt2
ON wt1.WEEK >= wt2.WEEK
GROUP BY wt1.WEEK
ORDER BY wt1.WEEK


/* Question: You are interested in the number of sessions completed by a notary based on how long they have 
 * been with the company, and whether that number is changing over time. For example, do notaries complete
 * the most sessions in the weeks right after onboarding, and then decrease from there? Or do the number 
 * of sessions level out or increase the longer they have been working there? */
WITH wk_sessions AS (
SELECT (date_part('day', se."timestamp" - onboarding_date)/7)::int AS weeks_since_onboarding
, count(*) AS n_sessions
FROM mobile_notary.notary n 
LEFT JOIN mobile_notary."session" s 
ON s.notary_id = n.notary_id
LEFT JOIN mobile_notary.session_event se 
ON s.session_id = se.session_id
WHERE se."event" = 'SessionCompleted'
GROUP BY weeks_since_onboarding
ORDER BY weeks_since_onboarding
)
SELECT a.weeks_since_onboarding
	, n_sessions
	, cumulative_sessions
FROM wk_sessions a
LEFT JOIN (
	SELECT ws1.weeks_since_onboarding
	, sum(ws2.n_sessions) AS cumulative_sessions
	FROM wk_sessions ws1
	INNER JOIN wk_sessions ws2
	ON ws1.weeks_since_onboarding >= ws2.weeks_since_onboarding
	GROUP BY ws1.weeks_since_onboarding
	ORDER BY ws1.weeks_since_onboarding
) b
ON a.weeks_since_onboarding = b.weeks_since_onboarding