SELECT
	IFNULL(it.`name`,
	'--') AS `name`,
	IFNULL(sum( toFloat64(inc.amount) ),
	0) AS amount
FROM
	income inc
LEFT JOIN income_contrast ic
 ON
	inc.income_term_name = ic.name_source
	and inc.income_term_no = ic.code_source
	and inc.customer = ic.hospital
LEFT JOIN income_type it
 ON
	ic.target = it.id
LEFT JOIN deparment_contrast dc
 ON
	dc.name_source = inc.department_name
	and dc.code_source = inc.department_no
	and dc.hospital = inc.customer
LEFT JOIN department d
 ON
	d.id = dc.target
LEFT JOIN visit_type vt
 ON
	( vt.`code` = inc.visit_type_name
		or vt.`name` = inc.visit_type_name)
WHERE
	inc.`status` = 1
	and inc.project = 78
	and inc.date >= '2021-11-01 00:00:00'
	and inc.date <= '2021-11-29 23:59:59'
GROUP BY
	it.id,
	name
ORDER BY
	amount desc;