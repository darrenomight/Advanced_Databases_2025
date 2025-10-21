--NAME			  VALUE     CON_ID
-------------------- ---------- ----------
--Fixed Size		4928296 	 0
--Variable Size	      402653184 	 0
--Database Buffers      973078528 	 0
--Redo Buffers		4530176 	 0
--In-Memory Area	      218103808 	 0


-- Enable timing
SET TIMING ON

-- Analytical query
SELECT s.tid, SUM(s.amount), AVG(s.qty)
FROM sales_copy s
JOIN product p ON s.pid = p.pid
JOIN customer c ON s.cid = c.cid
GROUP BY s.tid;

SET TIMING OFF;

--99,949 rows selected. 
--Elapsed: 00:00:26.586

--99,949 rows selected. 
--Elapsed: 00:00:142

